#include <boost/filesystem.hpp>
#include <iostream>
#include "../src/YarosContainer.h"
#include "../src/YarosUnity.h"

int CONTAINER_DEPTH = 5;
std::string TYPE_NAME = "Worker State";

int main(int argc, char* argv[]) {
    // #arguments ok?
    if (argc != 2) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    // argv[1] is an existent file?
    if (!boost::filesystem::exists(argv[1])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    YarosUnity* unity = new YarosUnity(argv[1]);
    for (auto& c: unity->getContainersOfDepth(CONTAINER_DEPTH)) {
        YarosContainer* container = new YarosContainer(*c);
        for (auto& d: container->getData(unity->entityTypeWithName(TYPE_NAME)));
    }
    delete unity;
    return 0;
}
