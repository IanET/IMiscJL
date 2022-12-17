module IMisc
import Base.@kwdef

export Void, void, @kwdef, Maybe, @retrefs

"""
    Void

A type with no fields that is the type of void. Anything can be converted to type Void
"""
struct Void end

const void = Void()
Void(x::Any) = void
Base.convert(::Type{Void}, x::Any) = void
Base.convert(::Type{Void}, v::Void) = void

"""
    Maybe{T}

A type that is either T or Nothing
"""
const Maybe{T} = Union{T, Nothing}

@generated function retrefs_impl(f::Function, args...)
    refargexps = Expr[]
    for i in eachindex(args)
        if args[i] <: Base.RefValue
            push!(refargexps, :(args[$i]))
        end
    end
    return Expr(:tuple, refargexps..., :(f(args...)))
end

"""
    @retrefs 

Macro to capture ref arguments in a call expression and return their values in a tuple along with the function return value
Effectively emulating [out] params common in ccall without needing to manually pre-create the references

eg

Given:

```
    function foo(r::Ref{Int})::Bool
        r[] += 1
        return true
    end
```


Instead of:

```
    function wrapfoo()
        r = Ref(Int(0))
        retval = foo(r)
        return r, retval
    end
```

Simply write:

```
    result = @retrefs foo(Int(0))
```

"""
macro retrefs(fex::Expr)
    @assert fex.head == :call "Expression must be a function call"
    func = fex.args[1]
    args = fex.args[2:end]
    return esc(
        quote 
            let 
                local _tres = $retrefs_impl($func, $(args...))
                local _vals = Tuple([r[] for r in _tres[begin:end-1]])
                (_vals..., _tres[end])
            end
        end
    )
end

# function callback0(args::Int32, results::Int32)::Int32
#     return 0
# end

# @macroexpand @cfunction(callback0, Int32, (Int32, Int32)) 
#     return 0
# end

# macro cfunction1(fex::Expr)
#     @assert fex.head == :function
#     # dump(fex)
#     func = fex.args[1].args[1].args[1]
#     # dump(func)
#     args = fex.args[1].args[1].args[2:end]
#     # dump(args)
#     #  TODO Assert args are head = ::, args[2] is a type
#     argtypes = tuple([arg.args[2] for arg in args]...)
#     # dump(argtypes)
#     rettype = fex.args[1].args[end]
#     argtypeexpr = Expr(:tuple, (argtypes...))
#     # dump(:(@cfunction($func, $rettype, $argtypeexpr)))

#     # Works
#     # return :(@cfunction($func, $rettype, $argtypeexpr))
#     exp1 = :($fex)
#     exp2 = :(@cfunction($func, $rettype, $argtypeexpr))
#     # return :($exp1) # works
#     # return exp1 # works

#     # return Expr(:block, exp1) # mangles name
#     # return esc(Expr(:block, exp1)) # works
#     # return esc(Expr(:block, exp2)) # works
#     return esc(Expr(:block, exp1, exp2)) # fails

#     # dump(exp1)
#     # dump(exp2)
#     # return esc(Expr(:block, (exp1, exp2)))
#     # return exp1
# end # module

# @cfunction1 function callback3(args::Int32, results::Int32)::Int32
#     return Int32(0)
# end

# @macroexpand @cfunction1 function callback5(a::Int, b::Int)::Int
#     return a+b
# end

# # dump(:(@cfunction(callback, Int32, (Int32, Int32))))

# q1 = quote
#     function callback9(a::Int, b::Int)::Int
#         return a + b
#     end
#     dump(callback9)
#     @cfunction(callback9, Int, (Int, Int))
# end

# eval(q1)


# macro cfunction1(fex::Expr)
# # macro cfunction1(f, rt, at)
#     # dump(f)
#     # dump(rt)
#     # dump(at)
#     func = fex.args[1].args[1].args[1]
#     rettype = fex.args[1].args[end]
#     # args = fex.args[1].args[1].args[2:end]
#     # argtypes = tuple([arg.args[2] for arg in args]...)
#     (f, rt, at) = (func, rettype, :(Int, Int))
#     # if !(isa(at, Expr) && at.head === :tuple)
#     #     throw(ArgumentError("@cfunction argument types must be a literal tuple"))
#     # end
#     at.head = :call
#     pushfirst!(at.args, GlobalRef(Core, :svec))
#     # if isa(f, Expr) && f.head === :$
#     #     fptr = f.args[1]
#     #     typ = CFunction
#     # else
#         fptr = QuoteNode(f)
#         typ = Ptr{Cvoid}
#     # end
#     cfun = Expr(:cfunction, typ, fptr, rt, at, QuoteNode(:ccall))
#     return esc(cfun)
# end

# # @cfunction1(callback1, Int, (Int, Int))

# # @cfunction1(callback1, Int, (Int, Int))

# function callback1(a::Int, b::Int)::Int
#     return a + b
# end

# @cfunction1 function callback2(a::Int, b::Int)::Int
#     return a + b
# end



# :($(Expr(:cfunction, Ptr{Nothing}, :(:callback1), :Int, :(Core.svec(Int, Int)), :(:ccall))))

# function callback1(a::Int, b::Int)::Int
#     return a + b
# end

# @macroexpand @cfunction(callback1, Int, (Int, Int))

# Works!
q1 = quote
    function callback1(a::Int, b::Int)::Int
        return a + b
    end
    @cfunction(:(:callback1), Int, (Int, Int))
end

eval(q1)



import Base.@cfunction

macro cfunction(fex::Expr)
    @assert fex.head == :function  # fex is a function definition 
    funcname = fex.args[1].args[1].args[1] |> String
    rettype = fex.args[1].args[end]
    args = fex.args[1].args[1].args[2:end]
    argtypes = [arg.args[2] for arg in args]
    argtypeexpr = Expr(:tuple, (argtypes...)) # types must be a litteral tuple for cfunction
    cfexp = :(@cfunction($funcname, $rettype, $argtypeexpr)) # the cfunction ptr
    return esc(Expr(:block, fex, cfexp)) 
end

# test
cf = @cfunction function callback3(a::Int, b::Int)::Int
    return a + b
end
