Example from [here](https://github.com/wolfpld/tracy/tree/master/examples/OpenCLVectorAdd) that was slightly modified so that it works outside the `cmake` infrastructure of `tracy`

First install the *Tracy profiler* (aka *server*) and launch it.

The Tracy profiler displays profiling info emitted from a *Tracy client*.
For the application you want to profile to serve as Tracy client, you need to embed the Tracy client
in your application.
The source code of the Tracy client is in the `public` subfolder of the `tracy` repository so let's clone it:
Run the following to clone `tracy` next to the `LINMA2710` folder:
```sh
$ git clone https://github.com/wolfpld/tracy.git
```
You can also clone it elsewhere but then you need to modify the `TRACY_DIR` variable in this `Makefile`.
Now, check the version you have on the Tracy server (the GUI you have launched), say it is `v0.11.1`.
You now need to checkout the corresponding tag in the `tracy` git repo to have the good version
of the Tracy client.
```sh
$ cd tracy
$ git checkout v0.11.1
```

Then, go back in this folder and do
```sh
$ make
```
Now, click on "Connect" on the tracy application. Then run:
```sh
$ ./OpenCLVectorAdd
```
You should now see the trace in the tracy application.

## Profiling a Tracy client running on the server

> [!NOTE]
> Tracy supports 3 GUI backends : [GLFW](https://www.glfw.org/), [Emscripten](https://emscripten.org/) and [Wayland](https://wayland.freedesktop.org/).
> Manneback does not have GLFW nor Emscripten nor [xkbcommon](https://xkbcommon.org/) which is needed by Wayland.
> For this reason, we will just install the Tracy server on our own computer and **not** run in on the cluser through `ssh -X`.

Clone `tracy` on the cluster and checkout the right tag like recommended above.
Now, connect to a compute node and take note of its ip
```sh
[blegat@mbackf2 tracy]$ salloc
salloc: Pending job allocation 57562683
salloc: job 57562683 queued and waiting for resources
salloc: job 57562683 has been allocated resources
salloc: Granted job allocation 57562683
salloc: Waiting for resource configuration
salloc: Nodes mb-sky015 are ready for job
[blegat@mb-sky015 tracy]$ hostname -i
10.33.204.15
```
Now, use the following to allow the server running on your local computer to communicate with the client running on the compute node of the cluster:
```sh
[local computer]$ sshuttle -r manneback 10.33.204.15/16 # /!\ modify it with "the output of `hostname -i` on the compute node"/16
```
Now, run the
```sh
[blegat@mb-sky015 tracy]$ ./OpenCLVectorAdd
Waiting 10 seconds to give you time to start the Tracy server...
9 seconds left...
8 seconds left...
```
Quick! Launch the Tracy server, enter the ip of the server and then click on "Connect" before the timer expires or you'll miss the profiling information of the start of the program (or the whole of it since this example is quite small).
You can also directly launch the profiler with the ip address:
```sh
./build/tracy-profiler -a 10.33.204.15 # /!\ modify it with "the output of `hostname -i` on the compute node"
```
