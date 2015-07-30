#include "YarosCluster.h"

namespace KMeans {
    std::vector<std::map<std::string,double>> initCentroids(const int k, const std::map<std::string,std::map<std::string,double>>& cMap) {
        std::list<int> indexes;
        std::vector<std::map<std::string,double>> centroids;
        while (indexes.size() != k) {
            std::srand(std::time(nullptr));
            indexes.push_back((std::rand()%cMap.size()));
            indexes.sort();
            indexes.unique();
        }
        int i = 0;
        int index = indexes.front();
        indexes.pop_front();
        for (auto& container: cMap) {
            if (i == index) {
                centroids.push_back(container.second);
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

    std::vector<std::map<std::string,double>> computeCentroids(const std::map<std::string,std::map<std::string,double>>& cMap, const std::map<std::string,int>& gMap, const std::vector<std::map<std::string,double>>& oldCentroids) {
        std::vector<std::map<std::string,double>> newCentroids;
        // for every GROUP (centroid)
        for (int i = 0; i != oldCentroids.size(); ++i) {
            int counter = 0;
            std::map<std::string,double> newCentroid;
            // accumulate SUM
            for (auto& container: gMap) {
                if (i == container.second) {
                    for (auto& data: (cMap.find(container.first))->second) {
                        if (newCentroid.find(data.first) == newCentroid.end())
                            newCentroid.insert({data.first, data.second});
                        else
                            (newCentroid.find(data.first))->second += data.second;
                    }
                    ++counter;
                }
            }
            // calculate MEAN
            for (auto& data: newCentroid)
                data.second /= counter;
            newCentroids.push_back(newCentroid);
        }
        return newCentroids;
    }
}

std::map<std::string,int> YarosCluster::kMeans(const int k, const std::map<std::string,std::map<std::string,double>>& cMap) {
    if (k <= 0) {
        throw std::invalid_argument("k (#-of-clusters) must be a natural number.");
    }
    std::map<std::string,int> gMap = std::map<std::string,int>();
    // Select 'k' points as initial centroids
    std::vector<std::map<std::string,double>> centroids = KMeans::initCentroids(k, cMap);
    std::vector<std::map<std::string,double>> oldCentroids;
    // Repeat
    while (centroids != oldCentroids) {
        // Form 'k' clusters by assigning each point to its closest centroid
        for (auto& container: cMap) {
            int closestCentroid = -1;
            double shortestDist = std::numeric_limits<double>::max();
            for (int i = 0; i != centroids.size(); ++i) {
                double currentDist = KMeans::computeDistance(centroids[i], container.second);
                if (currentDist < shortestDist) {
                    shortestDist = currentDist;
                    closestCentroid = i;
                }
            }
            gMap[container.first] = closestCentroid;
        }
        // Recompute the centroid of each cluster
        oldCentroids = centroids;
        centroids = KMeans::computeCentroids(cMap, gMap, centroids);
    }
    // Until Centroids do not change
    return gMap;
}

double YarosCluster::SSE(const std::map<std::string,int>& gMap, const std::map<std::string,std::map<std::string,double>>& cMap) {
    /* Measure of COHESION: Sum of the squared Euclidian distance of every object to its cluster centroid */
    double totalSSE = 0.0;
    for (auto& container: gMap)
        totalSSE += KMeans::computeDistance(KMeans::computeCentroid(container.second,gMap,cMap), cMap.find(container.first)->second);
    return totalSSE;
}

double YarosCluster::SSB(const std::map<std::string,int>& gMap, const std::map<std::string,std::map<std::string,double>>& cMap) {
    /* Measure of SEPARATION: Weigthed sum of the squared Euclidian distance of every cluster centroid to the data centroid */
    double totalSSB = 0.0;
    std::map<std::string,double> centroid = KMeans::computeCentroid(cMap);
    for (int i = 0; i != k; ++i)
        totalSSB += (KMeans::memberCount(i,gMap))*(KMeans::computeDistance(centroid,KMeans::computeCentroid(i,gMap,cMap)));
    return totalSSB;
}
