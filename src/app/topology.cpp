#include <boost/filesystem.hpp>
#include <iostream>
#include <string>
#include "../lib/YarosUnity.h"

void dumpContainerTopology(YarosUnity* unity) {
    for (auto& l: unity->getContainerTopology())
        for (auto& c: l.second)
            std::cout << "[" << l.first << "] " << c->description() << std::endl;
}

void dumpTypeTopology(YarosUnity* unity) {
    for (auto& l: unity->getTypeTopology())
        for (auto& t: l.second)
            if (t->parent()) {
                std::cout << "[" << l.first << "] " << t->kind() << ", " << (t->parent())->name() << ", " << t->name() << ", " << t->alias()  << std::endl;
            } 
            else {
                std::cout << "[" << l.first << "] " << t->kind()  << ", " << "null" << ", " << t->name() << ", " << t->alias()  << std::endl;
            }
}

int main(int argc, char* argv[]) {
    if (argc != 3 || (std::string(argv[1]) != std::string("--containers") && std::string(argv[1]) != std::string("--types")) || !boost::filesystem::exists(argv[2])) {
        std::cout << "Wrong usage." << std::endl;
        std::cout << "topology (--containers | --types) <trace-file>" << std::endl;
        return 1;
    }
    YarosUnity* unity = new YarosUnity(argv[2]);
    if (std::string(argv[1]) == std::string("--containers")) {
        dumpContainerTopology(unity);
    }
    else {
        dumpTypeTopology(unity);
    }
    return 0;
}
