### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 78503ab7-f0a3-4231-8b4e-5fd30715ec27
import Pkg

# ╔═╡ 58758402-50e7-4d7b-b4aa-4b0dcb137869
Pkg.activate(".")

# ╔═╡ 34519b36-0e60-4c2c-92d6-3b8ed71e6ad1
using MyUtils, PlutoUI, PlutoUI.ExperimentalLayout, Luxor, StaticArrays, BenchmarkTools, PlutoTeachingTools, Markdown

# ╔═╡ d537aa7e-f38a-11ef-3bef-b7291789fea9
header("LINMA2710 - Scientific Computing
Shared-Memory Multiprocessing", "P.-A. Absil and B. Legat")

# ╔═╡ e7445ed8-cbf7-475d-bd67-3df8d9015de2
section("Parallel sum")

# ╔═╡ d5432907-3e55-4035-9c91-183c37d886ea
aside(vbox([
md"`log_size` = $(@bind log_size Slider(14:24, default = 16, show_value = true))",
md"`num_threads` = $(@bind num_threads Slider(2:8, default = 2, show_value = true))",
]), v_offset = -900)

# ╔═╡ 3a5d674d-7c5b-4dac-b9ae-d65a1e9a5cba
vec = rand(Cfloat, 2^log_size)

# ╔═╡ 1b9fb8aa-71cf-4e69-ad84-666c1b66bb5e
begin
	no_diff = Foldable(
		md"Wait, these didn't make any difference in the benchmark, how can it be ?",
		md"""
The compiler most probably use a register (actually a SIMD register here (if there is any) since we used `#pragma omp simd`) as accumulator for the `for` loop and only stored the value of that register into `total`, `local_results[thread_num]` or `no_false_sharing` (depending on the version).
Despite all this, it is still important to be careful about this issue and not trust the execution on one environment or rely too much on compiler optimizations for the code to be portable.
""",
	)
	false_sharing = Foldable(
		md"This is still a performance issue, can you see why ?",
		md"""
The entries of `local_results` are close to each other in memory. There are therefore very likely going to be part of the same block on cache. This means that when one threads modifies it, the cache block will need to be written and then other threads will need to refresh the value of this block in their cache.  variable `total` is shared between the threads, so its value in the register should be sync'ed between the threads! This is called *false sharing*. Let's fix this ? $(@bind no_false_sharing CheckBox(default = false))
$no_diff
""",
	)
aside(Foldable(
	md"Can you spot the issue in the code ?",
	md"""
The same variable `total` is shared between the threads, so its value in the register should be sync'ed between the threads, this is a performance issue! More importantly, the access to the `total` variable are not **atomic**. Therefore, two threads may read the value, `add`, and then store → only one of the two `add` will then be accounted for! Let's fix this ? $(@bind local_results CheckBox(default = false))
$false_sharing
	""",
), v_offset = -800)
end

# ╔═╡ 19655acd-5880-44fa-ac29-d56faf43e87b
function c_sum_code(T; local_results::Bool, no_false_sharing::Bool, simd::Bool)
	code = """
#include <vector>
#include <omp.h>
#include <stdio.h>

extern "C" {
$T sum($T *vec, int length, int num_threads, int verbose) {
  $T total = 0;
  omp_set_dynamic(0); // Force the value `num_threads`
  omp_set_num_threads(num_threads);
"""
	if local_results
		code *= """
  std::vector<$T> local_results(num_threads);
"""
	end
	code *= """
  #pragma omp parallel
  {
    int thread_num = omp_get_thread_num();
	int stride = length / num_threads;
    int last = stride * (thread_num + 1);
    if (thread_num + 1 == num_threads)
      last = length;
	if (verbose >= 1)
      fprintf(stderr, "thread id : %d / %d %d:%d\\n", thread_num, omp_get_num_threads(), stride * thread_num, last - 1);
"""
	if no_false_sharing
		code *= """
	$T no_false_sharing = 0;
"""
	end
	if simd
		code *= """
    #pragma omp simd
"""
	end
    code *= """
    for (int i = stride * thread_num; i < last; i++)
      $(local_results ? (no_false_sharing ? "no_false_sharing" : "local_results[thread_num]") : "total") += vec[i];
"""
	if local_results && no_false_sharing
		code *= """
	local_results[thread_num] = no_false_sharing;
"""
	end
	code *= """
  }
"""
	if local_results
		code *= """
  for (int i = 0; i < local_results.size(); i++)
    total += local_results[i];
"""
	end
	code *= """
  return total;
}
}
"""
	return code
end;

# ╔═╡ ebe1cd42-ba25-4538-acbe-353e0e47009e
sum_md_code, sum_lib = compile_lib(c_sum_code("float"; local_results, no_false_sharing, simd = true), lib = true, cflags = ["-O3", "-mavx2", "-fopenmp"], language = CppLanguage());

# ╔═╡ 4b9cfb4d-2355-42e3-be2f-35e2638e984b
sum_md_code

# ╔═╡ 253bd533-99b7-4012-b3f4-e86a2466a919
c_sum(x::Vector{Cfloat}; num_threads = 1, verbose = 0) = ccall(("sum", sum_lib), Cfloat, (Ptr{Cfloat}, Cint, Cint, Cint), x, length(x), num_threads, verbose);

# ╔═╡ 62297efe-3a15-4dab-ac17-b823ab3e7933
@btime c_sum($vec, num_threads = 1, verbose = 0)

# ╔═╡ 31727049-ac0a-45a6-aae0-934d4549b541
@btime c_sum($vec; num_threads, verbose = 0)

# ╔═╡ b5f1d18c-53ad-4441-8ca8-e02d6ab840d0
@time c_sum(vec; num_threads, verbose = 1)

# ╔═╡ f95dd40b-8c56-4e10-abbc-3dbb58148e1f
section("Amdahl's law")

# ╔═╡ 2a1f3d29-4d6b-4634-86f3-4ecd4a7821a2
frametitle("Speed-up and efficency")

# ╔═╡ b2b3beda-c8bf-4616-b1bd-bdd907d11636
hbox([
definition("Speed-up", md"""
```math
S_p = \frac{T_1}{T_p}
```"""),
Div(definition("Efficiency", md"""
```math
E_p = \frac{S_p}{p}
```"""); style = Dict("margin-left" => "30px")),
	Div(md"""
Let ``T_p`` bet the time with ``p`` processes
* ``E_p > 1`` → Unlikely
* ``E_p = 1`` → Ideal
* ``E_p < 1`` → Realistic
	"""; style = Dict("margin" => "30px", "flex-grow" => "1")),

]; style = Dict("align-items" => "center", "justify-content" => "center"))

# ╔═╡ b26ab400-ce89-4a76-ad48-464ac6821dd2
frametitle("Amdahl's law")

# ╔═╡ 4b7a62a4-1e88-410b-8549-3021f6cdf6da
md"""
* ``F_s`` : Percentage of ``T_1`` that is sequential
* ``F_p = 1 - F_s`` : Percentage of ``T_1`` that is parallelizable

```math
\begin{align}
T_p &= T_1F_s + T_1F_p/p\\
S_p &= \frac{1}{F_s + F_p/p} & E_p &= \frac{1}{pF_s + F_p}\\
\lim_{p \to \infty} S_p &= \frac{1}{F_s}
\end{align}
```
"""

# ╔═╡ e83baa29-ad2b-4ffc-99f5-cdbca9e31233
frametitle("Application to parallel sum")

# ╔═╡ f7da896d-089c-4430-b82c-db86c380b171
md"""```math
\begin{align}
  T_1 & = n\\
  T_p & = n/p + \log_2(p)\\
  S_p & = \frac{1}{1/p + \log_2(p)/n} & E_p & = \frac{1}{1 + p\log_2(p)/n}
\end{align}
```"""

# ╔═╡ d1aef3d4-33d1-4151-8ba3-2169f734ea6b
Foldable(md"How to get ``1/F_s = \lim_{p \to \infty} S_p`` ?", md"""
The algorithm cannot use more than ``n`` processes so if ``p \ge n``, we have
``T_p = \log_2(n)``.
Therefore, ``\lim_{p \to \infty} S_p = \frac{1}{\log_2(n)}`` hence ``F_s = \log_2(n)``.
""")

# ╔═╡ 8b98b33e-f65d-4cbd-9e80-20a7132cd349
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 0.2

# ╔═╡ Cell order:
# ╟─d537aa7e-f38a-11ef-3bef-b7291789fea9
# ╟─e7445ed8-cbf7-475d-bd67-3df8d9015de2
# ╟─4b9cfb4d-2355-42e3-be2f-35e2638e984b
# ╠═62297efe-3a15-4dab-ac17-b823ab3e7933
# ╠═31727049-ac0a-45a6-aae0-934d4549b541
# ╠═b5f1d18c-53ad-4441-8ca8-e02d6ab840d0
# ╠═3a5d674d-7c5b-4dac-b9ae-d65a1e9a5cba
# ╠═253bd533-99b7-4012-b3f4-e86a2466a919
# ╟─d5432907-3e55-4035-9c91-183c37d886ea
# ╟─1b9fb8aa-71cf-4e69-ad84-666c1b66bb5e
# ╟─ebe1cd42-ba25-4538-acbe-353e0e47009e
# ╟─19655acd-5880-44fa-ac29-d56faf43e87b
# ╟─f95dd40b-8c56-4e10-abbc-3dbb58148e1f
# ╟─2a1f3d29-4d6b-4634-86f3-4ecd4a7821a2
# ╟─b2b3beda-c8bf-4616-b1bd-bdd907d11636
# ╟─b26ab400-ce89-4a76-ad48-464ac6821dd2
# ╟─4b7a62a4-1e88-410b-8549-3021f6cdf6da
# ╟─e83baa29-ad2b-4ffc-99f5-cdbca9e31233
# ╟─f7da896d-089c-4430-b82c-db86c380b171
# ╟─d1aef3d4-33d1-4151-8ba3-2169f734ea6b
# ╟─78503ab7-f0a3-4231-8b4e-5fd30715ec27
# ╟─58758402-50e7-4d7b-b4aa-4b0dcb137869
# ╟─34519b36-0e60-4c2c-92d6-3b8ed71e6ad1
# ╠═8b98b33e-f65d-4cbd-9e80-20a7132cd349
