using .IMisc

struct Win
    value::Int
end

# macro with(param, exprs...)

# end

function move(win::Win, x::Int, y::Int)
    println("Move($(win.value)) $x $y")
end

function size(win::Win, w::Int, h::Int)
    println("Size($(win.value)) $w $h")
end

function setVisible(win::Win, vis::Bool)
    println("Visible($(win.value)) $vis")
end

win = Win(42)

macro with(param, exprs...)
    retexprs = Expr[]
    if length(exprs) == 1 && exprs[1].head == :block
        exprs = exprs[1].args
    else
        exprs = collect(exprs)
    end
    for expr in exprs
        if !(expr isa Expr) continue end
        if expr.head == :quote 
            expr = expr.args[1]
        end
        if expr.head == :call
            insert!(expr.args, 2, param)
            push!(retexprs, expr)
        end
    end
    return Expr(:block, retexprs...)
end

@with win :(move(10, 10)) :(size(20, 20)) :(setVisible(true))
@with win move(20, 20) size(30, 30)
@with win move(20, 20) 
@with win move(20, 20) size(30, 30) setVisible(false)

@with win begin
    :(move(30, 30)) 
    :(size(40, 40)) 
    :(setVisible(true))
end

@with win begin
    move(40, 40)
    size(50, 50) 
    setVisible(false)
end
