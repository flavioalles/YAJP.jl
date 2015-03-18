/* YarosTmp.cpp */
#include <iostream>
#include "YarosTmp.h"

PajeTypeNature YarosTmp::natureTypes[] = { 
    PAJE_EventType,
    PAJE_LinkType,
    PAJE_StateType,
    PAJE_VariableType,
    PAJE_UndefinedType
};

void YarosTmp::dumpcontainer(const PajeContainer* pajecontainer) {
    std::cout << pajecontainer->description() << std::endl;
    for (auto& nature: natureTypes)
        for (auto& entity: pajecontainer->getEntitiesOfNature(nature))
            std::cout << entity->description() << std::endl;
    std::cout << std::endl;
}
