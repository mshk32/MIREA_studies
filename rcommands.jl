using HorizonSideRobots
HSR = HorizonSideRobots

#ф-ии для инверсии направлений
inverse(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+2,4))
inverse(sides::Tuple{HorizonSide, HorizonSide}) = for side in sides HorizonSide(mod(Int(side)+2,4)) end

#метод ф-ии для перемещения по диагонали
function HSR.move!(robot, sides::Any)
    for s in sides
        move!(robot, s)
    end
end

#метод ф-ии для проверки границ при перемещении по диагонали
HSR.isborder(robot, side::Tuple{HorizonSide, HorizonSide}) = isborder(robot,side[1]) || isborder(robot, side[2])

#ф-я для передвижения робота до стенки
function along!(robot, side)::Nothing
    while !isborder(robot, side)
        move!(robot, side)
    end
end

#ф-я для передвижения робота на указанное кол-во шагов
function along!(robot, side, num_steps)::Nothing
    for _ in 1:num_steps
        move!(robot, side)
    end
end

#ф-я для передвижения робота до стенки, возвращающая пройденное расстояние
function numsteps_along!(robot, side)::Integer
    nsteps = 0
    while !isborder(robot, side)
        move!(robot, side)
        nsteps += 1
    end
    return nsteps
end

#ф-я для маркирования роботом клеток до стенки(кроме изначальной клетки робота), возвращает кол-во шагов
function mark_along!(robot, side)::Integer
    nsteps = 0
    while !isborder(robot, side)
        move!(robot, side)
        putmarker!(robot)
        nsteps += 1
    end
    return nsteps
end

#Маркирует ряд, включая клетку позиции робота
function mark_row!(robot, side)
    putmarker!(robot)
    while !isborder(robot, side)
        move!(robot, side)
        putmarker!(robot)
    end
end

#Задача №1
function Straight_cross!(robot)
    for side in (Nord, Ost, Sud, West)
        nsteps_side = mark_along!(robot, side)
        along!(robot, inverse(side), nsteps_side)
    end
    putmarker!(robot)
end 

#Задача №2
function Mark_perimeter!(robot)
    nsteps_sud = numsteps_along!(robot, Sud)
    nsteps_west = numsteps_along!(robot, West)
    for side in (Ost, Nord, West, Sud)
        mark_along!(robot, side)
    end
    along!(robot, Ost, nsteps_west)
    along!(robot, Nord, nsteps_sud)
end

#Задача №3
function Mark_all!(robot)
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
function X_cross!(robot)
    for side in (Tuple{Nord, West}, Tuple{Nord, Ost}, Tuple{Sud, Ost}, Tuple{Sud, West})
        nsteps_side = mark_along!(robot, side)
        along!(robot, inverse(side), nsteps_side)
    end
    putmarker!(robot)
end 