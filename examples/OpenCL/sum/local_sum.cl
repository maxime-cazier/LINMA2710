// Inspired from https://github.com/JuliaGPU/OpenCL.jl/blob/master/src/mapreduce.jl

//codesnippet
__kernel void local_sum(__local float* shared)
{
  int items = get_local_size(0);
  int item = get_local_id(0);
  int index = 0, stride = 1;
  float other_val = 0;
  while (stride < items) {
    barrier(CLK_LOCAL_MEM_FENCE);
    index = 2 * stride * item;
    if (index < items) {
      other_val = 0;
      if (index + stride < items)
        other_val = shared[index+stride];
      shared[index] = shared[index] + other_val;
    }
    stride *= 2;
  }
}

__kernel void sum(__global float* glob, __local float* shared, __global float *result) {
  int item = get_local_id(0);
  shared[item] = glob[item];
  local_sum(shared);
  if (item == 0)
    *result = shared[item];
}
//codesnippet
