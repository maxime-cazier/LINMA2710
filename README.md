# LINMA2710 Scientific Computing

[<img src="https://upload.wikimedia.org/wikipedia/commons/7/72/UCLouvain_logo.svg" height="20"/>](https://uclouvain.be/en-cours-2024-linma2710)
[<img src="https://upload.wikimedia.org/wikipedia/commons/c/c6/Moodle-logo.svg" height="16"/>](https://moodle.uclouvain.be/enrol/index.php?id=2951)

This repository contains different resources for the LINMA2710 courses given at UCLouvain.

You find below some help on connecting to the CECI cluster:

## CECI cluster

In order to use the CECI clusters, you need a CECI account.
If you don't already have an account (if you don't know whether you have an account, chances are you don't have one), first [create one](https://login.ceci-hpc.be/init/).
You will receive an email, follow the link in the email and in the field labelled "Email of Supervising Professor", enter `benoit.legat@uclouvain.be`.
Follow the steps detailed [here](https://support.ceci-hpc.be/doc/_contents/QuickStart/ConnectingToTheClusters/index.html) in order to download your private key, create the corresponding public key and create the file `.ssh/config`.

Follow [this guide](https://support.ceci-hpc.be/doc/_contents/ManagingFiles/TransferringFilesEffectively.html) to copy the notebook as well as the three scripts `install.sh`, `load.sh`, `notebook.sh` and `submit.sh` from your computer to the cluster. For instance, with `scp` you can copy the notebook from your computer with:
```sh
(your computer) $ scp gan.ipynb manneback:.
```
and copy the scripts to the cluster with:
```sh
(your computer) $ scp install.sh load.sh notebook.sh submit.sh manneback:.
```

You should now be able to connect to the manneback cluster with
```sh
(your computer) $ ssh manneback
```

Start by installing the dependencies using (you should do this only once, not everytime you connect to the cluster):
```sh
(manneback cluster) $ bash install.sh
```

In order to provide more resources to JupyterLab, [submit the job `bash notebook.sh` with Slurm](https://support.ceci-hpc.be/doc/_contents/QuickStart/SubmittingJobs/SlurmTutorial.html).
The file `submit.sh` gives an example of submission script to use to request a GPU (see [here](https://www.ceci-hpc.be/scriptgen.html) for a helper for writing your own submission script). You can use it with
```sh
(manneback cluster) $ sbatch submit.sh
```
The output produced by the job is written in the file `slurm-<JOBID>.out` where `<JOBID>` is the job id listed in the `JOBID` column of the table outputted by
```sh
(manneback cluster) $ squeue --me
```
At the end of the file, you should copy-paste the url given by Jupyter as you will need you give this url (appended with `/24`) to `sshuttle` in the next step.
Now, follow the instructions [here](https://support.ceci-hpc.be/doc/_contents/UsingSoftwareAndLibraries/Jupyter/index.html#connect-to-the-jupyterhub-interface) to use this instance of JupyterLab from a web browser of your computer.

Note that if you do `(manneback cluster) $ bash notebook.sh` directly without using `sbatch` or `srun`, the notebook will run on the *login node* which has limited resources as it is only meant for you to connect and send jobs via Slurm that are executed on *compute nodes*, you will also not have any GPU on the login node.

## Julia


**Do not** use `module load CUDA`. This command uses [Lmod](https://github.com/TACC/Lmod) to set `LD_LIBRARY_PATH` (as detailed in the output of `module show CUDA`) [which is discouraged](https://github.com/JuliaGPU/CUDA.jl/issues/1755).

Running Julia interactively on a compute node is as simple as running `$ srun --pty julia`.
If `CUDA` was precompiles on a login node, you will see the error
```julia
julia> using CUDA
┌ Error: CUDA.jl could not find an appropriate CUDA runtime to use.
│ 
│ CUDA.jl's JLLs were precompiled without an NVIDIA driver present.
│ This can happen when installing CUDA.jl on an HPC log-in node,
│ or in a container. In that case, you need to specify which CUDA
│ version to use at run time by calling `CUDA.set_runtime_version!`
│ or provisioning the preference it sets at compile time.
│ 
│ If you are not running in a container or on an HPC log-in node,
│ try re-compiling the CUDA runtime JLL and re-loading CUDA.jl:
│      pkg = Base.PkgId(Base.UUID("76a88914-d11a-5bdc-97e0-2f5a05c973a2"),
│                       "CUDA_Runtime_jll")
│      Base.compilecache(pkg)
│      # re-start Julia and re-load CUDA.jl
│ 
│ For more details, refer to the CUDA.jl documentation at
│ https://cuda.juliagpu.org/stable/installation/overview/
└ @ CUDA ~/.julia/packages/CUDA/1kIOw/src/initialization.jl:118
```
Just copy-paste these lines on the REPL to re-compile CUDA.jl and then exit it and restart a new Julia session with `srun` again.
If you still get the error, leave the REPL, then run the following (replacing `v1.11` by your Julia version of course):
```sh
(manneback cluster) $ rm -r ~/.julia/compiled/v1.11/CUDA*
```
New, start a new Julia session with `srun` and `using CUDA` should not error anymore.

See [here](https://enccs.github.io/julia-for-hpc/hpc-cluster/) for additional information.
