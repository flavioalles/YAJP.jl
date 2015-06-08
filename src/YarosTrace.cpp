#include "YarosTrace.h"
#include <queue>
#include <string>
#include <vector>

YarosTrace::YarosTrace(const std::string tracefile): PajeUnity(false, false, tracefile, -1, 1, nullptr) {
}

YarosTrace::~YarosTrace() {
}

// std::vector<...> or std::list<...>?
std::vector<std::string*>& YarosTrace::getTopology() {
    std::vector<std::string*> *descriptions = new std::vector<std::string*>();
    std::queue<PajeContainer*> discovered;
    discovered.push(this->rootInstance());
    while (!discovered.empty()) {
        PajeContainer* container = discovered.front();
        discovered.pop();
        descriptions->push_back(new std::string("[" + std::to_string(container->depth) + "] " + container->description() + " (" + std::to_string((container->getChildren()).size()) + ")"));
        std::vector<PajeContainer*> children = container->getChildren();
        std::vector<PajeContainer*>::iterator childrenIt;
        for (childrenIt = children.begin(); childrenIt != children.end(); childrenIt++)
            discovered.push(*childrenIt);
    }
    return *descriptions;
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
