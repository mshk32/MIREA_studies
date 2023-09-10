using HorizonSideRobots

inverse(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+2,4))

function along!(robot, side)::Nothing
    while !isborder(robot, side)
        move!(robot, side)
    end
end

function along!(robot, side, num_steps)::Nothing
    for _ in 1:num_steps
        move!(robot, side)
    end
end

function mark_along!(robot, side)::Integer
    nsteps = 0
    while !isborder(robot, side)
        move!(robot, side)
        putmarker!(robot)
        nsteps += 1
    end
    return nsteps
end

function Straight_cross!(robot)
    for side in (Nord, Ost, Sud, West)
        nsteps_side = mark_along!(robot, side)
        along!(robot, inverse(side), nsteps_side)
    end
    putmarker!(robot)
end 

