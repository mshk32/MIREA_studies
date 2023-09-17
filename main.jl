using HorizonSideRobots
include("rcommands.jl")

r = Robot("temp.sit", animate=true)

mark_external_internal!(r)