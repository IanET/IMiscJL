module IMisc

"""
    Void

A type with no fields that is the type of void. Anything can be converted to type Void
"""
struct Void end

const void = Void()
Void(x::Any) = void
Base.convert(::Type{Void}, x::Any) = void
Base.convert(::Type{Void}, v::Void) = void

end # module
