#ifndef YAROS_DATA_H
#define YAROS_DATA_H
#include <stdexcept>

class YarosData {
public:
    virtual std::string getName();
    virtual double getStart();
    virtual double getEnd();
    virtual ~YarosData() {};
};

class YarosEvent : public YarosData {
private:
    std::string name;
    double start;
public:
    YarosEvent(std::string name, double start);
    ~YarosEvent();
    YarosEvent() = delete;
    YarosEvent(const YarosEvent&) = delete;
    YarosEvent& operator=(const YarosEvent&) = delete;
    std::string getName();
    double getStart();
};

class YarosState : public YarosData {
private:
    std::string name;
    double start;
    double end;
public:
    YarosState(std::string name, double start, double end);
    ~YarosState();
    YarosState() = delete;
    YarosState(const YarosState&) = delete;
    YarosState& operator=(const YarosState&) = delete;
    std::string getName();
    double getStart();
    double getEnd();
};
#endif
