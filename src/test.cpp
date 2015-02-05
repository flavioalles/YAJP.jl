/* test.cpp */

#include <boost/filesystem.hpp>
#include <iostream>
#include <string>
#include <vector>
#include "PajeContainer.h"
#include "PajeUnity.h"
#include "MiscUtils.h"

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
    // play with PajeComponent
    // get containers
    std::vector<PajeContainer*> containers = pajeTrace->enumeratorOfContainersInContainer(pajeTrace->rootInstance());
    // iterate over them
    std::vector<PajeContainer*>::iterator containersIt;
    for (containersIt = containers.begin(); containersIt != containers.end(); containersIt++) {
        std::vector<std::string> containerDescription = MiscUtils::splitString((*containersIt)->description(), ',');
        std::vector<std::string>::iterator contDescriptionIt;
        for (contDescriptionIt = containerDescription.begin(); contDescriptionIt != containerDescription.end(); contDescriptionIt++)
            std::cout << *contDescriptionIt << " ";
        std::cout << std::endl;
        // iterate over container's children
        std::vector<PajeContainer*> children = (*containersIt)->getChildren();
        std::vector<PajeContainer*>::iterator childrenIt;
        for (childrenIt = children.begin(); childrenIt != children.end(); childrenIt++) {
            std::vector<std::string> childDescription = MiscUtils::splitString((*childrenIt)->description(), ',');
            std::vector<std::string>::iterator childDescriptionIt; 
            for (childDescriptionIt = childDescription.begin(); childDescriptionIt != childDescription.end(); childDescriptionIt++)
                std::cout << *childDescriptionIt << " ";
            std::cout << std::endl;
        }
        std::cout << std::endl;
    }
    return 0;
}
