/* test.cpp */

#include <boost/filesystem.hpp>
#include <iostream>
#include <string>
#include <vector>
#include <PajeType.h>
#include <PajeUnity.h>

namespace paje {
    PajeTypeNature natureTypes[] = {
        PAJE_EventType,
        PAJE_LinkType,
        PAJE_StateType,
        PAJE_VariableType,
        PAJE_UndefinedType
    };
}

bool dumpEntitiesSizeMap(std::map<PajeTypeNature,int> entMap);

int main(int argc, char *argv[]) {
    // #arguments ok?
    if (argc != 2) {
        std::cout << "Wrong usage." << std::endl;
        return 1;
    }
    // argv[1] is an existent file?
    if (!boost::filesystem::exists(argv[1])) {
        std::cout << "Inexistent trace file." << std::endl;
        return 2;
    }
    // instatiate PajeUnity
    PajeUnity *pajeTrace = new PajeUnity(false, false, argv[1], -1, 0);
    double start = pajeTrace->startTime();
    double end = pajeTrace->endTime();
    // root
    PajeContainer *rootContainer = pajeTrace->rootInstance();
    std::cout << rootContainer->description() << std::endl;
    // get containers contained by root
    std::vector<PajeContainer*> containers = pajeTrace->enumeratorOfContainersInContainer(rootContainer);
    // get entities by nature
    std::vector<PajeEntity*> ents;
    // map number of entities per PajeTypeNature
    std::map<PajeTypeNature,int> entMap; // map number of entities per PajeTypeNature
    for (auto& nature: paje::natureTypes) {
        ents = rootContainer->getEntitiesOfNature(nature);
        entMap[nature] = ents.size();
    }
    // dump map
    dumpEntitiesSizeMap(entMap);
    // iterate over containers (BFS ou DFS?)
    for (std::vector<PajeContainer*>::iterator contIt = containers.begin(); contIt != containers.end(); contIt++);
    return 0;
}

bool dumpEntitiesSizeMap(std::map<PajeTypeNature,int> entMap) {
    std::map<PajeTypeNature,int>::iterator entMapIt;
    std::string nature;
    for (entMapIt = entMap.begin(); entMapIt != entMap.end(); entMapIt++) {
        switch((*entMapIt).first) {
            case PAJE_EventType:
                nature = "PajeEvent";
                break;
            case PAJE_LinkType:
                nature = "PajeLink";
                break;
            case PAJE_StateType:
                nature = "PajeState";
                break;
            case PAJE_VariableType:
                nature = "PajeVariable";
                break;
            default:
                nature = "Unknown";
        }
        std::cout << nature << ": " << (*entMapIt).second << std::endl;
    }
    return true;
}
