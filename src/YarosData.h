#ifndef YAROS_DATA_H
#define YAROS_DATA_H
#include <PajeContainer.h>

class YarosData : public PajeContainer {
public:
    YarosData(const PajeContainer&);
    ~YarosData();
    YarosData() = delete;
    YarosData(const YarosData&) = delete;
    YarosData& operator=(const YarosData&) = delete; 
};
#endif
