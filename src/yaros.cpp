/* test.cpp */

#include <boost/filesystem.hpp>
#include <iostream>
#include <string>
#include <vector>
#include "YarosTrace.h"

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
    // instatiate YarosTrace (TODO: treat exceptions?)
    YarosTrace* yarosTrace = new YarosTrace(argv[1]);
    delete yarosTrace;
    return 0;
}
