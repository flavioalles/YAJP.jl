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

/* YarosLink */
YarosLink::YarosLink(std::string name, std::string type, double start, double end, std::string startContainer) {
    this->name = name;
    this->type = type;
    this->start = start;
    this->end = end;
    this->startContainer = startContainer;
    this->endContainer = std::string();
}

YarosLink::YarosLink(std::string name, std::string type, double start, double end, std::string startContainer, std::string endContainer) {
    this->name = name;
    this->type = type;
    this->start = start;
    this->end = end;
    this->startContainer = startContainer;
    this->endContainer = endContainer;
}

YarosLink::~YarosLink() {
}

std::string YarosLink::getName() {
    return this->name;
}

std::string YarosLink::getType() {
    return this->type;
}

double YarosLink::getStart() {
    return this->start;
}

double YarosLink::getEnd() {
    return this->end;
}

std::string YarosLink::getStartContainer() {
    return this->startContainer;
}

std::string YarosLink::getEndContainer() {
    return this->endContainer;
}

std::string YarosLink::dumpData() {
    if (this->endContainer.empty())
        return this->name + " " + this->type + " " + std::to_string(this->start) + " " + std::to_string(this->end) + " " + this->startContainer;
    else
        return this->name + " " + this->type + " " + std::to_string(this->start) + " " + std::to_string(this->end) + " " + this->startContainer + " " + this->endContainer;
}

/* YarosState */
YarosState::YarosState(std::string name, std::string type, double start, double end, int imbrication) {
    this->name = name;
    this->type = type;
    this->start = start;
    this->end = end;
    this->imbrication = imbrication;
}

YarosState::~YarosState() {
}

std::string YarosState::getName() {
    return this->name;
}

std::string YarosState::getType() {
    return this->type;
}

double YarosState::getStart() {
    return this->start;
}

double YarosState::getEnd() {
    return this->end;
}

int YarosState::getImbrication() {
    return this->imbrication;
}

std::string YarosState::dumpData() {
    return this->name + " " + this->type + " " + std::to_string(this->start) + " " + std::to_string(this->end) + " " + std::to_string(this->imbrication);
}
