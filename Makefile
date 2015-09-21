libyaros:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.so *.o -lstdc++ -lpaje -lyaml-cpp
	rm -f *.o
libyaros-osx:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.dylib *.o -lstdc++ -lpaje -lyaml-cpp
	rm -f *.o
dump:
	install -d bin
	clang -std=c++11 -o bin/yaros-dump src/app/dump.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem -lyaml-cpp
explore:
	install -d bin
	clang -std=c++11 -O3 -o bin/yaros-explore src/app/explore.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
kmeans:
	install -d bin
	clang -std=c++11 -O3 -o bin/yaros-kmeans src/app/kmeans.cpp -L${PWD}/lib -lstdc++ -lm -lyaros -lpaje -lboost_system -lboost_filesystem -lyaml-cpp
topology:
	install -d bin
	clang -std=c++11 -O3 -o bin/yaros-topology src/app/topology.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
install:
	install -C bin/* /usr/local/bin
	install -C lib/* /usr/local/lib
	install -d /usr/local/include/yaros
	install -C src/lib/*.h /usr/local/include/yaros
