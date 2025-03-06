### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 82e1ea5e-f8e0-11ef-0f93-49a66050feaf
import Pkg

# ╔═╡ a55c5090-1455-4fb9-bdb9-a0b9b340b154
Pkg.activate(@__DIR__)

# ╔═╡ 8df4ff2f-d176-4b4e-a525-665b5d07ea52
using MyUtils, PlutoUI, PlutoUI.ExperimentalLayout, Luxor, StaticArrays, BenchmarkTools, PlutoTeachingTools, Markdown

# ╔═╡ 58e12afd-6eb0-4731-bd57-d9ae7ab4e164
header("LINMA2710 - Scientific Computing
Distributed Computing with MPI", "P.-A. Absil and B. Legat")

# ╔═╡ 5a566137-fbd1-45b2-9a55-e4aded366bb3
section("Single Program Multiple Data (SPMD)")

# ╔═╡ a6c337c4-0c81-4463-ad4f-9a4528d953ab
frametitle("Message Passing Interface (MPI)")

# ╔═╡ c04bcc96-e5fe-4d6e-a12e-40dcde58c62e
md"""
* MPI $(img("https://avatars.githubusercontent.com/u/14836989", name = "MPI.png", :height => "20pt")) is an open standard for distributed computing
* [Many implementations](https://www.mpi-forum.org/implementation-status/):
  - MPICH, from $(img("https://upload.wikimedia.org/wikipedia/commons/6/65/ArgonneLaboratoryLogo.png", :height => "20pt")) and $(img("https://upload.wikimedia.org/wikipedia/commons/6/69/Mississippi_State_University_logo.svg", :height => "20pt"))
  - Open MPI $(img("https://upload.wikimedia.org/wikipedia/commons/6/6f/Open_MPI_logo.png", :height => "20pt")) (not to be confused with $(img("https://upload.wikimedia.org/wikipedia/commons/e/eb/OpenMP_logo.png", :width => "45pt")))
  - commercial implementations from $(img("https://upload.wikimedia.org/wikipedia/commons/4/46/Hewlett_Packard_Enterprise_logo.svg", :height => "20pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/6/6a/Intel_logo_%282020%2C_dark_blue%29.svg", :height => "15pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/9/96/Microsoft_logo_%282012%29.svg", :height => "15pt")), and $(img("https://upload.wikimedia.org/wikipedia/commons/9/96/NEC_logo.svg", :height => "15pt"))
"""

# ╔═╡ cf799c26-1cea-4b38-9a15-8497813bd668
frametitle("MPI basics")

# ╔═╡ 6d2b3dbc-0686-49f0-904a-56c3ce63b4dd
hbox([
	Div(md"Initializes MPI, remove `mpiexec`, etc... from `argc` and `argv`."; style = Dict("flex-grow" => "1")),
	c"""
MPI_Init(&argc, &argv)
""",
])

# ╔═╡ b5a3e471-af4a-466f-bbae-96306bcc7563
vbox([
	Div(md"Get the number of processes. `nprocs` is the **same** on all processes."; style = Dict("flex-grow" => "1")),
	c"""
int nprocs;
MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
""",
])

# ╔═╡ d722a86d-6d51-4d91-ac22-53af94c91497
vbox([
	Div(md"Get the id of processes. `procid` is the **different** for **different** processes."; style = Dict("flex-grow" => "1")),
	c"""
int procid;
MPI_Comm_rank(MPI_COMM_WORLD, &procid);
""",
])

# ╔═╡ c3590376-06ed-45a4-af0b-2d46f1a387c8
hbox([
	Div(md"""
Free up memory.
"""; style = Dict("flex-grow" => "1")),
	c"""
MPI_Finalize();
""",
])

# ╔═╡ 52d428d5-cb33-4f2a-89eb-3a8ce3f5bb81
Foldable(
	md"Each process runs the **same** executable. So how can we make them do different things ?",
	md"Even if the code is the same, `MPI_Comm_rank` will give different `procid` so the part of the program depending on the value of `procid` will differ.",
)

# ╔═╡ 273ad3a6-cb32-49bb-8702-fdaf8597e812
frametitle("Different processes may be on the same node")

# ╔═╡ 4e32f7fb-cd5a-4190-9c92-ba4029313475
img("https://raw.githubusercontent.com/VictorEijkhout/TheArtOfHPC_vol2_parallelprogramming/refs/heads/main/booksources/graphics/mpi-node2.png")

# ╔═╡ 82230d6c-25ce-4d12-8842-e0651fc4b143
frametitle("Processor name identifies the node")

# ╔═╡ 7d9ac5f9-39bf-4052-ad8a-ac0fec15c64a
md"""
Processes that are on the same node share the same `processor_name` (the `hostname`).
"""

# ╔═╡ b0ca0392-71b8-4f44-8c6c-0978a02a0e6c
compile_and_run(Example("procname.c"), mpi = true, verbose = 1, show_run_command = true)

# ╔═╡ 21b6133f-db59-4885-9b3d-331c3d6ef306
frametitle("Compiling")

# ╔═╡ 35ba1eea-56ae-4b74-af96-21ec5a93c455
md"""
You could simply add `lmpi` bu using `mpicc` and `mpic++` is easier.
"""

# ╔═╡ 8981b5e2-2497-478e-ab28-a14b62f6f916
run(`mpicc -show`)

# ╔═╡ 5441e428-b320-433c-acde-15fe6bf58537
run(`mpic++ -show`)

# ╔═╡ 40606ee3-38cc-4123-9b86-b774bf89e499
section("Collectives")

# ╔═╡ c2578811-2a84-4759-947b-d370d559a2d0
hbox([
	img("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/broadcastvsscatter.png"),
	vbox([
		img("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/gather.png"),
		img("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/allgather.png"),
	]),
])

# ╔═╡ b94cd399-0370-49e9-a522-056f3af22955
img("https://raw.githubusercontent.com/VictorEijkhout/TheArtOfHPC_vol2_parallelprogramming/refs/heads/main/booksources/graphics/collectives.jpg")

# ╔═╡ 5b33a0f5-5bd1-4e58-a122-85cf1baa6e29
img("https://raw.githubusercontent.com/VictorEijkhout/TheArtOfHPC_vol2_parallelprogramming/refs/heads/main/booksources/graphics/collective_comm.jpg")

# ╔═╡ 7aae4bcf-5f2b-43bf-aa8f-df6ec0f6ac43
aside(md"[Source](https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/)", v_offset = -200)

# ╔═╡ 321c7d0d-1b95-404c-9cb5-6c6df97b3836
frametitle("Reduction collectives")

# ╔═╡ a1b2d090-d498-4d5d-90a0-8cdc648dc833
section("Distributed sum")

# ╔═╡ a771f33f-7ed1-41aa-bee0-c215729a8c8d
frametitle("Distributed vector")

# ╔═╡ 370f0f20-e373-4028-bca1-83e93678cbcb
img("https://raw.githubusercontent.com/VictorEijkhout/TheArtOfHPC_vol2_parallelprogramming/refs/heads/main/booksources/graphics/mpi-array.png")

# ╔═╡ 141d162c-c817-498f-be16-f1cd35d82487
Foldable(md"How to collect the partial sums ?", md"`MPI_Reduce`")

# ╔═╡ 7cf59087-efca-4f03-90dc-f2acefdcbc8a
frametitle("Let's try it")

# ╔═╡ 35aa1295-642f-4525-bf19-df2a42ff39d6
compile_and_run(Example("mpi_sum.c"), mpi = true, num_processes = 4, verbose = 1)

# ╔═╡ e832ce25-94e2-4743-854d-02b52cc7b56d
aside(Foldable(md"Why is it the first process that gets the sum ?", md"We gave 0 to the 6th argument of `MPI_Reduce`, this decides which node gets the sum."), v_offset = -100)

# ╔═╡ a79c410a-bebf-434c-9730-568e0ff4f4c7
section("Consortium des Équipements de Calcul Intensif (CÉCI)")

# ╔═╡ 39f48c25-6efb-4ff2-aedc-9d3e722dad24
md"""
* [Follow README instructions to create an account and setup your computer](https://github.com/blegat/LINMA2710?tab=readme-ov-file#ceci-cluster)
  - Don't wait the last minute, if you get into trouble it's easier to get this setup before you actually need it
* Select $(img("https://www.ceci-hpc.be/assets/img/new_ceci_logo.png", :height => "15pt")) cluster from [the list](https://www.ceci-hpc.be/clusters.html) + `manneback` for GPU. You only have access to Tier-2 clusters. This sadly leaves out:
  - Tier-1 clusters such as Lucia
  - Tier-0 cluster such as $(img("https://www.lumi-supercomputer.eu/content/uploads/2020/02/lumi_logo.png", :height => "15pt")) from $(img("https://upload.wikimedia.org/wikipedia/commons/8/8f/HPC_JU_logo_RGB.svg", :height => "20pt"))
* Connect with SSH using `ssh lemaitre4` or `ssh manneback`.
"""

# ╔═╡ 55e96151-2aa1-4ea0-b672-2038c57d911e
aside(img("https://upload.wikimedia.org/wikipedia/en/3/3e/The_LUMI_supercomputer.jpg", :height => "100pt"), v_offset = -140)

# ╔═╡ be0e3ba0-18cc-4b9a-a56d-2566f5148fae
frametitle(md"""$(img("https://github.com/TACC/Lmod/raw/main/logos/2x/Lmod-4color%402x.png", :height => "30px"))""")

# ╔═╡ 88f33f35-d922-4d98-af4a-ebb79d9b7dc6
mpicc_cmd = md"""
```sh
[blegat@lm4-f001 ~]$ mpicc
-bash: mpicc: command not found

[blegat@lm4-f001 ~]$ module load gompi/2023a

[blegat@lm4-f001 ~]$ mpicc
gcc: fatal error: no input files
compilation terminated.
```
""";

# ╔═╡ e3474aea-ee14-4c78-ae46-5badc66a543a
list_1 = Foldable(md"`[blegat@lm4-f001 ~]$ module list`", md"""
```
Currently Loaded Modules:
  1) tis/2018.01 (S)   2) releases/2023a (S)   3) StdEnv

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```
""");

# ╔═╡ 6c1984f6-4e36-4637-b0da-c7dd8b0f9ff0
list_2 = Foldable(md"`[blegat@lm4-f001 ~]$ module list`", md"""
```
Currently Loaded Modules:
  1) tis/2018.01                   (S)  11) libpciaccess/0.17-GCCcore-12.3.0
  2) releases/2023a                (S)  12) hwloc/2.9.1-GCCcore-12.3.0
  3) StdEnv                             13) OpenSSL/1.1
  4) GCCcore/12.3.0                     14) libevent/2.1.12-GCCcore-12.3.0
  5) zlib/1.2.13-GCCcore-12.3.0         15) UCX/1.14.1-GCCcore-12.3.0
  6) binutils/2.40-GCCcore-12.3.0       16) libfabric/1.18.0-GCCcore-12.3.0
  7) GCC/12.3.0                         17) PMIx/4.2.4-GCCcore-12.3.0
  8) numactl/2.0.16-GCCcore-12.3.0      18) UCC/1.2.0-GCCcore-12.3.0
  9) XZ/5.4.2-GCCcore-12.3.0            19) OpenMPI/4.1.5-GCC-12.3.0
 10) libxml2/2.11.4-GCCcore-12.3.0      20) gompi/2023a

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```
""");

# ╔═╡ c0daf219-cb87-4203-b835-49ab7eb955be
md"""
```
[local computer]$ ssh lemaitre4
```

$list_1

$mpicc_cmd

$list_2
"""

# ╔═╡ c1285653-38ba-418b-bdf5-cda99440998d
aside(tip(Foldable(md"Use `module spider` to see which version are available",
md"""
```
[blegat@lm4-f001 ~]$ module spider gompi

----------------------------
  gompi:
----------------------------
    Description:
      GNU Compiler Collection (GCC) based compiler toolchain, including OpenMPI for MPI support.

     Versions:
        gompi/2021b
        gompi/2022b
        gompi/2023a
        gompi/2023b

----------------------------
  For detailed information about a specific "gompi" package (including how to load the modules) use the module's full name.
  Note that names that have a trailing (E) are extensions provided by other modules.
  For example:

     $ module spider gompi/2023b
----------------------------
```
""")), v_offset = -300)

# ╔═╡ beee4908-d519-413a-964f-149bb82cdbb8
frametitle("Slurm")

# ╔═╡ d8bb1d43-bf42-4a09-bdeb-5db406ef1ccd
hbox([Div(md"""
* `srun` : Synchronous (blocked) job
```
[blegat@lm4-f001 ~]$ srun --time=1 pwd
srun: job 3491072 queued and waiting for resources
srun: job 3491072 has been allocated resources
/home/users/b/l/blegat
```
* `$ sbatch submit.sh` : Asynchronous job, get status with
* `$ squeue --me`
""", style = Dict("flex-grow" => "1", "margin-right" => "30px")),
md"""
$(img("https://upload.wikimedia.org/wikipedia/commons/3/3a/Slurm_logo.svg", :width => "160px", :height => "160px"))
See [CÉCI documentation](https://support.ceci-hpc.be/doc/_contents/QuickStart/SubmittingJobs/SlurmTutorial.html)
""",
])

# ╔═╡ 972b8af7-5e4d-4236-8875-016d1ed5b535
Pkg.instantiate()

# ╔═╡ 9d0c7847-a76f-42a0-b73c-0aed1c58d87a
biblio = load_biblio!();

# ╔═╡ 2504c31b-ea38-403f-931a-8ebb72e73af4
bibrefs(biblio, "eijkhout2017Parallel")

# ╔═╡ Cell order:
# ╟─58e12afd-6eb0-4731-bd57-d9ae7ab4e164
# ╟─2504c31b-ea38-403f-931a-8ebb72e73af4
# ╟─5a566137-fbd1-45b2-9a55-e4aded366bb3
# ╟─a6c337c4-0c81-4463-ad4f-9a4528d953ab
# ╟─c04bcc96-e5fe-4d6e-a12e-40dcde58c62e
# ╟─cf799c26-1cea-4b38-9a15-8497813bd668
# ╟─6d2b3dbc-0686-49f0-904a-56c3ce63b4dd
# ╟─b5a3e471-af4a-466f-bbae-96306bcc7563
# ╟─d722a86d-6d51-4d91-ac22-53af94c91497
# ╟─c3590376-06ed-45a4-af0b-2d46f1a387c8
# ╟─52d428d5-cb33-4f2a-89eb-3a8ce3f5bb81
# ╟─273ad3a6-cb32-49bb-8702-fdaf8597e812
# ╟─4e32f7fb-cd5a-4190-9c92-ba4029313475
# ╟─82230d6c-25ce-4d12-8842-e0651fc4b143
# ╟─7d9ac5f9-39bf-4052-ad8a-ac0fec15c64a
# ╟─b0ca0392-71b8-4f44-8c6c-0978a02a0e6c
# ╟─21b6133f-db59-4885-9b3d-331c3d6ef306
# ╟─35ba1eea-56ae-4b74-af96-21ec5a93c455
# ╠═8981b5e2-2497-478e-ab28-a14b62f6f916
# ╠═5441e428-b320-433c-acde-15fe6bf58537
# ╟─40606ee3-38cc-4123-9b86-b774bf89e499
# ╟─c2578811-2a84-4759-947b-d370d559a2d0
# ╟─b94cd399-0370-49e9-a522-056f3af22955
# ╟─5b33a0f5-5bd1-4e58-a122-85cf1baa6e29
# ╟─7aae4bcf-5f2b-43bf-aa8f-df6ec0f6ac43
# ╟─321c7d0d-1b95-404c-9cb5-6c6df97b3836
# ╟─a1b2d090-d498-4d5d-90a0-8cdc648dc833
# ╟─a771f33f-7ed1-41aa-bee0-c215729a8c8d
# ╟─370f0f20-e373-4028-bca1-83e93678cbcb
# ╟─141d162c-c817-498f-be16-f1cd35d82487
# ╟─7cf59087-efca-4f03-90dc-f2acefdcbc8a
# ╟─35aa1295-642f-4525-bf19-df2a42ff39d6
# ╟─e832ce25-94e2-4743-854d-02b52cc7b56d
# ╟─a79c410a-bebf-434c-9730-568e0ff4f4c7
# ╟─39f48c25-6efb-4ff2-aedc-9d3e722dad24
# ╟─55e96151-2aa1-4ea0-b672-2038c57d911e
# ╟─be0e3ba0-18cc-4b9a-a56d-2566f5148fae
# ╟─c0daf219-cb87-4203-b835-49ab7eb955be
# ╟─c1285653-38ba-418b-bdf5-cda99440998d
# ╟─88f33f35-d922-4d98-af4a-ebb79d9b7dc6
# ╟─e3474aea-ee14-4c78-ae46-5badc66a543a
# ╟─6c1984f6-4e36-4637-b0da-c7dd8b0f9ff0
# ╟─beee4908-d519-413a-964f-149bb82cdbb8
# ╟─d8bb1d43-bf42-4a09-bdeb-5db406ef1ccd
# ╟─82e1ea5e-f8e0-11ef-0f93-49a66050feaf
# ╟─972b8af7-5e4d-4236-8875-016d1ed5b535
# ╟─8df4ff2f-d176-4b4e-a525-665b5d07ea52
# ╟─a55c5090-1455-4fb9-bdb9-a0b9b340b154
# ╟─9d0c7847-a76f-42a0-b73c-0aed1c58d87a
