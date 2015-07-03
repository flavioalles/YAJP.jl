#include <boost/filesystem.hpp>
#include <iostream>
#include "../lib/YarosUnity.h"
#include "../lib/YarosContainer.h"

int CONTAINER_DEPTH = 5;
int NUM_CENTERS_MAX = 10;
std::string TYPE_NAME = "Worker State";
std::string STATE_NAME = "chol_model_11";

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    if (!boost::filesystem::exists(argv[1])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    YarosUnity* unity = new YarosUnity(argv[1]);
    for (auto& c: unity->getContainersOfDepth(CONTAINER_DEPTH)) {
        for (auto& d: static_cast<YarosContainer*>(c)->getData(unity->entityTypeWithName(TYPE_NAME)))
            if (d->getName() == STATE_NAME);
        break;
    }
    delete unity;
    return 0;
}
