#include "YarosCluster.h"

namespace KMeans {
    std::vector<std::string> initCentroids(const int k, const std::map<std::string,std::string>& gMap) {
        std::vector<std::string> centroids;
        std::list<int> indexes = std::list<int>();
        while (indexes.size() != k) {
            std::srand(std::time(nullptr));
            indexes.push_back((std::rand()%gMap.size()));
            indexes.sort();
            indexes.unique();
        }
        int i = 0;
        int index = indexes.front();
        indexes.pop_front();
        for (auto& container: gMap) {
            if (i == index) {
                centroids.push_back(container.first); 
                if (indexes.empty()) {
                    break;
                }
                else {
                    index = indexes.front();
                    indexes.pop_front();
                }
            }
            ++i;
        }
        return centroids;
    }

    double computeDistance(std::map<std::string,double> centroid, std::map<std::string,double> container) {
        double distance = 0.0;
        for (auto s: centroid)
            distance += std::pow((s.second)-(container.find(s.first))->second,2);
        return std::sqrt(distance);
    }

    std::vector<std::string> recomputeCentroids(const std::map<std::string,std::map<std::string,double>>& cMap, const std::map<std::string,std::string>& gMap, const std::vector<std::string>& oldCentroids) {
        std::vector<std::string>* newCentroids = new std::vector<std::string>();
        // for every GROUP (centroid)
        for (auto& centroid: oldCentroids) {
            int counter = 0;
            std::map<std::string,double> sum = std::map<std::string,double>();
            // for every MEMBER: accumulate SUM
            for (auto& container: gMap) {
                if (centroid == container.second) {
                    for (auto& data: (cMap.find(container.first))->second) {
                        if (sum.find(data.first) == sum.end())
                            sum.insert({data.first, data.second});
                        else
                            (sum.find(data.first))->second += data.second;
                    }
                    ++counter;
                }
            }
            // calculate MEAN
            std::map<std::string,double> mean = std::map<std::string,double>();
            for (auto& data: sum)
                mean.insert({data.first,data.second/counter});
            // for every CONTAINER: determine new centroid (closest to MEAN)
            double shortestDist = std::numeric_limits<double>::max();
            std::string newCentroid = std::string();
            for (auto& container: gMap) {
                double currentDist = computeDistance(mean,cMap.find(container.first)->second);
                if (shortestDist > currentDist) {
                    shortestDist = currentDist;
                    newCentroid = container.first;
                }
            }
            newCentroids->push_back(newCentroid);
        }
        return *newCentroids;
    }
}

std::map<std::string,std::string>& YarosCluster::kMeans(const int k, const std::map<std::string,std::map<std::string,double>>& cMap) {
    if (k <= 0) {
        throw std::invalid_argument("k (#-of-clusters) must be a natural number.");
    }
    std::map<std::string,std::string>* gMap = new std::map<std::string,std::string>();
    for (auto& container: cMap)
        gMap->insert({container.first,std::string()});
    // Select 'k' points as initial centroids
    std::vector<std::string> centroids = KMeans::initCentroids(k, *gMap);
    std::vector<std::string> oldCentroids {};
    // Repeat
    while (centroids != oldCentroids) {
        // Form 'k' clusters by assigning each point to its closest centroid
        for (auto& container: cMap) {
            double shortestDist = std::numeric_limits<double>::max();
            std::string closestCentroid = std::string();
            for (auto currentCentroid: centroids) {
                double currentDist = KMeans::computeDistance(cMap.find(currentCentroid)->second, container.second);
                if (shortestDist > currentDist) {
                    shortestDist = currentDist;
                    closestCentroid = currentCentroid;
                }
            }
            (gMap->find(container.first))->second = closestCentroid;
        }
        // Recompute the centroid of each cluster
        oldCentroids = centroids;
        centroids = KMeans::recomputeCentroids(cMap, *gMap, centroids);
    }
    // Until Centroids do not change
    return *gMap;
}
