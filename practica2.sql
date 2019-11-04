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
        ON UPDATE CASCADE,
        FOREIGN KEY(num_set)
        REFERENCES `set`(num_set)
        ON UPDATE CASCADE,
        FOREIGN KEY(color)
        REFERENCES color(id)
        ON UPDATE CASCADE
);

-- Consultas

-- 1
select count(*)
from pieza
where categoria = '1';
-- TODAS LAS CATEGORÍAS
-- 2

select *
from `set`
where `año` > 2000 and tematica is null;

-- 3
select nombre, cantidad
from `set`, contiene
where `set`.num_set = contiene.num_set
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
select distinct categoria.nombre
from categoria join pieza on categoria.id = pieza.categoria join contiene on pieza.num_pieza = contiene.num_pieza 
join `set` on contiene.num_pieza = `set`.num_set join color on contiene.color = color.id
where año between 2001 and 2003 and color.id not in ( select nombre
														  from color 
														  where nombre ='Red');
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
select distinct tematica.nombre
from tematica join `set` on tematica.id = `set`.tematica join contiene on `set`.num_set=contiene.num_set
where contiene.color = any( select id
							from color
                            where es_transparente = 't');

-- 10

select num_set, `set`.nombre, count(distinct num_pieza)
from contiene natural join `set`
group by num_set, `set`.nombre
having count(distinct num_pieza) >= all(select count(distinct num_pieza)
									   from contiene
									   group by num_set);
                                       
-- 11
select nombre 
from pieza join contiene on pieza.num_pieza = contiene.num_pieza
where color = any (select color.id
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
join contiene on pieza.num_pieza=contiene.num_pieza
join `set` on contiene.num_set=`set`.num_set
where año =  (select max(año)
					from `set` );

-- 14

select num_set, num_pieza, `set`.nombre, count(*)
from contiene natural join `set` 
group by num_set, num_pieza, `set`.nombre
having count(*) > 1;

-- 15
select color.rgb, categoria.nombre, tematica.nombre, contiene.cantidad
from color join contiene on color.id=contiene.color
join `set` on contiene.num_set=`set`.num_set join tematica on `set`.tematica=tematica.id
join pieza on contiene.num_pieza=pieza.num_pieza join  categoria on pieza.categoria=categoria.id
where cantidad = (select max(cantidad) from contiene)
or cantidad = (select min(cantidad) from contiene)
order by cantidad;
