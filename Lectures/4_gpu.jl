### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
import Pkg

# ╔═╡ 8dcb5cf0-d579-42ba-ba4d-41c599587975
Pkg.activate(".")

# ╔═╡ 584dcbdd-cfed-4e19-9b7c-0e5256d051fa
using MyUtils, PlutoUI, Luxor, StaticArrays, BenchmarkTools

# ╔═╡ 2861935c-c989-434b-996f-f2c99d785315
frametitle("GPGPU")

# ╔═╡ 56576b00-e1e0-41b1-abf7-d21a7d2fecde
md"""
Stands for "General-purpose computing on graphics processing units"
"""

# ╔═╡ a4db4017-9ecd-4b03-9127-2c75e5d2c537
Pkg.instantiate()

# ╔═╡ Cell order:
# ╠═2861935c-c989-434b-996f-f2c99d785315
# ╠═56576b00-e1e0-41b1-abf7-d21a7d2fecde
# ╠═7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
# ╠═8dcb5cf0-d579-42ba-ba4d-41c599587975
# ╠═a4db4017-9ecd-4b03-9127-2c75e5d2c537
# ╠═584dcbdd-cfed-4e19-9b7c-0e5256d051fa
