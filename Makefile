gcc-ubuntu:
	g++ -std=c++11 -Isrc/libpaje -o bin/test src/test.cpp src/MiscUtils.cpp -Llib -lpaje -lboost_system -lboost_filesystem
gcc-osx:
	g++ -std=c++11 -o bin/test src/test.cpp src/MiscUtils.cpp -lpaje -lboost_system -lboost_filesystem
clang-osx:
	# Not Working
	clang -std=c++11 -o bin/test src/test.cpp src/MiscUtils.cpp -lpaje -lboost_system -lboost_filesystem
