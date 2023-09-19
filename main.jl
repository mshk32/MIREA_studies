using HorizonSideRobots
include("rcommands.jl")

r = Robot("start.sit", animate=true)

find_marker!(r)