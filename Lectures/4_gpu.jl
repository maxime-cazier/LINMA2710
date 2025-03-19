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

# ╔═╡ 7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
import Pkg

# ╔═╡ 8dcb5cf0-d579-42ba-ba4d-41c599587975
Pkg.activate(".")

# ╔═╡ 4034621b-b836-43f6-99ec-2f7ac88cf4e3
using OpenCL, pocl_jll # `pocl_jll` provides the POCL OpenCL platform for CPU devices

# ╔═╡ 584dcbdd-cfed-4e19-9b7c-0e5256d051fa
using MyUtils, PlutoUI, PlutoUI.ExperimentalLayout, Luxor, StaticArrays, BenchmarkTools, PlutoTeachingTools

# ╔═╡ 2861935c-c989-434b-996f-f2c99d785315
header("LINMA2710 - Scientific Computing
Graphics processing unit (GPU)", "P.-A. Absil and B. Legat")

# ╔═╡ 6a09a11c-6ddd-4302-b371-7a947f339b52
md"""
Sources

* [OpenCL.jl](https://github.com/JuliaGPU/OpenCL.jl)
* [HandsOnOpenCL](https://github.com/HandsOnOpenCL/Lecture-Slides)
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

# ╔═╡ 2e0ffb06-536b-402c-9ee8-8980c6f08d37
frametitle("OpenCL Platforms and Devices")

# ╔═╡ 269eadc2-77ea-4329-ae77-a2df4d2af8cb
md"""
* Platforms are OpenGL implementations, listed in `/etc/OpenCL/vendors`
* Devices are actual CPUs/GPUs
* ICD allows to change platform at runtime.
"""

# ╔═╡ 7e29d33b-9956-4663-9985-b89923fbf1f8
OpenCL.versioninfo()

# ╔═╡ 05372b0b-f03c-4b50-99c2-51559da18137
md"See also `clinfo` command line tool and `examples/OpenCL/common/device_info.c`."

# ╔═╡ ee9ca02c-d431-4194-ba96-67a855d0f7b1
frametitle("Mandelbrot")

# ╔═╡ 3e0f2c68-c766-4277-8e3b-8ada91050aa3
hbox([
	md"""`mandel_size` = $(@bind mandel_size Slider(2 .^ (4:16), default = 512, show_value = true))""",
	Div(html" "; style = Dict("flex-grow" => "1")),
	md"""`maxiter` = $(@bind maxiter Slider(1:200, default = 100, show_value = true))""",
])

# ╔═╡ c902f1de-5659-4518-b3ac-534844e9a93c
q = [ComplexF32(r,i) for i=1:-(2.0/mandel_size):-1, r=-1.5:(3.0/mandel_size):0.5];

# ╔═╡ 0c3de497-aa34-441c-9e8d-8007809c05e4
mandel_source = code(Example("OpenCL/mandelbrot/mandel.cl"));

# ╔═╡ 81e9d99a-c6ce-48ff-9caa-9b1869b36c2a
aside(codesnippet(mandel_source), v_offset = -400)

# ╔═╡ d49864e2-4643-4bb4-8fed-b53a3b5f2dcb
function platform_device_select()
	p = @bind platform Select([p => p.name for p in cl.platforms()])
	d = @bind device Select([d => d.name for d in cl.devices(platform)])
	return platform, device, hbox([
		p,
		Div(html" "; style = Dict("flex-grow" => "1")),
		d,
	])
end

# ╔═╡ ff473748-ed4a-4cef-9681-10ba978a3525
md"""
* Platform
  - name: $(platform.name)
  - profile: $(platform.profile)
  - vendor: $(platform.vendor)
  - version: $(platform.version)
* Device
  - name: $(device.name)
  - type: $(device.device_type)
  - memory size: $(div(device.global_mem_size, 1024^2)) MB
  - max mem alloc size: $(div(device.max_mem_alloc_size, 1024^2)) MB
  - max clock freq: $(device.max_clock_frequency) MHz
  - max compute units: $(device.max_compute_units)
  - max work group size: $(device.max_work_group_size)
  - max work item size: $(device.max_work_item_size)
"""

# ╔═╡ d92bef71-976a-42dd-81ca-5c298697f2e2
#=╠═╡
mandel_select
  ╠═╡ =#

# ╔═╡ 3f0383c1-f5e7-4f84-8b86-f5823c37e5eb
function mandel_opencl(q::Array{ComplexF32}, maxiter::Int64)
	cl.device!(mandel_device)
    q = CLArray(q)
    o = CLArray{Cushort}(undef, size(q))

    prg = cl.Program(; source = mandel_source.code) |> cl.build!
    k = cl.Kernel(prg, "mandelbrot")

    clcall(k, Tuple{Ptr{ComplexF32}, Ptr{Cushort}, Cushort},
           q, o, maxiter; global_size=length(q))

    return Array(o)
end

# ╔═╡ 02a4d1b9-b8ec-4fd5-84fa-4cf67d947419
mandel_image = @time mandel_opencl(q, maxiter);

# ╔═╡ a4db4017-9ecd-4b03-9127-2c75e5d2c537
Pkg.instantiate()

# ╔═╡ 3ce993a9-8354-47a5-8c63-ff0b0b70caa5
import CairoMakie # not `using`  as `Slider` collides with PlutoUI

# ╔═╡ ed8bf827-d280-4c80-9518-ddb35614daaa
CairoMakie.image(CairoMakie.rotr90(mandel_image))

# ╔═╡ 6c0e8029-0cae-493e-b59b-7bc6c92c6aed
hbox([
	(@bind mandel_platform Select([p => p.name for p in cl.platforms()])),
	Div(html" "; style = Dict("flex-grow" => "1")),
	(@bind mandel_device Select([d => d.name for d in cl.devices(mandel_platform)])),
])

# ╔═╡ 252f41a3-fc39-45e0-8dca-8750245f2057
# ╠═╡ disabled = true
#=╠═╡
mandel_platform, mandel_device, mandel_select = platform_device_select()
  ╠═╡ =#

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
# ╟─2e0ffb06-536b-402c-9ee8-8980c6f08d37
# ╟─269eadc2-77ea-4329-ae77-a2df4d2af8cb
# ╠═7e29d33b-9956-4663-9985-b89923fbf1f8
# ╟─05372b0b-f03c-4b50-99c2-51559da18137
# ╟─ff473748-ed4a-4cef-9681-10ba978a3525
# ╟─ee9ca02c-d431-4194-ba96-67a855d0f7b1
# ╠═252f41a3-fc39-45e0-8dca-8750245f2057
# ╟─d92bef71-976a-42dd-81ca-5c298697f2e2
# ╟─6c0e8029-0cae-493e-b59b-7bc6c92c6aed
# ╟─3e0f2c68-c766-4277-8e3b-8ada91050aa3
# ╠═c902f1de-5659-4518-b3ac-534844e9a93c
# ╠═02a4d1b9-b8ec-4fd5-84fa-4cf67d947419
# ╟─ed8bf827-d280-4c80-9518-ddb35614daaa
# ╟─81e9d99a-c6ce-48ff-9caa-9b1869b36c2a
# ╟─0c3de497-aa34-441c-9e8d-8007809c05e4
# ╠═3f0383c1-f5e7-4f84-8b86-f5823c37e5eb
# ╠═d49864e2-4643-4bb4-8fed-b53a3b5f2dcb
# ╟─7f00bb10-fe5b-11ef-0aeb-dd2bd85aac10
# ╟─8dcb5cf0-d579-42ba-ba4d-41c599587975
# ╟─a4db4017-9ecd-4b03-9127-2c75e5d2c537
# ╠═4034621b-b836-43f6-99ec-2f7ac88cf4e3
# ╟─584dcbdd-cfed-4e19-9b7c-0e5256d051fa
# ╟─3ce993a9-8354-47a5-8c63-ff0b0b70caa5
