/* YarosTrace.cpp */
#include "YarosTrace.h"

YarosTrace::YarosTrace(const std::string tracefile) : pajeTrace{new PajeUnity(false, false, tracefile, -1, 0)} {
}

YarosTrace::~YarosTrace() {
    try {
        delete pajeTrace;
    }
    catch (...) {
        // TODO: log it
        std::abort();
    }
}
