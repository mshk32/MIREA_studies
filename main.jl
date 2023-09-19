using HorizonSideRobots
include("rcommands.jl")

r = Robot("temp.sit", animate=true)

find_hole!(r)