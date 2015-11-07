all: extract_fv

extract_fv : extract_fv.o fisher.o gmm.o stat.o simd_math.o
	g++ -O3 -g -DDEBUG -o extract_fv extract_fv.o fisher.o gmm.o stat.o simd_math.o -Igzstream -Lgzstream -lgzstream -lz

extract_fv.o : extract_fv.cc fisher.h gmm.h gzstream/gzstream.h
	g++ -O3 -g -DDEBUG -c extract_fv.cc

fisher.o : fisher.cxx fisher.h gmm.h simd_math.h
	g++ -O3 -g -DDEBUG -c fisher.cxx

gmm.o : gmm.cxx gmm.h stat.h simd_math.h
	g++ -O3 -g -DDEBUG -c gmm.cxx

stat.o : stat.cxx stat.h
	g++ -O3 -g -DDEBUG -c stat.cxx

simd_math.o: simd_math.cxx simd_math.h
	g++ -O3 -g -DDEBUG -c simd_math.cxx

clean:
	rm *.o extract_fv
