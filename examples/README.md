# Profiling with `tau2`

## Installing `tau2`

The software is not available on the clusters so you cannot just load them with `module load`, you will need to install it from source.
First clone it:
```sh
$ git clone https://github.com/UO-OACISS/tau2.git
```
To configure, it is important to read the [GPU-specific instructions](https://github.com/UO-OACISS/tau2/blob/master/README.gpu) in order for it to catch OpenCL-specific commands.
You need to pass a folder to `-lopencl` where [it should find `include/CL/cl.h` and `lib/libOpenCL.so`](https://github.com/UO-OACISS/tau2/blob/master/configure#L3360-L3403).
In my local Linux computer, I can simply do
```sh
[local computer]$ ./configure -opencl=/usr
```
On the manneback cluster, we will use the OpenCL library that comes with CUDA. To see where it is located, we can see `Lmod`:
```sh
[blegat@mb-icg102 usr]$ module show CUDA
...
prepend_path("CMAKE_PREFIX_PATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1")
prepend_path("CPATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/include")
prepend_path("CPATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/extras/CUPTI/include")
prepend_path("CPATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/nvvm/include")
prepend_path("LD_LIBRARY_PATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/lib")
prepend_path("LD_LIBRARY_PATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/extras/CUPTI/lib64")
prepend_path("LD_LIBRARY_PATH","/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/nvvm/lib64")
```
We see that it is under `/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1`. Let's see where OpenCL is:
```sh
[blegat@mbackf1 tau2]$ find /opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/ -name cl.h
/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux/include/CL/cl.h
[blegat@mbackf1 tau2]$ find /opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/ -name libOpenCL.so
/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux/lib/libOpenCL.so
```
Seems like `/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux` is a perfect fit so we can configure with:
```sh
[blegat@mbackf1 tau2]$ ./configure -opencl=/opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux/
...
Looking for libOpenCL.so in /opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux/
found /opt/sw/arch/easybuild/2023b/software/CUDA/12.1.1/targets/x86_64-linux/lib/libOpenCL.so
...
```
It worked! Let's use `make` now and then check where the binaries are stored:
```sh
[blegat@mbackf1 tau2]$ make
```
If we try `tau_exec` not it won't work because the binary is inside a directory that is not listed as one of the directories where the shell looks for binaries
```sh
[blegat@mbackf1 tau2]$ tau_exec
-bash: tau_exec: command not found
[blegat@mbackf1 tau2]$ find . -name tau_exec
./x86_64/bin/tau_exec
./tools/src/tau_exec
```
Let's just add it to this list (this assumes that you are at the root of the `tau2` directory where you did `./configure` and `make`, otherwise `pwd` won't give the correct value).
```sh
[blegat@mbackf1 tau2]$ PATH=$(pwd)/tools/src/tau_exec:$PATH
[blegat@mbackf1 tau2]$ tau_exec

Usage: tau_exec [options] [--] <exe> <exe options>
...
```
This `PATH` environment is only updated for this shell session. In order to apply everytime to lauch a new ssh connection, add it to you `.bashrc` with.
```sh
[blegat@mbackf1 tau2]$ echo "export PATH=$(pwd)/x86_64/bin:\$PATH" >> ~/.bashrc
```
