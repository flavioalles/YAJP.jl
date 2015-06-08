#include "YarosTrace.h"

YarosTrace::YarosTrace(const std::string tracefile): pajeTrace{new PajeUnity(false, false, tracefile, -1, 1, nullptr)} {
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
