#include "YarosData.h"

/* YarosData */
std::string YarosData::getName() {
    throw std::runtime_error("Undefined for the derived class");
}

double YarosData::getStart() {
    throw std::runtime_error("Undefined for the derived class");
}

double YarosData::getEnd() {
    throw std::runtime_error("Undefined for the derived class");
}

std::string YarosData::dumpData() {
    throw std::runtime_error("Undefined for the derived class");
}

/* YarosEvent */
YarosEvent::YarosEvent(std::string name, double start) {
    this->name = name;
    this->start = start;
}

YarosEvent::~YarosEvent() {
}

std::string YarosEvent::getName() {
    return this->name;
}

double YarosEvent::getStart() {
    return this->start;
}

std::string YarosEvent::dumpData() {
    return this->name + " " + std::to_string(this->start);
}

/* YarosState */
YarosState::YarosState(std::string name, double start, double end) {
    this->name = name;
    this->start = start;
    this->end = end;
}

YarosState::~YarosState() {
}

std::string YarosState::getName() {
    return this->name;
}

double YarosState::getStart() {
    return this->start;
}

double YarosState::getEnd() {
    return this->end;
}

std::string YarosState::dumpData() {
    return this->name + " " + std::to_string(this->start) + " " + std::to_string(this->end);
}
