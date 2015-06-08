test:
	clang -std=c++11 -o tests/bin/yaros tests/test.cpp src/*.cpp -lstdc++ -lpaje -lboost_system -lboost_filesystem
	install -d $(HOME)/bin
	install tests/bin/yaros $(HOME)/bin
