/* YarosTrace.cpp */
#include <queue>
#include <vector>
#include "YarosTmp.h"
#include "YarosTrace.h"

YarosTrace::YarosTrace(const std::string tracefile) : pajeTrace{new PajeUnity(false, false, tracefile, -1, 0)} {
}

YarosTrace::~YarosTrace() {
    delete pajeTrace;
}

void YarosTrace::dumptrace() const {
    // let Q be a queue
    std::queue<PajeContainer*> containerqueue;
    // Q.push(root)
    containerqueue.push(this->pajeTrace->rootInstance());
    while (!containerqueue.empty()) {
        // v ← Q.pop()
        PajeContainer* pajecontainer = containerqueue.front();
        containerqueue.pop();
        // dump container
        YarosTmp::dumpcontainer(pajecontainer);
        // for all edges from v to w in G.adjacentEdges(v) do
        std::vector<PajeContainer*> children = pajecontainer->getChildren();
        for (auto& child: pajecontainer->getChildren())
            // Q.push(w)
            containerqueue.push(child);
    }
}
