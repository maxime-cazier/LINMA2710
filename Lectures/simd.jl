### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 406dcb0d-b68d-40ec-8844-c5445cff88f6
import Pkg

# ╔═╡ dfc87f8b-1b29-4f3a-b674-6ddf16b9d1ce
Pkg.activate(".")

# ╔═╡ d3c2d2b7-8f23-478b-b36b-c92552a6cf01
using MyUtils, PlutoUI, Luxor, StaticArrays, BenchmarkTools

# ╔═╡ 49aca9a0-ed40-11ef-1cf9-635242dfa821
header("LINMA2710 - Scientific Computing", "P.-A. Absil and B. Legat")

# ╔═╡ 74ae5855-85e8-4615-bf98-e7819bc053d2
section("History")

# ╔═╡ 0d17955c-6ddc-4d57-8600-8ad3229d4631
HAlign(md"""
* **1972** : C language created by Dennis Ritchie and Ken Thompson to ease development of Unix (previously developed in **assembly**)
* **1985** : C++ created by Bjarne Stroustrup
* **2003** : Vikram Adve and Chris Lattner create LLVM
* **2005** : Apple hires Chris Lattner
* **2007** : Chris Lattner creates the LLVM-based compiler Clang
* **2009** : Mozilla start developing an LLVM-based compiler for Rust
* **2009** : Develpment starts on Julia, with LLVM-based compiler
""",
	md"""$(@draw begin
	    placeimage_from_url("https://upload.wikimedia.org/wikipedia/commons/1/18/ISO_C%2B%2B_Logo.svg", Point(-100, -100), scale = 0.1)
	    arrow(Point(-85, -85), Point(-20, -15))
	    placeimage_from_url("https://raw.githubusercontent.com/rust-lang/www.rust-lang.org/master/static/images/rust-social-wide-light.svg", Point(0, -100), scale = 0.15)
	    arrow(Point(0, -85), Point(0, -15))
	    placeimage_from_url("https://julialang.org/assets/infra/logo.svg", Point(100, -100), scale = 0.15)
	    arrow(Point(85, -85), Point(20, -15))
		placeimage_from_url("https://llvm.org/img/LLVMWyvernSmall.png", Point(-30, 30), scale = 0.08)
		boxed("LLVM Intermediate Representation", Point(0, 0))
		arrow(Point(0, 10), Point(0, 85))
		boxed("Assembly", Point(0, 100))
	end 300 300)"""
)

# ╔═╡ 8a552e21-e51b-457d-b974-148537db6cae
section("Single Instruction Multiple Data (SIMD)")

# ╔═╡ 639e0ece-502b-4379-a932-32c0d119cc2f
frametitle("Instruction sets")

# ╔═╡ 1ddcda8b-fa23-4802-852c-e70b1777c2e4
md"""
The data is **packed** on a single SIMD unit whose width and register depends on the instruction set family.
The single instruction is then run in parallel on all elements of this small **vector** stored in the SIMD unit.
These give the prefix `vp` to the instruction names that stands from *Vectorized Packed*.

| Instruction Set Family | Width of SIMD unit | Register |
|-----------------|-------------------|----------|
| Streaming SIMD Extension (SSE) | 128-bit           | `%xmm`   |
| Advanced Vector Extensions (AVX) | 256-bit           | `%ymm`   |
| AVX-512  | 512-bit           | `%zmm`   |

To determine which instruction set is supported for your computer, look at the `Flags` list in the output of `lscpu`.
We can check in the [Intel® Intrinsics Guide](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#) that `avx`, `avx2` and `avx_vnni` are in the AVX family.
"""

# ╔═╡ 3afaf82a-4843-4afa-8541-1a26d7e943a1
run(pipeline(`lscpu`, `grep Flag`))

# ╔═╡ fc278dad-6133-466b-8c3a-775353bdd64a
function f(x1, x2, x3, x4, y1, y2, y3, y4)
	z1 = x1 + y1
	z2 = x2 + y2
	z3 = x3 + y3
	z4 = x4 + y4
	return z1, z2, z3, z4
end

# ╔═╡ 8ba06c7f-514f-4699-bbf4-38d13a7f0cad
code_llvm(sum, Tuple{Vector{Int}}, debuginfo=:none)

# ╔═╡ e4ef3a2b-ba92-4c86-9ff2-2b968de27ea5
function f2(x, y)
	z = x .+ y
	return z
end

# ╔═╡ 9b2e5748-dce0-4d04-a454-ee3833d59a44
md"`vpadd` for Vectorized Packed add"

# ╔═╡ b4021d54-42e0-468d-9c10-515328e76577
@code_llvm debuginfo=:none f2(ntuple(Int8, Val(32)), ntuple(Int8, Val(32)))

# ╔═╡ 6cc66e41-9598-4f78-9332-6e6c02033b70
@code_native debuginfo=:none f2(ntuple(Int8, Val(32)), ntuple(Int8, Val(32)))

# ╔═╡ 293226a1-d575-4e95-813e-ba8e7abd79b2
function my_copy(a::Vector{Int}, b::Vector{Int})
	for i in 1:length(a)
		@inbounds a[i] = b[i]
	end
end

# ╔═╡ b32e85ed-df6c-49d5-be66-b925bd773faf
begin
	@code_llvm raw = false debuginfo = :none optimize = true my_copy([-1, 1], [0, 0])
end

# ╔═╡ 3a7df4f4-0f7b-4a51-8d6a-dcba9a97c18f
let
    T = Float64
	A = rand(SMatrix{2,2,T})
	x = rand(SVector{2,T})
	@code_llvm debuginfo=:none A * x
end

# ╔═╡ b9ad74c5-d99d-4129-afa2-4ff62eedf796
frametitle("LLVM Loop Vectorizer")

# ╔═╡ 8f0f8590-5751-4b8f-95d2-9c3dffb9b085
Resource(
	"https://i0.wp.com/juliacomputing.com/assets/img/new/auto-vectorization2.png",
	:alt => "SIMD"
)

# ╔═╡ 1997274f-f016-43ea-a8c6-2a607ac4b195
vec_int = rand(Int64, 10^3);

# ╔═╡ a1e7e896-bd0b-43a9-afbb-653f6d493aea
vec_floats = rand(Float16, 10^3);

# ╔═╡ a71f00ab-b5ac-47e2-8745-17f837064d8d
@btime sum(vec_int)

# ╔═╡ 3105d963-0e89-43ca-b6f9-daaf8aec70b2
@btime sum(vec_floats)

# ╔═╡ 4dd4ce0d-3e48-4af1-bb9d-ab3f121d1a7c
md"""
Also need `@inbounds` otherwise the compiler is worried that SIMD will mess up with errors.
"""

# ╔═╡ aed45648-3bfa-4df8-907f-7c711bef5b65
function mysum_simd(x::Vector{T}) where {T}
	s = zero(T)
	@simd for v in x
		s += v
	end
	return s
end;

# ╔═╡ 39e3ff9c-892e-4476-8b81-802a9d6ef8b5
@btime mysum_simd(vec_floats)

# ╔═╡ a26fe835-e205-418b-a2fe-45387e313e85
function mysum(x::Vector{T}) where {T}
	s = zero(T)
	for v in x
		s += v
	end
	return s
end;

# ╔═╡ 8302c524-1f1c-401f-a39c-59b5e4869870
@btime mysum(vec_int)

# ╔═╡ e9cb0525-fb17-4429-844b-797b3c0aaae4
@btime mysum(vec_floats)

# ╔═╡ 10f0f454-f5b8-43ad-a2c5-94ad4945271f
code_llvm(mysum, Tuple{Vector{Float64}}, debuginfo=:none)

# ╔═╡ a71d878e-6182-4adc-8551-1334fee37e19
code_llvm(mysum, Tuple{Vector{Int}}, debuginfo=:none)

# ╔═╡ 0bfeb5db-a332-4f95-b8c8-39b53c4d5822
@code_llvm debuginfo=:none mysum([1, 2, 3, 4])

# ╔═╡ 529ba439-40fe-4d93-88c5-797c0a9fc6ee
frametitle("LLVM Superword-Level Parallelism (SLP) Vectorizer")

# ╔═╡ e699def3-f554-4a82-b3f2-52963f82bec4
a = rand(10^7)

# ╔═╡ 3a530df7-8e1b-444c-9164-d9a3e315afe5
sum_code, sum_lib = compile_lib("""
double sum(double *vec, int length) {
    double total = 0;
    for (int i = 0; i < length; i++) {
        total = total + vec[i];
    }
    return total;
}""", lib = true);

# ╔═╡ 1c8fc81d-c1a8-40ac-b51c-bcdf5df41ae8
sum_code

# ╔═╡ 9268e690-6ade-433f-a3fd-a7f2d7992c64
c_sum(X::Vector{Float64}) = ccall(("sum", sum_lib), Float64, (Ptr{Float64}, Cint), X, length(X))

# ╔═╡ 2d67e6ba-fa28-4d83-9e17-4b70e473b0b3
@benchmark c_sum(a)

# ╔═╡ 69c872e1-966a-4a7a-a90f-d13bc108b801
f(a, b) = (a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4])

# ╔═╡ 6869a1d9-b662-4c66-9adb-fc72932eb6c5
@code_llvm debuginfo=:none f(1, 2, 3, 4, 5, 6, 7, 8)

# ╔═╡ bfb3b635-85b2-4a1e-a16c-5106b6495d09
@code_llvm debuginfo=:none f((1, 2, 3, 4), (5, 6, 7, 8))

# ╔═╡ fcf5c210-c100-4534-a65b-9bee23c518da
md"""
Sources:
* [SIMD in Julia](https://www.youtube.com/watch?v=W1hXttRmuks&t=337s)
* [Demystifying Auto-vectorization in Julia](https://www.juliabloggers.com/demystifying-auto-vectorization-in-julia/)
"""

# ╔═╡ ba942e73-ab7c-4635-ae10-88fa4e717368
SVector{2,Float32}

# ╔═╡ Cell order:
# ╟─49aca9a0-ed40-11ef-1cf9-635242dfa821
# ╟─74ae5855-85e8-4615-bf98-e7819bc053d2
# ╟─0d17955c-6ddc-4d57-8600-8ad3229d4631
# ╟─8a552e21-e51b-457d-b974-148537db6cae
# ╟─639e0ece-502b-4379-a932-32c0d119cc2f
# ╟─1ddcda8b-fa23-4802-852c-e70b1777c2e4
# ╠═3afaf82a-4843-4afa-8541-1a26d7e943a1
# ╠═fc278dad-6133-466b-8c3a-775353bdd64a
# ╠═6869a1d9-b662-4c66-9adb-fc72932eb6c5
# ╠═8ba06c7f-514f-4699-bbf4-38d13a7f0cad
# ╠═e4ef3a2b-ba92-4c86-9ff2-2b968de27ea5
# ╟─9b2e5748-dce0-4d04-a454-ee3833d59a44
# ╠═b4021d54-42e0-468d-9c10-515328e76577
# ╠═6cc66e41-9598-4f78-9332-6e6c02033b70
# ╠═293226a1-d575-4e95-813e-ba8e7abd79b2
# ╠═b32e85ed-df6c-49d5-be66-b925bd773faf
# ╠═3a7df4f4-0f7b-4a51-8d6a-dcba9a97c18f
# ╟─b9ad74c5-d99d-4129-afa2-4ff62eedf796
# ╟─8f0f8590-5751-4b8f-95d2-9c3dffb9b085
# ╠═1997274f-f016-43ea-a8c6-2a607ac4b195
# ╠═a1e7e896-bd0b-43a9-afbb-653f6d493aea
# ╠═a71f00ab-b5ac-47e2-8745-17f837064d8d
# ╠═8302c524-1f1c-401f-a39c-59b5e4869870
# ╠═3105d963-0e89-43ca-b6f9-daaf8aec70b2
# ╠═e9cb0525-fb17-4429-844b-797b3c0aaae4
# ╠═39e3ff9c-892e-4476-8b81-802a9d6ef8b5
# ╟─4dd4ce0d-3e48-4af1-bb9d-ab3f121d1a7c
# ╠═aed45648-3bfa-4df8-907f-7c711bef5b65
# ╠═a26fe835-e205-418b-a2fe-45387e313e85
# ╠═10f0f454-f5b8-43ad-a2c5-94ad4945271f
# ╠═a71d878e-6182-4adc-8551-1334fee37e19
# ╠═0bfeb5db-a332-4f95-b8c8-39b53c4d5822
# ╟─529ba439-40fe-4d93-88c5-797c0a9fc6ee
# ╠═e699def3-f554-4a82-b3f2-52963f82bec4
# ╟─1c8fc81d-c1a8-40ac-b51c-bcdf5df41ae8
# ╟─9268e690-6ade-433f-a3fd-a7f2d7992c64
# ╠═2d67e6ba-fa28-4d83-9e17-4b70e473b0b3
# ╟─3a530df7-8e1b-444c-9164-d9a3e315afe5
# ╠═69c872e1-966a-4a7a-a90f-d13bc108b801
# ╠═bfb3b635-85b2-4a1e-a16c-5106b6495d09
# ╟─fcf5c210-c100-4534-a65b-9bee23c518da
# ╠═ba942e73-ab7c-4635-ae10-88fa4e717368
# ╠═406dcb0d-b68d-40ec-8844-c5445cff88f6
# ╠═dfc87f8b-1b29-4f3a-b674-6ddf16b9d1ce
# ╠═d3c2d2b7-8f23-478b-b36b-c92552a6cf01
