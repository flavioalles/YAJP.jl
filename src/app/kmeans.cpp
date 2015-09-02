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

const int MAX_GROUPS = 4;
const int RUNS = 10;
const std::string KMEANS_OUTPUT {"kmeans.csv"};
const std::string RESULTS_OUTPUT {"results.csv"};
const std::string SEP {","};

int main(int argc, char* argv[]) {
    /* Make std::cout an unbuffered stream */
    std::cout.setf(std::ios::unitbuf);
    /* Verify if call is good */
    if ((argc < 3) || (argc > 4) || ((argc == 4) && (argv[1] != std::string("--no-overwrite")))) {
        std::cout << "Wrong usage." << std::endl;
        std::cout << "kmeans [--no-overwrite] <yaml-config> <paje-trace>" << std::endl;
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
    /* Get configuration from YAML file & Simulate trace */
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
    /* Cluster acquired data */
    std::cout << "Clustering data..." << std::endl;
    int bestK;
    double minSSE = std::numeric_limits<double>::max();
    std::map<std::string,int> gMap;
    for (int k = 1; k <= MAX_GROUPS; ++k) {
        std::cout << "  (K = " << k << ") ";
        for (int r = 0; r != RUNS; ++r) {
            std::cout << ".";
            std::map<std::string,int> currentGMap = YarosCluster::kMeans(k, *cMap);
            double currentSSE = YarosCluster::SSE(currentGMap,*cMap);
            if (currentSSE < minSSE) {
                minSSE = currentSSE;
                bestK = k;
                gMap = std::move(currentGMap);
            }
        }
        std::cout << " Done."<< std::endl;
    }
    double SSB = YarosCluster::SSB(gMap, *cMap);
    /* Output clustering results to file */
    std::cout << "Writing results to files..." << std::endl;
    std::fstream filestream;
    std::string filename;
    // Groupings
    std::string kmeansPath;
    if (argc == 3) {
        filename = boost::filesystem::path(argv[1]).filename().replace_extension().string() + ".kmeans.csv";
        kmeansPath = (boost::filesystem::path(argv[2]).parent_path()/boost::filesystem::path(filename)).string();
    } else {
        int index = 1;
        kmeansPath = (boost::filesystem::path(argv[3]).parent_path()/boost::filesystem::path(KMEANS_OUTPUT)).string();
        std::string basePath = kmeansPath;
        while (boost::filesystem::is_regular_file(boost::filesystem::path(kmeansPath))) {
            kmeansPath = (boost::filesystem::path(basePath)).replace_extension(boost::filesystem::path(std::to_string(index)+(boost::filesystem::path(KMEANS_OUTPUT).extension().string()))).string();
            ++index;
        }
    }
    filestream.open(kmeansPath, std::ios::out);
    filestream << "container" << SEP << "group";
    for (auto d: config["data"])
        filestream << SEP << d.first;
    filestream << std::endl;
    for (auto& c: gMap) {
        filestream << c.first << SEP << c.second;
        for (auto d: config["data"])
            filestream << SEP << (((cMap->find(c.first))->second).find(d.first.as<std::string>()))->second;
        filestream << std::endl;
    }
    filestream.close();
    // Results
    std::string resultsPath;
    if (argc == 3) {
        filename = boost::filesystem::path(argv[1]).filename().replace_extension().string() + ".results.csv";
        resultsPath = (boost::filesystem::path(argv[2]).parent_path()/boost::filesystem::path(filename)).string();
    } else {
        int index = 1;
        resultsPath = (boost::filesystem::path(argv[3]).parent_path()/boost::filesystem::path(RESULTS_OUTPUT)).string();
        std::string basePath = resultsPath;
        while (boost::filesystem::is_regular_file(boost::filesystem::path(resultsPath))) {
            resultsPath = (boost::filesystem::path(basePath)).replace_extension(boost::filesystem::path(std::to_string(index)+(boost::filesystem::path(KMEANS_OUTPUT).extension().string()))).string();
            ++index;
        }
    }
    filestream.open(resultsPath, std::ios::out);
    filestream << "runtime" << SEP << "K" << SEP << "SSE" << SEP << "SSB" << std::endl;
    filestream << (unity->endTime()-unity->startTime()) << SEP << bestK << SEP << minSSE << SEP << SSB << std::endl;
    filestream.close();
    std::cout << "Done." << std::endl;
    std::cout << "Groupings in '" << kmeansPath << "'." << std::endl;
    std::cout << "Results in '" << resultsPath << "'." << std::endl;
    delete unity;
    return 0;
}
