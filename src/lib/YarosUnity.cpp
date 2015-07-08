#include "YarosUnity.h"
#include <map>
#include <queue>
#include <string>
#include <vector>

YarosUnity::YarosUnity(const std::string tracefile): PajeUnity(false, false, tracefile, -1, 1, nullptr) {
}

YarosUnity::~YarosUnity() {
}

std::map<int,std::vector<PajeContainer*>>& YarosUnity::getContainerTopology() {
    std::map<int,std::vector<PajeContainer*>>* containers = new std::map<int,std::vector<PajeContainer*>>();
    std::queue<PajeContainer*> discovered;
    discovered.push(this->rootInstance());
    while (!discovered.empty()) {
        PajeContainer* container = discovered.front();
        discovered.pop();
        auto keyValuePair = containers->find(container->depth);
        if (keyValuePair == containers->end()) {
            std::vector<PajeContainer*>* contV = new std::vector<PajeContainer*>;
            contV->push_back(container);
            containers->insert({container->depth, *contV});
        }
        else {
            (keyValuePair->second).push_back(container);
        }
        for (auto &child: container->getChildren())
            discovered.push(child);
    }
    return *containers;
}

std::vector<PajeContainer*>& YarosUnity::getContainersOfDepth(int depth) {
    std::vector<PajeContainer*> *containers = new std::vector<PajeContainer*>();
    if (depth >= 0) {
        std::queue<PajeContainer*> discovered;
        discovered.push(this->rootInstance());
        while (!discovered.empty()) {
            PajeContainer* container = discovered.front();
            discovered.pop();
            if (container->depth == depth)
                containers->push_back(container);
            for (auto &child: container->getChildren())
                discovered.push(child);
        }
    }
    return *containers;
}

std::vector<PajeContainer*>& YarosUnity::getContainersOfName(std::string name) {
    std::vector<PajeContainer*> *containers = new std::vector<PajeContainer*>();
    if (!name.empty()) {
        std::queue<PajeContainer*> discovered;
        discovered.push(this->rootInstance());
        while (!discovered.empty()) {
            PajeContainer* container = discovered.front();
            discovered.pop();
            if (container->type()->name() == name)
                containers->push_back(container);
            for (auto &child: container->getChildren())
                discovered.push(child);
        }
    }
    return *containers;
}

std::map<int,std::vector<PajeType*>>& YarosUnity::getTypeTopology() {
    std::map<int,std::vector<PajeType*>>* types = new std::map<int,std::vector<PajeType*>>();
    std::queue<PajeType*> discovered;
    discovered.push(this->rootEntityType());
    while (!discovered.empty()) {
        PajeType* type = discovered.front();
        discovered.pop();
        auto keyValuePair = types->find(type->depth());
        if (keyValuePair == types->end()) {
            std::vector<PajeType*>* typeV = new std::vector<PajeType*>;
            typeV->push_back(type);
            types->insert({type->depth(), *typeV});
        }
        else {
            (keyValuePair->second).push_back(type);
        }
        if (type->nature() == PAJE_ContainerType) {
            for (auto &child: (dynamic_cast<PajeContainerType*>(type))->children())
                discovered.push(child.second);
        }
    }
    return *types;
}
