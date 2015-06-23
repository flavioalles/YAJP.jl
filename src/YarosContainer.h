#ifndef YAROS_CONTAINER_H
#define YAROS_CONTAINER_H
#include <PajeContainer.h>
#include <PajeException.h>
#include "YarosData.h"

class YarosContainer : public PajeContainer {
public:
    YarosContainer(const PajeContainer&);
    ~YarosContainer();
    YarosContainer() = delete;
    YarosContainer(const YarosContainer&) = delete;
    YarosContainer& operator=(const YarosContainer&) = delete; 
    std::vector<YarosData*>& getData(PajeType* type);
};
#endif
