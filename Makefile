test:
	clang -std=c++11 -o yaros tests/test.cpp src/*.cpp -lstdc++ -lpaje -lboost_system -lboost_filesystem
