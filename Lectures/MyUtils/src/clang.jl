import Clang_jll
import MultilineStrings
import InteractiveUtils

function md_code(code, language)
    code = "```" * language * '\n' * code
    if code[end] != '\n'
        code *= '\n'
    end
    return Markdown.parse(code * "```")
end

md_c(code) = md_code(code, "c")

function compile(code; lib, emit_llvm = false, cflags = ["-O3"])
    path = mktempdir()
    main_file = joinpath(path, "main.c")
    bin_file = joinpath(path, ifelse(emit_llvm, "main.llvm", ifelse(lib, "lib.so", "bin")))
    write(main_file, code)
    args = [main_file]
    append!(args, cflags)
    if lib
        push!(args, "-fPIC")
        push!(args, "-shared")
    end
    if emit_llvm
        push!(args, "-S")
        push!(args, "-emit-llvm")
    end
    push!(args, "-o")
    push!(args, bin_file)
    try
        Clang_jll.clang() do exe
            run(Cmd([exe; args]))
        end
    catch err
        if err isa ProcessFailedException
            return md_c(code)
        else
            rethrow(err)
        end
    end
    return bin_file
end

function emit_llvm(code; kws...)
    llvm = compile(code; lib = false, emit_llvm = true, kws...)
    InteractiveUtils.print_llvm(stdout, read(llvm, String))
    return md_c(code)
end

function compile_lib(code; kws...)
    return md_c(code), compile(code; lib = true, kws...)
end

function compile_and_run(code; args = String[], kws...)
    cmd = Cmd([compile(code; lib = false, kws...); args])
    if !isempty(args)
        println("\$ $(string(cmd)[2:end-1])") # `2:end-1` to remove the backsticks
    end
    run(cmd)
    return md_c(code)
end

function wrap_in_main(code)
    if code[end] == '\n'
        code = code[1:end-1]
    end
    return """
#include <stdlib.h>

int main(int argc, char **argv) {
$(MultilineStrings.indent(code, 2))
}
"""
end

function wrap_compile_and_run(code; kws...)
    compile_and_run(wrap_in_main(code); kws...)
    return md_c(code)
end
