### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
import Pkg

# ╔═╡ 8dcb5cf0-d579-42ba-ba4d-41c599587975
Pkg.activate(".")

# ╔═╡ 584dcbdd-cfed-4e19-9b7c-0e5256d051fa
using MyUtils, PlutoUI, PlutoUI.ExperimentalLayout, Luxor, StaticArrays, BenchmarkTools, OpenCL, pocl_jll

# ╔═╡ 2861935c-c989-434b-996f-f2c99d785315
header("LINMA2710 - Scientific Computing
Graphics processing unit (GPU)", "P.-A. Absil and B. Legat")

# ╔═╡ 6a09a11c-6ddd-4302-b371-7a947f339b52
md"""
* Source : [HandsOnOpenCL](https://github.com/HandsOnOpenCL/Lecture-Slides)
"""

# ╔═╡ 2b7036fe-2cd6-45bb-8124-b805b85fd0ba
frametitle("Context")

# ╔═╡ d235c08c-5508-4da1-9863-dcc75775b28d
md"""
* Most *dedicated* GPUs produced by $(img("https://upload.wikimedia.org/wikipedia/commons/a/a4/NVIDIA_logo.svg", :height => "15pt")) and $(img("https://upload.wikimedia.org/wikipedia/commons/7/7c/AMD_Logo.svg", :height => "15pt"))
* *Integrated* GPUs by $(img("https://upload.wikimedia.org/wikipedia/commons/6/6a/Intel_logo_%282020%2C_dark_blue%29.svg", :height => "15pt")) used in laptops to reduce power consumption
* Designed for 3D rendering through ones of the APIs : $(img("https://upload.wikimedia.org/wikipedia/commons/7/7f/Microsoft-DirectX-Logo-wordmark.svg", :height => "20pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/2/21/OpenGL_logo.svg", :height => "20pt")), $(img("https://upload.wikimedia.org/wikipedia/commons/2/25/WebGL_Logo.svg", :height => "20pt")) $(img("https://upload.wikimedia.org/wikipedia/commons/f/fe/Vulkan_logo.svg", :height => "20pt")) or $(img("https://upload.wikimedia.org/wikipedia/commons/8/8d/Metal_3_Logo.png", :height => "20pt"))
"""

# ╔═╡ a3f31283-1054-4abe-9ec3-1e753905b83f
frametitle("General-Purpose computing on GPU (GPGPU)")

# ╔═╡ ed8768e0-4b3c-4a13-8533-2219cbd1d1a1
md"""
Also known as *compute shader* as they abuses the programmable shading of GPUs by treating the data as texture maps.
"""

# ╔═╡ 277130d7-1e4f-44e7-bcf5-3a70baa45f36
grid([
	md"Hardware-specific" img("https://upload.wikimedia.org/wikipedia/commons/b/b9/Nvidia_CUDA_Logo.jpg", :height => "70pt") img("https://upload.wikimedia.org/wikipedia/commons/7/7b/ROCm_logo.png", :height => "60pt") md"""` ` $(img("https://upload.wikimedia.org/wikipedia/commons/6/6a/Intel_logo_%282020%2C_dark_blue%29.svg", :height => "30pt")) $(img("https://upload.wikimedia.org/wikipedia/en/f/fa/OneAPI-rgb-3000.png", :height => "60pt"))"""
	md"Common interface" img("https://upload.wikimedia.org/wikipedia/commons/4/4d/OpenCL_logo.svg") img("https://upload.wikimedia.org/wikipedia/commons/1/12/SYCL_logo.svg") img("https://d29g4g2dyqv443.cloudfront.net/sites/default/files/akamai/designworks/blog1/OpenACC-logo.png", :height => "50pt")
])

# ╔═╡ 2eba97cf-56c2-457c-b07d-1ec5678476b1
frametitle("Standard Portable Intermediate Representation (SPIR)")

# ╔═╡ 426b14a2-218a-4639-a36a-0188e8f8328a
md"""
Similar to LLVM IR : Intermediate representation for accelerated computation.
"""

# ╔═╡ a48fb960-3a78-435f-9167-78d831667252
img("https://www.khronos.org/assets/uploads/apis/2024-spirv-language-ecosystem.jpg")

# ╔═╡ adf26494-b700-4867-8c74-f8d520bbd29d
hbox([
	md"""
* CPUs:
   - All CPUs part of same device
   - 1 Compute Unit per core
   - Number of processing elements equal to SIMD width
* GPUs:
   - One device per GPU
""",
	img("https://upload.wikimedia.org/wikipedia/de/9/96/Platform_architecture_2009-11-08.svg", :width => "400pt"),
])

# ╔═╡ f161cf4d-f516-4db8-a54f-c757f50d4d83
img("https://upload.wikimedia.org/wikipedia/de/d/d1/OpenCL_Memory_model.svg")

# ╔═╡ 7e29d33b-9956-4663-9985-b89923fbf1f8
OpenCL.versioninfo()

# ╔═╡ aaa38deb-6aac-4d3c-bb1a-9ce01231c7d5
cl.device()

# ╔═╡ 31d22594-6682-4fa3-946c-4eb3feab9823
cl.device().max_work_group_size

# ╔═╡ d0e2e643-93e1-4b48-866e-d12a3714e419
cl.device().extensions

# ╔═╡ a4db4017-9ecd-4b03-9127-2c75e5d2c537
Pkg.instantiate()

# ╔═╡ Cell order:
# ╟─2861935c-c989-434b-996f-f2c99d785315
# ╟─6a09a11c-6ddd-4302-b371-7a947f339b52
# ╟─2b7036fe-2cd6-45bb-8124-b805b85fd0ba
# ╟─d235c08c-5508-4da1-9863-dcc75775b28d
# ╟─a3f31283-1054-4abe-9ec3-1e753905b83f
# ╟─ed8768e0-4b3c-4a13-8533-2219cbd1d1a1
# ╟─277130d7-1e4f-44e7-bcf5-3a70baa45f36
# ╟─2eba97cf-56c2-457c-b07d-1ec5678476b1
# ╟─426b14a2-218a-4639-a36a-0188e8f8328a
# ╟─a48fb960-3a78-435f-9167-78d831667252
# ╟─adf26494-b700-4867-8c74-f8d520bbd29d
# ╟─f161cf4d-f516-4db8-a54f-c757f50d4d83
# ╠═7e29d33b-9956-4663-9985-b89923fbf1f8
# ╠═aaa38deb-6aac-4d3c-bb1a-9ce01231c7d5
# ╠═31d22594-6682-4fa3-946c-4eb3feab9823
# ╠═d0e2e643-93e1-4b48-866e-d12a3714e419
# ╟─7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
# ╟─8dcb5cf0-d579-42ba-ba4d-41c599587975
# ╟─a4db4017-9ecd-4b03-9127-2c75e5d2c537
# ╠═584dcbdd-cfed-4e19-9b7c-0e5256d051fa
