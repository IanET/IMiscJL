module IMisc
import Base.@kwdef

export Void, void, @kwdef, Maybe, @with

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
    @with 

Macro to substitute first param in a series of calls.
Eg
```    
    @with window begin 
        move(0,0) 
        size(640, 480) 
        setVisible(true) 
    end 
```
"""
macro with(param, exprs...)
    if length(exprs) == 1 && exprs[1] isa Expr && exprs[1].head == :block
        modcalls(param, exprs[1].args)
    else
        modcalls(param, collect(exprs))
    end
    return Expr(:block, exprs...)
end

# Modify calls to insert param first
function modcalls(param, exprs)
    for expr in exprs
        if expr isa Expr && expr.head == :call
            insert!(expr.args, 2, param)
        end
    end
end


end # module
