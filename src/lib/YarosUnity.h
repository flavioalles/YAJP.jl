#ifndef YAROS_UNITY_H
#define YAROS_UNITY_H
#include <PajeContainer.h>
#include <PajeType.h>
#include <PajeUnity.h>

class YarosUnity : public PajeUnity {
public:
    YarosUnity(const std::string tracefile);
    ~YarosUnity();
    YarosUnity() = delete;
    YarosUnity(const YarosUnity&) = delete;
    YarosUnity& operator=(const YarosUnity&) = delete;
    std::map<int,std::vector<PajeContainer*>>& getContainerTopology();
    std::vector<PajeContainer*>& getContainersOfDepth(int depth);
    std::vector<PajeContainer*>& getContainersOfType(std::string name);
    std::map<int,std::vector<PajeType*>>& getTypeTopology();
};
#endif
