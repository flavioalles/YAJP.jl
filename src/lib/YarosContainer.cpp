#include "YarosContainer.h"

YarosContainer::YarosContainer(const PajeContainer& container): PajeContainer(container) {
}

YarosContainer::~YarosContainer() {
}

std::vector<YarosData*>& YarosContainer::getData() {
    std::vector<YarosData*>* data = new std::vector<YarosData*>;
    YarosData* yd;
    for (auto& t: this->getAllEntities()) {
        for (auto& e: t.second) {
            switch (e->type()->nature()) {
                case PAJE_EventType:
                    yd = new YarosEvent(e->value()->name(), e->startTime());
                    break;
                case PAJE_LinkType:
                    if (!e->endContainer())
                        yd = new YarosLink(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->startContainer()->name(), e->endContainer()->name());
                    else
                        yd = new YarosLink(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->startContainer()->name());
                    break;
                case PAJE_StateType:
                    yd = new YarosState(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->imbricationLevel());
                    break;
                case PAJE_VariableType:
                default:
                    throw PajeTypeException("Unknown PajeType.");
            }
            data->push_back(yd);
        }
    }
    return *data;
}

std::vector<YarosData*>& YarosContainer::getData(PajeType* type) {
    std::vector<YarosData*>* data = new std::vector<YarosData*>;
    YarosData* yd;
    for (auto& e: this->enumeratorOfEntitiesTyped(type)) {
        switch (e->type()->nature()) {
            case PAJE_EventType:
                yd = new YarosEvent(e->value()->name(), e->startTime());
                break;
            case PAJE_LinkType:
                if (!e->endContainer())
                    yd = new YarosLink(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->startContainer()->name(), e->endContainer()->name());
                else
                    yd = new YarosLink(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->startContainer()->name());
                break;
            case PAJE_StateType:
                yd = new YarosState(e->value()->name(), e->type()->name(), e->startTime(), e->endTime(), e->imbricationLevel());
                break;
            case PAJE_VariableType:
            default:
                throw PajeTypeException("Unknown PajeType.");
        }
        data->push_back(yd);
    }
    return *data;
}
