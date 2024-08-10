module IMisc
import Base.@kwdef

export Void, void, Maybe, @inlineref

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
    @inlineref 

Macro to extract ref expressions in a call expression as assignments in the local context.
eg

Given:

```
    function foo(a, b, out::Ref{Int})::Bool
        out[] = a + b
        return true
    end
```


Instead of:

```
    rout = Ref{Int}(0)
    res = foo(2, 3, rout)
```

Simply write:

```
    res = @inlineref foo(2, 3, rout = Ref{Int}(0))
```

"""
# Extract inline ref assignments
macro inlineref(inexpr::Expr)
    @assert inexpr.head == :call "Expression must be a function call"
    outexpr = Expr[]
    params = []
    for arg in inexpr.args[2:end]
        if typeof(arg) <: Expr && arg.head == :kw
            lhs = arg.args[1]
            push!(params, lhs)
            push!(outexpr, Expr(Symbol('='), lhs, arg.args[2]))
        else
            push!(params, arg)
        end
    end
    push!(outexpr, Expr(:call, inexpr.args[1], params...))
    return esc(Expr(:block, outexpr...))
end

end # module
