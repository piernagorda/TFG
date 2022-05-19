import MetalPerformanceShaders
import Accelerate

var dim = 100

while (dim<=31000){
    let ops = 2*dim*dim*dim

    //Matriz A
    var matrixAEntries: [Float32] = (0..<dim*dim).map{ _ in Float32.random(in: 1 ... 10)}
    print("Matriz A creada")
    //Matriz
    var matrixBEntries: [Float32] = (0..<dim*dim).map{ _ in Float32.random(in: 1 ... 10)}
    print("Matriz B creada")
    //Matriz C
    var matrixCEntries: [Float32] = (0..<dim*dim).map{ _ in Float32.random(in: 1 ... 10)}
    print("Matriz C creada")
    //--------------------------------------------------ACCELERATE

    let firstMatrix :  [Float32] = matrixAEntries
    let secondMatrix : [Float32] = matrixBEntries
    var answerMatrix : [Float32] = matrixCEntries
    let start = DispatchTime.now()
    print("Empezando sgemm...")
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(dim), Int32(dim), Int32(dim), 1.0,
                firstMatrix, Int32(dim), secondMatrix, Int32(dim), 1.0, &answerMatrix, Int32(dim))
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
    let timeInterval = Double(nanoTime) / 1_000_000_000
    var gflopsAccelerate: Double = (Double(ops)/1000000000)/timeInterval
    //print(answerMatrix)

    print("GFLOPS Accelerate: \(gflopsAccelerate). Tiempo: \(timeInterval). N: \(dim)")
    //--------------------------------------------------MPS
    let device = MTLCreateSystemDefaultDevice()!
    let commandQueue = device.makeCommandQueue()!
    let commandBuffer = commandQueue.makeCommandBuffer()!

    //C = alpha * AB + beta * C

    let mmKernel = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: dim, resultColumns: dim, interiorColumns: dim, alpha: 1.0, beta: 1.0)

    //Preparando Matriz A
    let totalBytesA = MemoryLayout<Float32>.stride * matrixAEntries.count
    let bufferA = device.makeBuffer(bytes: matrixAEntries, length: totalBytesA, options: .storageModeShared)
    let descriptorA = MPSMatrixDescriptor(dimensions: dim, columns: dim, rowBytes: totalBytesA/dim, dataType: .float32)
    let A = MPSMatrix(buffer: bufferA!, descriptor: descriptorA)

    //Preparando Matrix B
    let totalBytesB = MemoryLayout<Float32>.stride * matrixBEntries.count
    let bufferB = device.makeBuffer(bytes: matrixBEntries, length: totalBytesB, options: .storageModeShared)
    let descriptorB = MPSMatrixDescriptor(rows: dim, columns: dim, rowBytes: totalBytesB/dim, dataType: .float32)
    let B = MPSMatrix(buffer: bufferB!, descriptor: descriptorB)
    //Preparando Matriz C
    let totalBytesC = MemoryLayout<Float32>.stride * A.rows*B.columns
    let bufferC = device.makeBuffer(length: totalBytesC, options: .storageModeShared)
    let descriptorC = MPSMatrixDescriptor(rows: dim, columns: dim, rowBytes: totalBytesC/dim, dataType: .float32)
    let C = MPSMatrix(buffer: bufferC!, descriptor: descriptorC)

    let start2 = DispatchTime.now()
    mmKernel.encode(commandBuffer: commandBuffer, leftMatrix: A, rightMatrix: B, resultMatrix: C)
    print("Empezando MPS...")
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    let end2 = DispatchTime.now()
    let nanoTime2 = end2.uptimeNanoseconds - start2.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
    let timeInterval2 = Double(nanoTime2) / 1_000_000_000

    var output = [Float32]()
    let rawPointer = C.data.contents()
    let typePointer = rawPointer.bindMemory(to: Float32.self, capacity: A.rows*B.columns)
    let bufferPointer = UnsafeBufferPointer(start: typePointer, count: A.rows*B.columns)
    /*
    bufferPointer.map{
        value in
        output += [value]
    }
     */
    //print(output)

    var gflopsGPU: Double = (Double(ops)/1000000000)/timeInterval2

    print("GFLOPS GPU: \(gflopsGPU). Tiempo: \(timeInterval2). N: \(dim)")
    print("----")
    dim = dim+5000
}

//debugPrint(difference)
