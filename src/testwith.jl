include("IMisc.jl")
using .IMisc

struct Win
    value::Int
end

function move(win::Win, x::Int, y::Int)::Win
    println("Move($(win.value)) $x $y")
    return win
end

function size(win::Win, w::Int, h::Int)::Win
    println("Size($(win.value)) $w $h")
    return win
end

function setVisible(win::Win, vis::Bool)::Win
    println("Visible($(win.value)) $vis")
    return win
end

win = Win(42)

@with win move(20, 20) size(30, 30)
@with win move(20, 20) 
@with win move(20, 20) size(30, 30) setVisible(false)

@with win begin
    move(40, 40)
    size(50, 50) 
    setVisible(false)
end

move(x::Int, y::Int) = (win) -> move(win, x, y)
size(x::Int, y::Int) = (win) -> size(win, x, y)
setVisible(vis::Bool) = (win) -> setVisible(win, vis)

win |> 
    move(11, 11) |> 
    size(22, 22) |> 
    setVisible(true)

