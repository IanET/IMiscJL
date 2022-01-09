using .IMisc

struct Win
    value::Int
end

# macro with(param, exprs...)

# end

function move(win::Win, x::Int, y::Int)
    println("Move $(win.value) $x $y")
end

function size(win::Win, w::Int, h::Int)
    println("Size $(win.value) $w $h")
end

function setVisible(win::Win, vis::Bool)
    println("Visible $(win.value) $vis")
end

win = Win(42)

# @with(win, move(10, 10), size(640, 480))

macro with(param, exprs...)
    # @show param
    retexprs = Expr[]
    # dump(exprs)
    if length(exprs) == 1 && exprs[1].head == :block
        exprs = exprs[1].args
    else
        exprs = collect(exprs)
    end
    # dump(exprs)
    for expr in exprs
        if expr isa LineNumberNode continue end
        if expr.head == :quote 
            expr = expr.args[1]
        end
        # @show expr
        dump(expr)
        insert!(expr.args, 2, param)
        # dump(expr)
        push!(retexprs, expr)
    end
    # dump(retexprs)
    return Expr(:block, retexprs...)
end

@with win :(move(10, 10)) :(size(20, 20)) :(setVisible(true))

@with win begin
    :(move(10, 10)) 
    :(size(20, 20)) 
    :(setVisible(true))
end

@with win begin
    move(10, 10)
    size(20, 20) 
    setVisible(true)
end

# @with(win, move(win, 10, 10))
# @with win :(move(10, 10))

