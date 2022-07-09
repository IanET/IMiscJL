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
    @gensym tres vals
    return esc(
        quote 
            $tres = $retrefs_impl($func, $(args...))
            $vals = Tuple([r[] for r in $tres[begin:end-1]])
            ($vals..., $tres[end])
        end
    )
end


# """
#     GUID 
# """
# struct GUID
#     Data1::Culong
#     Data2::Cushort
#     Data3::Cushort
#     Data4::NTuple{8, UInt8}
# end

# # Guid of form 12345678-0123-5678-0123-567890123456
# macro guid_str(s)
#     parse_hexbytes(s::String) = parse(UInt8, s, base = 16)
#     GUID(parse(Culong, s[1:8], base = 16),   # 12345678
#         parse(Cushort, s[10:13], base = 16), # 0123
#         parse(Cushort, s[15:18], base = 16), # 5678
#         (parse_hexbytes(s[20:21]),           # 0123
#             parse_hexbytes(s[22:23]), 
#             parse_hexbytes(s[25:26]),        # 567890123456
#             parse_hexbytes(s[27:28]), 
#             parse_hexbytes(s[29:30]), 
#             parse_hexbytes(s[31:32]), 
#             parse_hexbytes(s[33:34]), 
#             parse_hexbytes(s[35:36])))
# end

end # module
