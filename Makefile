lib:
	clang -c -std=c++11 -fpic src/lib/*.cpp
	clang -shared -o libyaros.so *.o
	rm --force *.o
clean:
	rm --force libyaros.so
