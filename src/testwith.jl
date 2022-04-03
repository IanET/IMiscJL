include("IMisc.jl")
using .IMisc

mutable struct Win
    id::Int
    x::Int
    y::Int
    w::Int
    h::Int
    visible::Bool
end

Win(id::Int)::Win = Win(id, 0, 0, 0, 0, false)

function move(win::Win, x::Int, y::Int)::Win
    win.x = x
    win.y = y
    # dump(win)
    return win
end

function size(win::Win, w::Int, h::Int)::Win
    win.w = w
    win.h = h
    # dump(win)
    return win
end

function setVisible(win::Win, vis::Bool)::Win
    win.visible = vis
    # dump(win)
    return win
end

win = Win(42)

@with win move(20, 20) size(30, 30)
@with win move(20, 20) 
@with win move(20, 20) size(30, 30) setVisible(false)

function testWithBegin()
    @with win begin
        move(40, 40)
        size(50, 50) 
        setVisible(false)
    end
end

testWithBegin()

move(x, y) = (win) -> move(win, x, y)
size(w, h) = (win) -> size(win, w, h)
setVisible(vis) = (win) -> setVisible(win, vis)

function testPipe()
    win |> 
        move(11, 12) |> 
        size(22, 23) |> 
        setVisible(true)
end

testPipe()
