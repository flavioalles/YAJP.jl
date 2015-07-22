libyaros:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.so *.o -lstdc++ -lpaje -lyaml-cpp
	rm -f *.o
libyaros-osx:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.dylib *.o -lstdc++ -lpaje
	rm -f *.o
explore:
	install -d bin
	clang -std=c++11 -O3 -o bin/explore src/app/explore.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
	install -d ${HOME}/bin
	install bin/explore ${HOME}/bin
kmeans:
	install -d bin
	clang -std=c++11 -O3 -o bin/kmeans src/app/kmeans.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem -lyaml-cpp
	install -d ${HOME}/bin
	install bin/kmeans ${HOME}/bin
plot:
	install -d ${HOME}/bin
	install src/app/plot.py ${HOME}/bin
topology:
	install -d bin
	clang -std=c++11 -O3 -o bin/topology src/app/topology.cpp -L${PWD}/lib -lstdc++ -lyaros -lpaje -lboost_system -lboost_filesystem
	install -d ${HOME}/bin
	install bin/topology ${HOME}/bin
