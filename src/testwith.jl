include("IMisc.jl")
using .IMisc

struct Win
    value::Int
end

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

@with win move(20, 20) size(30, 30)
@with win move(20, 20) 
@with win move(20, 20) size(30, 30) setVisible(false)

@with win begin
    move(40, 40)
    size(50, 50) 
    setVisible(false)
end
