-- Creacion de tablas

CREATE TABLE tematica(
	id INTEGER UNIQUE NOT NULL,
    nombre VARCHAR(250),
    PRIMARY KEY(id)
);

CREATE TABLE color(
	id INTEGER UNIQUE NOT NULL,
	nombre VARCHAR(250),
    rgb VARCHAR(6),
    es_transparente VARCHAR(1),
    PRIMARY KEY(id)
);

CREATE TABLE categoria(
	id INTEGER UNIQUE NOT NULL,
    nombre VARCHAR(250),
    PRIMARY KEY(id)
);

CREATE TABLE `set`(
	num_set INTEGER UNIQUE NOT NULL,
    nombre VARCHAR(250),
    `año` INTEGER,
    tematica INTEGER,
    PRIMARY KEY(num_set),
    CONSTRAINT
		FOREIGN KEY(tematica)
        REFERENCES tematica(id)
        ON UPDATE CASCADE
);

CREATE TABLE pieza(
	num_pieza INTEGER UNIQUE NOT NULL,
    nombre VARCHAR(250),
    categoria INTEGER NOT NULL,
    PRIMARY KEY(num_pieza),
    CONSTRAINT
		FOREIGN KEY(categoria)
        REFERENCES categoria(id)
        ON UPDATE CASCADE
);

CREATE TABLE contiene(
	num_pieza INTEGER NOT NULL,
    num_set INTEGER NOT NULL,
    color INTEGER NOT NULL,
    cantidad INTEGER,
    PRIMARY KEY(num_pieza, num_set, color),
    CONSTRAINT
		FOREIGN KEY(num_pieza)
        REFERENCES pieza(num_pieza)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
        FOREIGN KEY(num_set)
        REFERENCES `set`(num_set)
        ON UPDATE CASCADE,
        FOREIGN KEY(color)
        REFERENCES color(id)
        ON UPDATE CASCADE
);

drop table contiene;

-- Consultas

-- 1
select categoria, count(*)
from pieza
group by categoria;
-- TODAS LAS CATEGORÍAS
-- 2

select *
from `set`
where `año` > 2000 and tematica is null;

-- 3
select `set`.num_set, nombre, cantidad
from `set`, contiene
where `set`.num_set = contiene.num_set
group by `set`.num_set
order by cantidad;
-- 4

select nombre
from color
where color.id not in(select color
					  from contiene);

-- 5
select color.nombre
from color join contiene on color.id = contiene.color join `set` on contiene.num_set= `set`.num_set
where año = 2016 and año not in (2017);
-- 6

select `set`.nombre, `set`.`año`
from `set` join tematica on `set`.tematica = tematica.id
where tematica.nombre like "r%"
order by `set`.nombre;

-- 7
-- Identificar categoria por id o nombre
select distinct categoria
from pieza natural join contiene join `set` on contiene.num_set = `set`.num_set
where `set`.año between 2001 and 2003 and contiene.color not in (select id
																from color 
                                                                where nombre like 'Red');
-- 8

select color.nombre
from contiene natural join `set` join color on contiene.color = color.id
where num_set in (select num_set
				  from contiene
				  group by num_set
				  having sum(cantidad) > 4)
and tematica in (select id
				 from tematica
				 where nombre like "Jurassic World"
				 or nombre like "The Hobbit")
group by color.nombre;

-- 9
select distinct tematica
from `set`
where num_set in ( select distinct num_set 
					from contiene 
                    where num_pieza in (select num_pieza 
										from pieza natural join contiene join color on contiene.color=color.id
                                        where es_transparente = 't'));
-- 10

select num_set, `set`.nombre, count(distinct num_pieza)
from contiene natural join `set`
group by num_set, `set`.nombre
having count(distinct num_pieza) >= all(select count(distinct num_pieza)
									   from contiene
									   group by num_set);
                                       
-- 11
select nombre
from pieza natural join contiene
where color in (select color.id
					from color 
					where nombre like '%Green%' and es_transparente = 't');

-- 12

select num_pieza, pieza.nombre, count(distinct color)
from contiene natural join pieza
group by num_pieza, pieza.nombre
having count(distinct color) >= 2;

-- 13
select distinct categoria.nombre
from categoria join pieza on categoria.id=pieza.categoria
natural join contiene join `set` on contiene.num_set=`set`.num_set
where `año` =  (select max(`año`)
					from `set` );
-- 14

select num_set, num_pieza, `set`.nombre, count(*)
from contiene natural join `set` 
group by num_set, num_pieza, `set`.nombre
having count(*) > 1;

-- 15
select color.rgb, categoria.nombre categoria, tematica.nombre tematica
from color join contiene on color.id=contiene.color
join `set` on contiene.num_set=`set`.num_set join tematica on `set`.tematica=tematica.id
join pieza on contiene.num_pieza=pieza.num_pieza join  categoria on pieza.categoria=categoria.id
where `set`.num_set in (select num_set
						from contiene
						group by num_set
						having sum(cantidad) >= all(select sum(cantidad)
													from contiene
													group by num_set)
						or sum(cantidad) <= all(select sum(cantidad)
												from contiene
												group by num_set));
-- Set mayor num piezas = mayor cantidad group by set
select max(suma), num_set
from (select sum(cantidad) suma, num_set
from contiene
group by num_set
order by sum(cantidad) desc) cantidades;

select min(suma), num_set
from (select sum(cantidad) suma, num_set
from contiene
group by num_set
order by sum(cantidad) asc) cantidades;

-- Procedimientos y funciones

-- 1
delimiter &&
create procedure SetsPorTematicaAnio(in tematica_in integer, in año_in integer)
begin
select `set`.nombre, sum(cantidad)
from `set` natural join contiene 
where tematica = tematica_in and año = año_in
group by contiene.num_set;
end&&
delimiter ;

call SetsPorTematicaAnio(4, 2003)
-- 2

delimiter &&
create procedure NumPiezasEnSet(in nombre_set varchar(250))
begin
	select num_set, nombre, sum(cantidad) cantidad_piezas, count(distinct color) colores_distintos
    from `set` natural join contiene
    where `set`.nombre = nombre_set
    group by `set`.nombre, num_set;
end&&
delimiter ;

-- 3

-- Triggers

-- 1

-- 2
CREATE TABLE bajas(
	num_pieza INTEGER UNIQUE NOT NULL,
    colores INTEGER,
    sets INTEGER,
    PRIMARY KEY(num_pieza)
);

set @sets = 0;

select count(distinct num_set), count(distinct color)
from contiene
where num_pieza = 3
group by(num_pieza);



delimiter &&
create trigger dlt_pieza
before delete on pieza
for each row
begin
	

end&&

delimiter ;


delete from pieza where num_pieza = 0;

