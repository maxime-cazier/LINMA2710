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
frametitle("Single Program Multiple Data (SPMD)")

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
image_from_url("https://raw.githubusercontent.com/VictorEijkhout/TheArtOfHPC_vol2_parallelprogramming/refs/heads/main/booksources/graphics/mpi-node2.png")

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
frametitle("Collectives")

# ╔═╡ c2578811-2a84-4759-947b-d370d559a2d0
hbox([
	image_from_url("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/broadcastvsscatter.png"),
	vbox([
		image_from_url("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/gather.png"),
		image_from_url("https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/allgather.png"),
	]),
])

# ╔═╡ 321c7d0d-1b95-404c-9cb5-6c6df97b3836
frametitle("Reduction collectives")

# ╔═╡ 7cf59087-efca-4f03-90dc-f2acefdcbc8a
frametitle("Distributed sum")

# ╔═╡ 35aa1295-642f-4525-bf19-df2a42ff39d6
compile_and_run(Example("mpi_sum.c"), mpi = true, num_processes = 4, verbose = 1)

# ╔═╡ a1b2d090-d498-4d5d-90a0-8cdc648dc833
section("Distributed sum")

# ╔═╡ a771f33f-7ed1-41aa-bee0-c215729a8c8d
frametitle("Distributed vector")

# ╔═╡ 7aae4bcf-5f2b-43bf-aa8f-df6ec0f6ac43
aside(md"[Source](https://mpitutorial.com/tutorials/mpi-scatter-gather-and-allgather/)", v_offset = -200)

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
# ╟─321c7d0d-1b95-404c-9cb5-6c6df97b3836
# ╟─7cf59087-efca-4f03-90dc-f2acefdcbc8a
# ╟─35aa1295-642f-4525-bf19-df2a42ff39d6
# ╟─a1b2d090-d498-4d5d-90a0-8cdc648dc833
# ╟─a771f33f-7ed1-41aa-bee0-c215729a8c8d
# ╟─7aae4bcf-5f2b-43bf-aa8f-df6ec0f6ac43
# ╟─82e1ea5e-f8e0-11ef-0f93-49a66050feaf
# ╟─972b8af7-5e4d-4236-8875-016d1ed5b535
# ╟─8df4ff2f-d176-4b4e-a525-665b5d07ea52
# ╟─a55c5090-1455-4fb9-bdb9-a0b9b340b154
# ╟─9d0c7847-a76f-42a0-b73c-0aed1c58d87a
