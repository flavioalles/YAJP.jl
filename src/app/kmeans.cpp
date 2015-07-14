#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <string>
#include "../lib/YarosCluster.h"
#include "../lib/YarosContainer.h"
#include "../lib/YarosUnity.h"

int K = 3;
std::list<std::string> NAMES {"chol_model_11","chol_model_21","chol_model_22"};
std::list<std::string> TYPES {"Worker"};
std::string OUTPUT_FILE {"kmeans.out"};

bool dataInNames(std::string name) {
    for (auto n: NAMES)
        if (n == name)
            return true;
    return false;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    if (!boost::filesystem::exists(argv[1])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    std::cout << "Simulating Paje trace..." << std::endl;
    YarosUnity* unity = new YarosUnity(argv[1]);
    std::cout << "Retrieving data..." << std::endl;
    std::map<std::string,std::map<std::string,double>>* cMap = new std::map<std::string,std::map<std::string,double>>();
    for (auto t: TYPES) {
        for (auto& c: unity->getContainersOfType(t)) {
            std::map<std::string,double>* dMap = new std::map<std::string,double>();
            for (auto& d: static_cast<YarosContainer*>(c)->getData())
                if (dataInNames(d->getName())) {
                    if (dMap->find(d->getName()) == dMap->end())
                        dMap->insert({d->getName(),(d->getEnd()-d->getStart())});
                    else
                        (dMap->find(d->getName()))->second += (d->getEnd()-d->getStart());
                }
            // insert NAMES that were not present in YarosContainer->getData()
            for (auto n: NAMES)
                if (dMap->find(n) == dMap->end())
                    dMap->insert({n,0.0});
            cMap->insert({c->name(),*dMap});
        }
    }
    std::cout << "Clustering data..." << std::endl;
    std::map<std::string,std::string> gMap = YarosCluster::kMeans(K, *cMap);
    std::cout << "Writing results to file..." << std::endl;
    std::fstream filestream;
    filestream.open((boost::filesystem::path(argv[1]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string(), std::ios::out);
    for (auto& c: gMap) {
        filestream << c.first << "," << c.second;
        for (auto& n: NAMES)
            filestream << "," << (((cMap->find(c.first))->second).find(n))->second;
        filestream << std::endl;
    }
    filestream.close();
    std::cout << "Done. Results in '" << (boost::filesystem::path(argv[1]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string() << "'." << std::endl;
    delete unity;
    return 0;
}
