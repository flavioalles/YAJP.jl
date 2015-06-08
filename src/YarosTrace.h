#ifndef YAROS_TRACE_H
#define YAROS_TRACE_H
#include <PajeContainer.h>
#include <PajeUnity.h>

class YarosTrace : public PajeUnity {
public:
    YarosTrace(const std::string tracefile);
    ~YarosTrace();
    YarosTrace() = delete;
    YarosTrace(const YarosTrace&) = delete;
    YarosTrace& operator=(const YarosTrace&) = delete;
    std::vector<std::string*>& getTopology();
    std::vector<PajeContainer*>& getContainersOfDepth(int depth);
    std::vector<PajeContainer*>& getContainersOfName(std::string name);
};
#endif
