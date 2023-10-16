using HorizonSideRobots
HSR = HorizonSideRobots


#ф-ии для изменения направлений
inverse(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+2,4))
inverse(direct::Tuple{HorizonSide, HorizonSide}) = inverse.(direct)
right(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+3,4))
left(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+1,4))

#метод ф-ии для перемещения по диагонали
function HSR.move!(robot, sides::Any)
    for s in sides
        move!(robot, s)
    end
end

#Попытка передвинуться, если нет границы
try_move!(robot, side) = 
    if isborder(robot, side)
        return false
    else
        move!(robot, side)
        return true
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

#Ищет маркер по пути робота. Маркера нет - проходит максимум шагов
function find_marker_along!(robot, side, max_num_steps)
    num_steps = 0
    while num_steps < max_num_steps && !ismarker(robot)
        move!(robot, side)
        num_steps += 1
    end
end

#Маркирует ряд, включая клетку позиции робота
function mark_row!(robot, side)
    putmarker!(robot)
    while !isborder(robot, side)
        move!(robot, side)
        putmarker!(robot)
    end
end     

"""
Далее идет реализация Задачи№5 и функций для нее.
Ее решение исключительно через сторонние функции,
полезность которых в будущем достаточно сомнительна, мне не нравится.
Часть вспомогательных ф-й я бы реализовал в самой задаче.
Но не уверен, насколько я прав.
"""

#Перемещает робота в юго-западный угол (актуально только для Задачи№5)
function move_to_angle!(robot)
    p1 = (side=Nord, nsteps=numsteps_along!(robot, Sud))
    p2 = (side=Ost, nsteps=numsteps_along!(robot, West))
    p3 = (side=Nord, nsteps=numsteps_along!(robot, Sud))
    return p3, p2, p1
end

function find_internal_border!(robot)
    side = Ost
    while !isborder(robot, Nord)#Сделать доп функцию для перемещения змейкой?
        if isborder(robot, side)
            move!(robot, Nord)
            side = inverse(side)
        end
        move!(robot, side)
    end
end

function move_to_internal_sudwest!(robot)
    while isborder(robot, Nord)
        move!(robot, West)
    end
end

function mark_internal_perimetr!(robot)
    for side in (Nord, Ost, Sud, West)
        move!(robot, side)
        putmarker!(robot)
        while isborder(robot, right(side))
            move!(robot, side)
            putmarker!(robot)
        end
    end
end

function move_back!(robot, back_path)
    for path_part in back_path
        along!(robot, path_part.side, path_part.nsteps)
    end
end

"""
Решение Задачи№5 закончено.
"""

#ф-я маркирует клетки через одну,
#третий аргумент показывает, маркировать ли с первой клетки
function chess_row_mark!(robot, side, mark_first_square)
    is_marker = mark_first_square
    while !isborder(robot, side)
        if is_marker
            putmarker!(robot)
        end
        is_marker = !is_marker
        move!(robot, side)
    end
    if is_marker
        putmarker!(robot)
    end
    return !is_marker
end


#Функции высшего порядка
along!(stop_condition::Function, robot, side) = 
    while stop_condition() == false && try_move!(robot, side) end

function numsteps_along!(stop_condition::Function, robot, side)
    n = 0
    while stop_condition() == false && try_move!(robot, side)
        n += 1
    end
    return n
end

function snake!(stop_condition::Function, robot; start_side, ortogonal_side)
    s = start_side
    along!(robot, s) do 
        stop_condition() || isborder(robot, s)
    end
    while !stop_condition() && try_move!(robot, ortogonal_side)
        s = inverse(s)
        along!(robot, s) do 
            stop_condition() || isborder(robot, s)
        end
    end
end

snake!(robot; start_side, ortogonal_side) = 
    snake!(() -> false, robot; start_side, ortogonal_side)

function shatl!(stop_condition::Function, robot; start_side)
    s = start_side
    n = 0
    while stop_condition() == false
        n += 1
        move!(robot, s, n)
        s = inverse(s)
    end
    return (n+1)÷2 
end

function spiral!(stop_condition::Function, robot; start_side = Nord, nextside::Function = left)
    side = start_side
    n = 0
    while stop_condition() == false
        if iseven(n)
            n += 1
        end
        move!(stop_condition, robot, side, num_maxsteps = n)
        side = nextside(side)
        move!(stop_condition, robot, side, num_maxsteps = n)
        side = nextside(side)
    end
end

function HorizonSideRobots.move!(stop_condition::Function, robot, side; num_maxsteps::Integer)
    n = 0
    while n < num_maxsteps && stop_condition() == false
        n += 1
        move!(robot, side)
    end
    return n
end

#Тип абстрактного робота
abstract type AbstractRobot end
HSR.move!(robot::AbstractRobot, side) = move!(get_baserobot(robot), side)
HSR.isborder(robot::AbstractRobot, side) = isborder(get_baserobot(robot), side)
HSR.putmarker!(robot::AbstractRobot) = putmarker!(get_baserobot(robot))
HSR.ismarker(robot::AbstractRobot) = ismarker(get_baserobot(robot))
HSR.temperature(robot::AbstractRobot) = temperature(get_baserobot(robot))



mutable struct CountmarkersRobot <: AbstractRobot
    robot::Robot
    num_markers::Int64
end
 
get_baserobot(robot::CountmarkersRobot) = robot.robot

function HSR.move!(robot::CountmarkersRobot, side) 
    move!(robot.robot, side)
    if ismarker(robot)
        robot.num_markers += 1
    end
    nothing
end


#Определение типа координатного робота

mutable struct RobotCoordinates
    x::Int
    y::Int
end
get_coords(coords::RobotCoordinates) = (coords.x, coords.y)

struct CoordsRobot <: AbstractRobot
    robot::Robot
    coords::RobotCoordinates
end

function НоrizonSideRobots.move!(robot::CoordsRobot, side)
    move!(robot.robot, side)
    move!(robot.coord, side)
end

get_coords(crobot::CoordsRobot) = get_coords(crobot.coords)
get_base_robot(crobot::CoordsRobot) = crobot.robot
