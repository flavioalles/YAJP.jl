libyaros:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.so *.o -lstdc++ -lpaje
	rm -f *.o
clean:
	rm -f lib/libyaros.so
