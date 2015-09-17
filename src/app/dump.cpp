#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <limits>
#include <string>
#include <yaml-cpp/yaml.h>
#include "../lib/YarosCluster.h"
#include "../lib/YarosContainer.h"
#include "../lib/YarosUnity.h"
#include "../lib/YarosUtils.h"

const std::string SEP {","};

int main(int argc, char* argv[]) {
    /* Make std::cout an unbuffered stream */
    std::cout.setf(std::ios::unitbuf);
    /* Verify if call is good */
    if (argc != 3) {
        std::cout << "Wrong usage." << std::endl;
        std::cout << "dump <yaml-config> <paje-trace>" << std::endl;
        return 1;
    }
    if (!boost::filesystem::is_regular_file(argv[1])) {
        std::cout << "Inexistent config. file." << std::endl;
        return 2;
    }
    if (!YarosUtils::checkConfig(argv[1])) {
        std::cout << "Inconsistent config. file." << std::endl;
        return 3;
    }
    if (!boost::filesystem::is_regular_file(argv[2])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 4;
    }
    /* Get configuration from YAML file & Simulate trace */
    std::cout << "Get clustering config. & simulating Paje trace..." << std::endl;
    YAML::Node config;
    YarosUnity* unity;
    config = YarosUtils::getConfig(argv[1]);
    unity = new YarosUnity(argv[2]);
    /* Acquire data specified in YAML file from simulated trace */
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
    /* Output data to file */
    std::cout << "Writing data to file..." << std::endl;
    std::fstream filestream;
    std::string dumpPath;
    std::string filename;
    filename = boost::filesystem::path(argv[1]).filename().replace_extension().string() + ".dump.csv";
    dumpPath = (boost::filesystem::path(argv[2]).parent_path()/boost::filesystem::path(filename)).string();
    filestream.open(dumpPath, std::ios::out);
    filestream << "Container";
    for (auto d: config["data"])
        filestream << SEP << d.first;
    filestream << std::endl;
    for (auto& c: (*cMap)) {
        filestream << c.first;
        for (auto d: config["data"])
            filestream << SEP << ((c.second).find(d.first.as<std::string>()))->second;
        filestream << std::endl;
    }
    filestream.close();
    std::cout << "Done. Dump in '" << dumpPath << "'." << std::endl;
    delete unity;
    return 0;
}
