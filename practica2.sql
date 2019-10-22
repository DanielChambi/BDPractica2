-- comentario

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