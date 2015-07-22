#ifndef YAROS_UTILS_H
#define YAROS_UTILS_H
#include <list>
#include <string>
#include <yaml-cpp/yaml.h>

namespace YarosUtils {
    extern const std::list<std::string> CONFIG_KEYS;
    bool checkConfig(const std::string yamlPath);
    YAML::Node getConfig(const std::string yamlPath);
}
#endif
