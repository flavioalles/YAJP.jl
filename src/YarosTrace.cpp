#include "YarosTrace.h"
#include <map>
#include <queue>
#include <string>
#include <vector>

YarosTrace::YarosTrace(const std::string tracefile): PajeUnity(false, false, tracefile, -1, 1, nullptr) {
}

YarosTrace::~YarosTrace() {
}

std::map<int,std::vector<PajeContainer*>>& YarosTrace::getContainerTopology() {
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

// std::vector<...> or std::list<...>?
std::vector<PajeContainer*>& YarosTrace::getContainersOfDepth(int depth) {
    std::vector<PajeContainer*> *containers = new std::vector<PajeContainer*>();
    if (depth >= 0) {
        std::queue<PajeContainer*> discovered;
        discovered.push(this->rootInstance());
        while (!discovered.empty()) {
            PajeContainer* container = discovered.front();
            discovered.pop();
            if (container->depth == depth)
                containers->push_back(container);
            std::vector<PajeContainer*> children = container->getChildren();
            std::vector<PajeContainer*>::iterator childrenIt;
            for (childrenIt = children.begin(); childrenIt != children.end(); childrenIt++)
                discovered.push(*childrenIt);
        }
    }
    return *containers;
}

// std::vector<...> or std::list<...>?
std::vector<PajeContainer*>& YarosTrace::getContainersOfName(std::string name) {
    std::vector<PajeContainer*> *containers = new std::vector<PajeContainer*>();
    if (!name.empty()) {
        std::queue<PajeContainer*> discovered;
        discovered.push(this->rootInstance());
        while (!discovered.empty()) {
            PajeContainer* container = discovered.front();
            discovered.pop();
            if (container->type()->name() == name)
                containers->push_back(container);
            std::vector<PajeContainer*> children = container->getChildren();
            std::vector<PajeContainer*>::iterator childrenIt;
            for (childrenIt = children.begin(); childrenIt != children.end(); childrenIt++)
                discovered.push(*childrenIt);
        }
    }
    return *containers;
}
