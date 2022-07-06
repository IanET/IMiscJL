module IMisc
import Base.@kwdef

export Void, void, @kwdef, Maybe

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


"""
    @retrefs 

Macro to capture ref arguments in a call expression and return their values in a tuple along with the function return value
Effectively emulating [out] params common in ccall without needing to manually pre-create the references

eg

Given:

function foo(r::Ref{Int})::Bool
    r[] += 1
    return true
end


Instead of:

function wrapfoo()
    r = Ref(Int(0))
    retval = foo(r)
    return r, retval
end

Simply write:

result = @retrefs foo(Int(0))

"""
macro retrefs(fex::Expr)
    @assert fex.head == :call "Expression must be a function call"
    func = fex.args[1]
    args = fex.args[2:end]
    return esc(
        quote 
            @gensym tres vals
            tres = _retrefs_impl($func, $(args...))
            vals = Tuple([r[] for r in tres[begin:end-1]])
            (vals..., tres[end])
        end
    )
end

@generated function _retrefs_impl(f::Function, args...)
    refargexps = Expr[]
    for i in eachindex(args)
        if args[i] <: Base.RefValue
            push!(refargexps, :(args[$i]))
        end
    end
    return Expr(:tuple, refargexps..., :(f(args...)))
end



end # module
