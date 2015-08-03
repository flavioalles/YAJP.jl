#ifndef YAROS_UTILS_H
#define YAROS_UTILS_H
#include <list>
#include <string>
#include <yaml-cpp/yaml.h>

namespace YarosUtils {
    const std::list<std::string> CONFIG_KEYS {"containers","data"};
    bool checkConfig(const std::string yamlPath);
    YAML::Node getConfig(const std::string yamlPath);
    std::string dataInConfig(const YAML::Node config, const std::string name);
}
#endif
