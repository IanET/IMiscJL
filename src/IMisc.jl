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
    @with 

Macro to substitute first param in a series of expressions.
Eg
    @with win move(0,0) size(640, 480) setVisible(true)
"""


end # module
