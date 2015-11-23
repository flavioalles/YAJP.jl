#include <boost/filesystem.hpp>
#include <cmath>
#include <fstream>
#include <iostream>
#include <limits>
#include <string>
#include <yaml-cpp/yaml.h>
#include "../lib/YarosUnity.h"

int main(int argc, char* argv[]) {
    /* Make std::cout an unbuffered stream */
    std::cout.setf(std::ios::unitbuf);
    /* Verify if call is good */
    if (argc != 2) {
        std::cout << "Wrong usage." << std::endl;
        std::cout << "yaros-span <paje-trace>" << std::endl;
        return 1;
    }
    if (!boost::filesystem::is_regular_file(argv[1])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    /* Get configuration from YAML file & Simulate trace */
    std::cout << "Simulating Paje trace..." << std::endl;
    YarosUnity* unity;
    unity = new YarosUnity(argv[1]);
    /* Output span */
    std::cout << (unity->endTime()-unity->startTime()) << std::endl;
    delete unity;
    return 0;
}
