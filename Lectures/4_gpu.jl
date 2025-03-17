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
header("LINMA2710 - Scientific Computing
Graphics processing unit (GPU)", "P.-A. Absil and B. Legat")

# ╔═╡ 2b7036fe-2cd6-45bb-8124-b805b85fd0ba
frametitle("Context")

# ╔═╡ d235c08c-5508-4da1-9863-dcc75775b28d
md"""
* Most *dedicated* GPUs produced by $(img("https://upload.wikimedia.org/wikipedia/commons/a/a4/NVIDIA_logo.svg", :height => "15pt")) and $(img("https://upload.wikimedia.org/wikipedia/commons/7/7c/AMD_Logo.svg", :height => "15pt"))
* *Integrated* GPUs by $(img("https://upload.wikimedia.org/wikipedia/commons/6/6a/Intel_logo_%282020%2C_dark_blue%29.svg", :height => "15pt")) used in laptops to reduce power consumption
* Designed for 3D rendering through ones of the APIs : $(img("https://upload.wikimedia.org/wikipedia/commons/7/7f/Microsoft-DirectX-Logo-wordmark.svg", :height => "20pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/2/21/OpenGL_logo.svg", :height => "20pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/2/25/WebGL_Logo.svg", :height => "20pt")) $(img("https://upload.wikimedia.org/wikipedia/commons/f/fe/Vulkan_logo.svg", :height => "20pt")) or $(img("https://upload.wikimedia.org/wikipedia/commons/8/8d/Metal_3_Logo.png", :height => "20pt"))
* General-Purpose computing on GPU (GPGPU) or *compute shader* abuses the programmable shading of GPUs by treating the data as texture maps through ones of the APIs:
  - $(img("https://upload.wikimedia.org/wikipedia/commons/4/4d/OpenCL_logo.svg", :height => "20pt"))
  - $(img("https://upload.wikimedia.org/wikipedia/commons/b/b9/Nvidia_CUDA_Logo.jpg", :height => "25pt"))
  - $(img("https://upload.wikimedia.org/wikipedia/commons/b/b9/Nvidia_CUDA_Logo.jpg", :height => "25pt"))
  - $(img("https://upload.wikimedia.org/wikipedia/commons/7/7b/ROCm_logo.png", :height => "25pt"))
  - $(img("https://upload.wikimedia.org/wikipedia/en/f/fa/OneAPI-rgb-3000.png", :height => "25pt"))
"""

# ╔═╡ 56576b00-e1e0-41b1-abf7-d21a7d2fecde
md"""
General-purpose computing on graphics processing units (GPGPU)
"""

# ╔═╡ a4db4017-9ecd-4b03-9127-2c75e5d2c537
Pkg.instantiate()

# ╔═╡ Cell order:
# ╟─2861935c-c989-434b-996f-f2c99d785315
# ╟─2b7036fe-2cd6-45bb-8124-b805b85fd0ba
# ╟─d235c08c-5508-4da1-9863-dcc75775b28d
# ╟─56576b00-e1e0-41b1-abf7-d21a7d2fecde
# ╟─7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
# ╟─8dcb5cf0-d579-42ba-ba4d-41c599587975
# ╟─a4db4017-9ecd-4b03-9127-2c75e5d2c537
# ╟─584dcbdd-cfed-4e19-9b7c-0e5256d051fa
