clang-ubuntu:
	clang -std=c++11 -o bin/yaros src/yaros.cpp src/YarosTrace.cpp -lstdc++ -lpaje -lboost_system -lboost_filesystem
gcc:
	g++ -std=c++11 -o bin/yaros src/yaros.cpp src/YarosTrace.cpp -lpaje -lboost_system -lboost_filesystem
clang-osx:
	# Not Working
	clang -std=c++11 -o bin/yaros src/yaros.cpp src/MiscUtils.cpp -lpaje -lboost_system -lboost_filesystem
