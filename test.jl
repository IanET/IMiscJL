include("src/IMisc.jl")

using .IMisc

function f1(a::Int, b::Int, c::Ref{Int})::Bool
    c[] = a + b
    return true
end

function f2(a::Int, b::Int, c::Ref{Int}, d::Ref{Int})::Bool
    c[] = a + b
    d[] = a - b
    return false
end

function f3(a::Int, b::Int)
    return a + b
end

function f4()
    return 42
end

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

function test()
    res = @inlineref f1(2, 3, out = Ref{Int}(0))
    @info res out[]

    res = @inlineref f2(2, 3, out1 = Ref{Int}(1), out2 = Ref{Int}(2))
    @info res out1[] out2[]

    @info @inlineref f3(1, 2)

    @info @inlineref f4()

end

test()