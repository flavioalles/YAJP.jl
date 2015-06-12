#ifndef YAROS_CONTAINER_H
#define YAROS_CONTAINER_H
#include <PajeContainer.h>

class YarosContainer : public PajeContainer {
public:
    YarosContainer(const PajeContainer&);
    ~YarosContainer();
    YarosContainer() = delete;
    YarosContainer(const YarosContainer&) = delete;
    YarosContainer& operator=(const YarosContainer&) = delete; 
};
#endif
