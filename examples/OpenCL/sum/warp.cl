// Inspired from https://github.com/JuliaGPU/OpenCL.jl/blob/master/src/mapreduce.jl

//codesnippet
__kernel void simt_sum(volatile __local float* shared)
{
  int items = get_local_size(0);
  int item = get_local_id(0);
  barrier(CLK_LOCAL_MEM_FENCE);
  if (items >= 64)
    shared[item] += shared[item + 32];
  if (items >= 32)
    shared[item] += shared[item + 16];
  if (items >= 16)
    shared[item] += shared[item + 8];
  if (items >= 8)
    shared[item] += shared[item + 4];
  if (items >= 4)
    shared[item] += shared[item + 2];
  if (items >= 2)
    shared[item] += shared[item + 1];
}
//codesnippet

__kernel void sum(__global float* glob, __local float* shared, __global float *result) {
  int item = get_local_id(0);
  shared[item] = glob[item];
  simt_sum(shared);
  if (item == 0)
    *result = shared[item];
}
