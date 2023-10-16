using HorizonSideRobots
HSR = HorizonSideRobots
include("rcommands.jl")

#Задача №1
function straight_cross!(robot)
    for side in (Nord, Ost, Sud, West)
        nsteps_side = mark_along!(robot, side)
        along!(robot, inverse(side), nsteps_side)
    end
    putmarker!(robot)
end 

#Задача №2
function mark_perimeter!(robot)
    nsteps_sud = numsteps_along!(robot, Sud)
    nsteps_west = numsteps_along!(robot, West)
    for side in (Ost, Nord, West, Sud)
        mark_along!(robot, side)
    end
    along!(robot, Ost, nsteps_west)
    along!(robot, Nord, nsteps_sud)
end

#Задача №3
function mark_all!(robot)
    nsteps_sud = numsteps_along!(robot, Sud)
    nsteps_west = numsteps_along!(robot, West)
    side = Ost
    mark_row!(robot, side)
    while !isborder(robot, Nord) 
        move!(robot, Nord)
        side = inverse(side)
        mark_row!(robot, side)
    end
    along!(robot, West)
    along!(robot, Sud)
    along!(robot, Ost, nsteps_west)
    along!(robot, Nord, nsteps_sud)
end

#Задача №4
function x_cross!(robot)
    for side in ((Nord, West), (Nord, Ost), (Sud, Ost), (Sud, West))
        nsteps_side = mark_along!(robot, side)
        along!(robot, inverse(side), nsteps_side)
    end
    putmarker!(robot)
end




#Задача №5
function mark_external_internal!(robot)
    back_path = move_to_angle!(robot)
    mark_perimeter!(robot)
    find_internal_border!(robot)
    move_to_internal_sudwest!(robot)
    mark_internal_perimetr!(robot)
    along!(robot, Sud)
    along!(robot, West)
    move_back!(robot, back_path)
end

#Задача №7
function find_hole!(robot)
    side = Ost
    n = 0
    while isborder(robot, Nord)
        n += 1
        side = inverse(side)
        along!(robot, side, n)
    end
    move!(robot, Nord)
    along!(robot, inverse(side), (n+1)/2)
end

#Задача №8
function find_marker!(robot)
    side = Nord
    num_steps = 1
    while !ismarker(robot)
        find_marker_along!(robot, side, num_steps)
        side = left(side)
        find_marker_along!(robot, side, num_steps)
        side = left(side)
        num_steps += 1
    end
end

#Задача №9
function chess_mark!(robot)
    nsteps_Sud = numsteps_along!(robot, Sud)
    nsteps_West = numsteps_along!(robot, West)
    is_marker_needed::Bool = false
    if (nsteps_Sud + nsteps_West) % 2 == 0
        is_marker_needed = true
    end
    side = Ost
    while !isborder(robot, Nord)
        is_marker_needed = chess_row_mark!(robot, side, is_marker_needed)
        move!(robot, Nord)
        side = inverse(side)
    end
    chess_row_mark!(robot, side, is_marker_needed)
    along!(robot, Sud)
    along!(robot, West)
    along!(robot, Ost, nsteps_West)
    along!(robot, Nord, nsteps_Sud)
end
