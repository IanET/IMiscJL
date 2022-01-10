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

Substitute first param in a series of calls. \n
For example:
```    
    @with window begin 
        move(0, 0) 
        size(640, 480) 
        setVisible(true) 
    end 
```
Is syntactic sugar for:
```
    move(window, 0, 0) 
    size(window, 640, 480) 
    setVisible(window, true) 
```
"""
macro with(param, exprs...)
    modcalls(param, isblock(exprs) ? exprs[1].args : collect(exprs))
    return esc(Expr(:block, exprs...))
end

isblock(exprs) = (length(exprs) == 1) && (exprs[1] isa Expr) && (exprs[1].head == :block)
iscall(expr) = (expr isa Expr) && (expr.head == :call)

# Modify calls to insert param first
function modcalls(param, exprs)
    for expr in exprs
        iscall(expr) && insert!(expr.args, 2, param)
    end
end

end # module
