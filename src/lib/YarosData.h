#ifndef YAROS_DATA_H
#define YAROS_DATA_H
#include <stdexcept>
#include <string>

class YarosData {
public:
    virtual std::string getName();
    virtual std::string getType();
    virtual double getStart();
    virtual double getEnd();
    virtual std::string dumpData();
    virtual ~YarosData() {};
};

class YarosEvent : public YarosData {
private:
    std::string name;
    std::string type;
    double start;
public:
    YarosEvent(std::string name, std::string type, double start);
    ~YarosEvent();
    YarosEvent() = delete;
    YarosEvent(const YarosEvent&) = delete;
    YarosEvent& operator=(const YarosEvent&) = delete;
    std::string getName();
    std::string getType();
    double getStart();
    std::string dumpData();
};

class YarosLink : public YarosData {
private:
    std::string name;
    std::string type;
    double start;
    double end;
    std::string startContainer;
    std::string endContainer;
public:
    YarosLink(std::string name, std::string type, double start, double end, std::string startContainer);
    YarosLink(std::string name, std::string type, double start, double end, std::string startContainer, std::string endContainer);
    ~YarosLink();
    YarosLink() = delete;
    YarosLink(const YarosLink&) = delete;
    YarosLink& operator=(const YarosLink&) = delete;
    std::string getName();
    std::string getType();
    double getStart();
    double getEnd();
    std::string getStartContainer();
    std::string getEndContainer();
    std::string dumpData();
};

class YarosState : public YarosData {
private:
    std::string name;
    std::string type;
    double start;
    double end;
    int imbrication;
public:
    YarosState(std::string name, std::string type, double start, double end, int imbrication);
    ~YarosState();
    YarosState() = delete;
    YarosState(const YarosState&) = delete;
    YarosState& operator=(const YarosState&) = delete;
    std::string getName();
    std::string getType();
    double getStart();
    double getEnd();
    int getImbrication();
    std::string dumpData();
};

class YarosVariable : public YarosData {
private:
    std::string type;
    double start;
    double end;
    double value;
public:
    YarosVariable(std::string type, double start, double end, double value);
    ~YarosVariable();
    YarosVariable() = delete;
    YarosVariable(const YarosVariable&) = delete;
    YarosVariable& operator=(const YarosVariable&) = delete;
    std::string getType();
    double getStart();
    double getEnd();
    double getValue();
    std::string dumpData();
};
#endif
