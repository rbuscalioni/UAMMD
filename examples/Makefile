
FILE=benchmark.cu

CPU= -O3 -funroll-loops -ffinite-math-only -fno-signaling-nans -fno-math-errno -fno-signed-zeros -frename-registers -march=native -fPIC

DEBUG= -O3
#DOUBLE_PRECISION=-DDOUBLE_PRECISION

BASIC_LINE= nvcc  $(DOUBLE_PRECISION) -lineinfo -I  ../src  -O3 -ccbin="g++" -Xcompiler="$(CPU)"  -src-in-ptx -gencode arch=compute_52,code=sm_52 -x cu -std=c++11 --expt-relaxed-constexpr
all:
	$(BASIC_LINE)  $(FILE)

lj:
	$(BASIC_LINE) LJ.cu

bdhi:
	$(BASIC_LINE) BDHI.cu -llapacke -lcblas -lcurand -lcublas -lcusolver -lcufft -lnvToolsExt

pse:
	$(BASIC_LINE) PSE.cu -lcurand -lcublas -lcusolver -llapacke -lcblas -lcufft -lcudart -lnvToolsExt

bd:
	$(BASIC_LINE) BD.cu -lcurand

bonds:
	$(BASIC_LINE)  Bonds.cu -lcurand 

sph:
	$(BASIC_LINE) SPH_test.cu -lcurand
