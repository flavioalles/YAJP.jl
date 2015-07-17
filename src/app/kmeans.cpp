#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <string>
#include "../lib/YarosCluster.h"
#include "../lib/YarosContainer.h"
#include "../lib/YarosUnity.h"

const int K = 3;
const std::string OUTPUT_FILE {"kmeans.out"};
const std::string SEP {","};
const std::map<std::string,std::list<std::string>> NAMES {
    {"tasks",{"chol_model_11","chol_model_21","chol_model_22"}},
    {"misc",{"Callback","FetchingInput","Initializing","Overhead","PushingOutput","Scheduling"}}
};
const std::list<std::string> TYPES {"Worker"};

std::string dataInNames(std::string name) {
    for (auto& d: NAMES)
        for (auto& n: d.second)
            if (n == name)
                return d.first;
    return std::string();
}

int main(int argc, char* argv[]) {
    if ((argc < 2) || (argc > 3) || ((argc == 3) && (argv[1] != std::string("--no-overwrite")))) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    if (((argc == 2) && (!boost::filesystem::is_regular_file(argv[1]))) || ((argc == 3) && (!boost::filesystem::is_regular_file(argv[2])))) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    std::cout << "Simulating Paje trace..." << std::endl;
    YarosUnity* unity;
    if (argc == 2)
        unity = new YarosUnity(argv[1]);
    else
        unity = new YarosUnity(argv[2]);
    std::cout << "Retrieving data..." << std::endl;
    std::map<std::string,std::map<std::string,double>>* cMap = new std::map<std::string,std::map<std::string,double>>();
    for (auto t: TYPES) {
        for (auto& c: unity->getContainersOfType(t)) {
            std::map<std::string,double>* dMap = new std::map<std::string,double>();
            for (auto& d: static_cast<YarosContainer*>(c)->getData()) {
                std::string mapKey = dataInNames(d->getName());
                if (!mapKey.empty()) {
                    if (dMap->find(mapKey) == dMap->end())
                        dMap->insert({mapKey,(d->getEnd()-d->getStart())});
                    else
                        (dMap->find(mapKey))->second += (d->getEnd()-d->getStart());
                }
            }
            // insert NAMES that were not present in YarosContainer->getData()
            for (auto& d: NAMES)
                if (dMap->find(d.first) == dMap->end())
                    dMap->insert({d.first,0.0});
            cMap->insert({c->name(),*dMap});
        }
    }
    std::cout << "Clustering data..." << std::endl;
    std::map<std::string,std::string> gMap = YarosCluster::kMeans(K, *cMap);
    std::cout << "Writing results to file..." << std::endl;
    std::fstream filestream;
    std::string outputPath;
    if (argc == 2) {
        outputPath = (boost::filesystem::path(argv[1]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string();
    }
    else { // (argc == 3)
        int index = 1;
        outputPath = (boost::filesystem::path(argv[2]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string();
        std::string basePath = outputPath;
        while (boost::filesystem::is_regular_file(boost::filesystem::path(outputPath))) {
            outputPath = (boost::filesystem::path(basePath)).replace_extension(boost::filesystem::path(std::to_string(index)+(boost::filesystem::path(OUTPUT_FILE).extension().string()))).string();
            ++index;
        }
    }
    filestream.open(outputPath, std::ios::out);
    filestream << "Container" << SEP << "Centroid";
    // assuming that iteration over std::pair's of std::map follows always the same order
    for (auto d: NAMES)
        filestream << SEP << d.first;
    filestream << std::endl;
    for (auto& c: gMap) {
        filestream << c.first << SEP << c.second;
        // assuming that iteration over std::pair's of std::map follows always the same order
        for (auto& d: NAMES)
            filestream << SEP << (((cMap->find(c.first))->second).find(d.first))->second;
        filestream << std::endl;
    }
    filestream.close();
    std::cout << "Done. Results in '" << outputPath << "'." << std::endl;
    delete unity;
    return 0;
}
