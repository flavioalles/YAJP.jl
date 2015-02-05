test:
	g++ -std=c++11 -Isrc/libpaje -o bin/test src/test.cpp src/MiscUtils.cpp -Llib -lpaje -lboost_system -lboost_filesystem
