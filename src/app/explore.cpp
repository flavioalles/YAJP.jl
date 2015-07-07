#include <boost/filesystem.hpp>
#include <iostream>
#include <string>
#include "../lib/YarosContainer.h"
#include "../lib/YarosUnity.h"

void dumpContainerByName(YarosUnity* unity, std::string name) {
    for (auto& l: unity->getContainerTopology())
        for (auto& c: l.second)
            if (c->name() == name) {
                std::cout << c->description() << std::endl;
                for (auto& d: static_cast<YarosContainer*>(c)->getData())
                    std::cout << d->dumpData() << std::endl;
            }
}

void dumpContainerByType(YarosUnity* unity, std::string type) {
    for (auto& l: unity->getContainerTopology())
        for (auto& c: l.second)
            if (c->type()->name() == type) {
                std::cout << c->description() << std::endl;
                for (auto& d: static_cast<YarosContainer*>(c)->getData())
                    std::cout << d->dumpData() << std::endl;
            }
}

int main(int argc, char* argv[]) {
    if (argc != 4 || (std::string(argv[1]) != std::string("--name") && std::string(argv[1]) != std::string("--type")) || !boost::filesystem::exists(argv[3])) {
        std::cout << "Wrong usage." << std::endl;
        std::cout << "explore (--name <container-name> | --type <container-type>) <trace-file>" << std::endl;
        return 1;
    }
    YarosUnity* unity = new YarosUnity(argv[3]);
    if (std::string(argv[1]) == std::string("--name")) {
        dumpContainerByName(unity, std::string(argv[2]));
    }
    else {
        dumpContainerByType(unity, std::string(argv[2]));
    }
    return 0;
}
