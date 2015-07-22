#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <string>
#include <yaml-cpp/yaml.h>
#include "../lib/YarosCluster.h"
#include "../lib/YarosContainer.h"
#include "../lib/YarosUnity.h"
#include "../lib/YarosUtils.h"

const int K = 3;
const std::string OUTPUT_FILE {"kmeans.out"};
const std::string SEP {","};

int main(int argc, char* argv[]) {
    if ((argc < 3) || (argc > 4) || ((argc == 4) && (argv[1] != std::string("--no-overwrite")))) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    if (((argc == 3) && (!boost::filesystem::is_regular_file(argv[1]))) || ((argc == 4) && (!boost::filesystem::is_regular_file(argv[2])))) {
        std::cout << "Inexistent config. file." << std::endl;
        return 2;
    }
    if (((argc == 3) && (!YarosUtils::checkConfig(argv[1]))) || ((argc == 4) && (!YarosUtils::checkConfig(argv[2])))) {
        std::cout << "Inconsistent config. file." << std::endl;
        return 3;
    }
    if (((argc == 3) && (!boost::filesystem::is_regular_file(argv[2]))) || ((argc == 4) && (!boost::filesystem::is_regular_file(argv[3])))) {
        std::cout << "Inexistent trace file." << std::endl;
        return 4;
    }
    std::cout << "Get clustering config. & simulating Paje trace..." << std::endl;
    YAML::Node config;
    YarosUnity* unity;
    if (argc == 3) {
        config = YarosUtils::getConfig(argv[1]);
        unity = new YarosUnity(argv[2]);
    }
    else {
        config = YarosUtils::getConfig(argv[2]);
        unity = new YarosUnity(argv[3]);
    }
    std::cout << "Retrieving data..." << std::endl;
    std::map<std::string,std::map<std::string,double>>* cMap = new std::map<std::string,std::map<std::string,double>>();
    for (auto t: config["containers"]) {
        for (auto& c: unity->getContainersOfType(t.as<std::string>())) {
            std::map<std::string,double>* dMap = new std::map<std::string,double>();
            for (auto& d: static_cast<YarosContainer*>(c)->getData()) {
                // discover if container name is in config["data"]
                // if yes, config["data"].first is dMap's key for data in this container
                std::string mapKey = YarosUtils::dataInConfig(config, d->getName());
                if (!mapKey.empty()) {
                    if (dMap->find(mapKey) == dMap->end())
                        dMap->insert({mapKey,(d->getEnd()-d->getStart())});
                    else
                        (dMap->find(mapKey))->second += (d->getEnd()-d->getStart());
                }
            }
            // insert names in config["data"] that were not present in YarosContainer->getData()
            for (auto d: config["data"])
                if (dMap->find(d.first.as<std::string>()) == dMap->end())
                    dMap->insert({d.first.as<std::string>(),0.0});
            cMap->insert({c->name(),*dMap});
        }
    }
    std::cout << "Clustering data..." << std::endl;
    std::map<std::string,std::string> gMap = YarosCluster::kMeans(K, *cMap);
    std::cout << "Writing results to file..." << std::endl;
    std::fstream filestream;
    std::string outputPath;
    if (argc == 3) {
        outputPath = (boost::filesystem::path(argv[2]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string();
    }
    else {
        int index = 1;
        outputPath = (boost::filesystem::path(argv[3]).parent_path()/boost::filesystem::path(OUTPUT_FILE)).string();
        std::string basePath = outputPath;
        while (boost::filesystem::is_regular_file(boost::filesystem::path(outputPath))) {
            outputPath = (boost::filesystem::path(basePath)).replace_extension(boost::filesystem::path(std::to_string(index)+(boost::filesystem::path(OUTPUT_FILE).extension().string()))).string();
            ++index;
        }
    }
    filestream.open(outputPath, std::ios::out);
    filestream << "Container" << SEP << "Centroid";
    // assuming that iteration over std::pair's of std::map always follows the same order
    for (auto d: config["data"])
        filestream << SEP << d.first;
    filestream << std::endl;
    for (auto& c: gMap) {
        filestream << c.first << SEP << c.second;
        // assuming that iteration over std::pair's of std::map follows the same order
        for (auto d: config["data"])
            filestream << SEP << (((cMap->find(c.first))->second).find(d.first.as<std::string>()))->second;
        filestream << std::endl;
    }
    filestream.close();
    std::cout << "Done. Results in '" << outputPath << "'." << std::endl;
    delete unity;
    return 0;
}
