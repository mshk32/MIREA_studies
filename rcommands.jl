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

"""
Решение Задачи№5 закончено.
"""


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
end


#Задача №9
function chess_mark!(robot)
    nsteps = numsteps_along!(robot, Sud)
    nsteps += numsteps_along!(robot, West)
    is_marker_needed::Bool = false
    if nsteps % 2 == 0
        is_marker_needed = true
    end
    side = Ost
    while !isborder(robot, Nord)
        chess_row_mark!(robot, side, is_marker_needed)
        move!(robot, Nord)
        side = inverse(side)
        is_marker_needed = !is_marker_needed
    end
    chess_row_mark!(robot, side, is_marker_needed)
end


