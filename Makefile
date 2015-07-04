libyaros:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.so *.o -lstdc++ -lpaje
	rm -f *.o
libyaros-osx:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.dylib *.o -lstdc++ -lpaje
	rm -f *.o
kmeans:
	install -d bin
	clang -std=c++11 -O3 -o bin/kmeans src/app/kmeans.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
	install -d ${HOME}/bin
	install bin/kmeans ${HOME}/bin
topology:
	install -d bin
	clang -std=c++11 -O3 -o bin/topology src/app/topology.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
	install -d ${HOME}/bin
	install bin/topology ${HOME}/bin
