/opt/cuda/nsight_systems/bin/nsys profile --stats=true --trace=nvtx,mpi --mpi-impl=openmpi --force-overwrite=true mpiexec -np 4 ./a.out 100000000 > nsys_profile.output 2>&1
