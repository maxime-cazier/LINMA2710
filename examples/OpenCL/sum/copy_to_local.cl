//codesnippet
__kernel void copy_to_local(__global float* glob, __local float* shared) {
  int item = get_local_id(0);
  shared[item] = glob[item];
}
//codesnippet
