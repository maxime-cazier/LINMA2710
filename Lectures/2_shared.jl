### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 78503ab7-f0a3-4231-8b4e-5fd30715ec27
import Pkg

# ╔═╡ 58758402-50e7-4d7b-b4aa-4b0dcb137869
Pkg.activate(".")

# ╔═╡ 34519b36-0e60-4c2c-92d6-3b8ed71e6ad1
using MyUtils, PlutoUI, PlutoUI.ExperimentalLayout, Luxor, StaticArrays, BenchmarkTools, PlutoTeachingTools, Markdown

# ╔═╡ d537aa7e-f38a-11ef-3bef-b7291789fea9
header(md"""LINMA2710 -- Scientific Computing
Shared-Memory Multiprocessing""", "P.-A. Absil and B. Legat")

# ╔═╡ e7445ed8-cbf7-475d-bd67-3df8d9015de2
section("Parallel sum")

# ╔═╡ 3a5d674d-7c5b-4dac-b9ae-d65a1e9a5cba
vec = rand(Cfloat, 2^16)

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

# ╔═╡ Cell order:
# ╟─d537aa7e-f38a-11ef-3bef-b7291789fea9
# ╟─e7445ed8-cbf7-475d-bd67-3df8d9015de2
# ╠═3a5d674d-7c5b-4dac-b9ae-d65a1e9a5cba
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
