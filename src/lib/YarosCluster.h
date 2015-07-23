#ifndef YAROS_CLUSTER_H
#define YAROS_CLUSTER_H
#include <cmath>
#include <ctime>
#include <exception>
#include <limits>
#include <list>
#include <map>
#include <string>
#include <vector>

namespace YarosCluster {
    std::map<std::string,std::string>& kMeans(const int k, const std::map<std::string,std::map<std::string,double>>& cMap);
    double intraGroupEval(const std::map<std::string,std::string>& gMap, const std::map<std::string,std::map<std::string,double>>& cMap);
    double interGroupEval(const std::map<std::string,std::string>& gMap, const std::map<std::string,std::map<std::string,double>>& cMap);
}
#endif
