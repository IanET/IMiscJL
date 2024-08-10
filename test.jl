include("src/IMisc.jl")

using .IMisc

function f1(a::Int, b::Int, c::Ref{Int})::Bool
    c[] = a + b
    return true
end

# macro m1(fexp::Expr)
#     return fexp
# end

# res = Ref{Int}(0)
# @m1 f1(1, 2, res)

# @macroexpand @m1 f1(1, 2, res)

macro m2(fex::Expr)
    func = fex.args[1]
    args = fex.args[2:end]
    # @info "m2" func args
    retexprs = Expr[]
    params = []
    for arg in args
        if typeof(arg) <: Expr && arg.head == :kw
            # dump(arg)
            lhs = arg.args[1]
            push!(params, lhs)
            rhs = arg.args[2]
            push!(retexprs, Expr(Symbol('='), lhs, rhs))
            dump(exp)
        else
            push!(params, arg)
        end
    end
    # dump(params)
    push!(retexprs, Expr(:call, func, params...))
    expr = Expr(:block, retexprs...)
    dump(expr)
    return esc(expr)
end

@m2 f1(2, 3, res = Ref{Int}(0))

@macroexpand @m2 f1(2, 3, res = Ref{Int}(0))


quote
    res = Ref{Int}(0)
    f1(1, 2, res)
end |> dump


@m2 f1(1, 2, res)

@m2 f1(1, 2, Ref{Int}(0))

quote
    res = Ref{Int}(0)
    f1(1, 2, res)
end |> dump