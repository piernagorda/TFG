#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

long long int sumaConsumosE=0, sumaConsumosP=0, sumaConsumosGPU=0;
float vecesE = 0, vecesP=0, vecesGPU=0;

//Codigo para analizar el output del consumo y sacar la media
/*
int main(){
    //ENTRADA DEL FICHERO
    
    std::ifstream in("datos.txt");
    auto cinbuf = std::cin.rdbuf(in.rdbuf());
    //COMIENZO
    std::string linea;
    while (getline(std::cin, linea)) {
        std::stringstream ss(linea);
        std::string temp;
        ss>>temp;
        //Analizamos si tiene la cuenta de mW
        if (temp=="E-Cluster"){
            ss>>temp;
            if (temp=="Power:"){
                int consumo;
                ss>>consumo;
                sumaConsumosE+=consumo;
                ++vecesE;
            }
        }
        if (temp=="P-Cluster"){
            ss>>temp;
            if (temp=="Power:"){
                int consumo;
                ss>>consumo;
                sumaConsumosP+=consumo;
                ++vecesP;
            }
        }
    }
    std::cout<<"Media de Consumo en Cores E: "<<(sumaConsumosE/vecesE)<<"\n";
    std::cout<<"Media de Consumo en Cores P: "<<(sumaConsumosP/vecesP)<<"\n";
    std::cout<<"Consumo medio entre ambos cores: "<<(sumaConsumosE+sumaConsumosP)/vecesE << "\n";
    //FIN
    std::cin.rdbuf(cinbuf);
}
*/

int main(){
    //ENTRADA DEL FICHERO
    
    std::ifstream in("datos.txt");
    auto cinbuf = std::cin.rdbuf(in.rdbuf());
    //COMIENZO
    std::string linea;
    while (getline(std::cin, linea)) {
        std::stringstream ss(linea);
        std::string temp;
        ss>>temp;
        //Analizamos si tiene la cuenta de mW
        if (temp=="P-Cluster"){
            ss>>temp;
            if (temp=="Power:"){
                int consumo;
                ss>>consumo;
                if (consumo > 500){
                    sumaConsumosP+=consumo;
                    ++vecesP;
                }
            }
        }
        if (temp == "GPU"){
            ss>>temp;
            if (temp=="Power:"){
                int consumo;
                ss>>consumo;
                if (consumo > 100){
                    sumaConsumosGPU+=consumo;
                    ++vecesGPU;
                }
            }

        }
    }
    std::cout<<"Media de Consumo en Cores P: "<<(sumaConsumosP/vecesP)<<"\n";
    std::cout<<"Media de Consumo en GPU: "<<(sumaConsumosGPU/vecesGPU)<<"\n";
    std::cout<<"Consumo medio entre ambos cores: "<<(sumaConsumosE+sumaConsumosP)/vecesE << "\n";
    //FIN
    std::cin.rdbuf(cinbuf);
}
