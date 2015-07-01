libyaros:
	install -d lib
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o lib/libyaros.so *.o
	rm --force *.o
clean:
	rm --force lib/libyaros.so
