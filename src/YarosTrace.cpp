/* YarosTrace.cpp */
#include "YarosTrace.h"

YarosTrace::YarosTrace(std::string tracefile) : pajeTrace{new PajeUnity(false, false, tracefile, -1, 0)} {

}

YarosTrace::~YarosTrace() {
    delete pajeTrace;
}
