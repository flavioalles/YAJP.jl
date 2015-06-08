clang:
	clang -std=c++11 -o yaros src/*.cpp -lstdc++ -lpaje -lboost_system -lboost_filesystem
	install -d $(HOME)/bin
	install yaros $(HOME)/bin
gcc:
	g++ -std=c++11 -o yaros src/*.cpp -lpaje -lboost_system -lboost_filesystem
