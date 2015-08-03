#include "YarosUtils.h"

bool YarosUtils::checkConfig(const std::string yamlPath) {
    YAML::Node config = YAML::LoadFile(yamlPath);
    if (config.size() != YarosUtils::CONFIG_KEYS.size())
        return false;
    for (auto key: YarosUtils::CONFIG_KEYS) {
        if (!config[key])
            return false;
        if (key == "containers") {
            if ((!config[key].IsSequence()) || (config[key].size() == 0))
                return false;
        }
        if (key == "data") {
            if ((!config[key].IsMap()) || (config[key].size() == 0))
                return false;
        }
    }
    return true;
}

YAML::Node YarosUtils::getConfig(const std::string yamlPath) {
    return YAML::LoadFile(yamlPath);
}

std::string YarosUtils::dataInConfig(const YAML::Node config, const std::string name) {
    for (auto d: config["data"])
        for (auto n: d.second)
            if (n.as<std::string>() == name)
                return d.first.as<std::string>();
    return std::string();
}
