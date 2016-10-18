/*Raul P. Pelaez 2016. Brownian Euler Maruyama integrator GPU kernels and callers

  Functions to integrate movement. The integration is done via a functor wich accesor ()
  takes a thrust::Tuple containing positions, velocities and forces on each particle. 

  Solves the following differential equation:
  X[t+dt] = dt(K·X[t]+D·F[t]) + sqrt(dt)·dW·B
  Being:
  X - Positions
  D - Diffusion matrix
  K - Shear matrix
  dW- Noise vector
  B - sqrt(D)


  TODO:
  100- Benchmark and optimize
*/
#include"utils/helper_math.h"
#include"utils/helper_gpu.cuh"
#include"BrownianEulerMaruyamaGPU.cuh"
#include<thrust/device_ptr.h>
#include<thrust/for_each.h>
#include<thrust/iterator/zip_iterator.h>



using namespace thrust;

#define TPB 128

namespace brownian_euler_maruyama_ns{
  __constant__ Params params;


  void initGPU(Params m_params){

    gpuErrchk(cudaMemcpyToSymbol(params, &m_params, sizeof(Params)));
  }



  /*Integrate the movement*/
  __global__ void integrateGPUD(real4 __restrict__  *pos,
				const real4 __restrict__  *force,
				const real3 __restrict__ *dW){
    uint i = blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=params.N) return;
    /*Half step velocity*/

    real3 *B = params.B;
    real3 *D = params.D;
    real3 *K = params.K;
    real sqrtdt = params.sqrtdt;
    real dt = params.dt; 
    real3 p = make_real3(pos[i]);
    real3 f = make_real3(force[i]);
    // X[t+dt] = dt(K·X[t]+D·F[t]) + sqrt(dt)·dW·B
    p.x =  dt*( dot(K[0],p) +  dot(D[0],f)) + sqrtdt*dot(dW[i],B[0]);
    p.y =  dt*( dot(K[1],p) +  dot(D[1],f)) + sqrtdt*dot(dW[i],B[1]);
    if(params.L.z!=real(0.0))//If 3D
      p.z =  dt*( dot(K[2],p) +  dot(D[2],f)) + sqrtdt*dot(dW[i],B[2]);

    pos[i] += make_real4(p);
  }

  //Update the positions
  void integrateGPU(real4 *pos, real3 *noise, real4 *force,
		    uint N){
    uint nthreads = TPB<N?TPB:N;
    uint nblocks = N/nthreads +  ((N%nthreads!=0)?1:0); 
    integrateGPUD<<<nblocks, nthreads>>>(pos, force, noise);
  }

}
