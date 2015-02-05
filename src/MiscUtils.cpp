/* MiscUtils.cpp */

#include "MiscUtils.h"

std::vector<std::string> MiscUtils::splitString(const std::string &str, const char &delim) {
    std::vector<std::string> vec;
    std::string::const_iterator stringIt;
    size_t pos = 0;
    size_t len = 0;
    for (stringIt = str.begin(); stringIt != str.end(); stringIt++) {
        if (*stringIt == delim) {
            std::string sub = str.substr(pos, len);
            // remove whitespace
            if (sub.front() == ' ')
                sub.erase(0, 1);
            if (sub.back() == ' ')
                sub.pop_back();
            vec.push_back(sub);
            pos += len + 1;
            len = 0;
        } else {
            len++;
        }
    }
    // push last string
    std::string sub = str.substr(pos, len);
    if (sub.front() == ' ')
        sub.erase(0, 1);
    if (sub.back() == ' ')
        sub.pop_back();
    vec.push_back(sub);
    return vec;
}
