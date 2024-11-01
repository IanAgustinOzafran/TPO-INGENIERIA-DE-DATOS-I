CREATE TABLE Sala (
    idSala INT PRIMARY KEY,
    tipoSala VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0)
);
go

CREATE TABLE Pelicula (
    idPelicula INT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    duracion INT NOT NULL CHECK (duracion > 0), -- La duración debe ser positiva
    clasificacion VARCHAR(20) NOT NULL
);
go

CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE --Para evitar mail duplicado
);
go

CREATE TABLE Funcion (
    idFuncion INT PRIMARY KEY,
    idSala INT NOT NULL,
    idPelicula INT NOT NULL,
    fechaHora DATETIME NOT NULL,
    FOREIGN KEY (idSala) REFERENCES Sala(idSala), 
    FOREIGN KEY (idPelicula) REFERENCES Pelicula(idPelicula) 
);

go

CREATE TABLE Entrada (
    idEntrada INT PRIMARY KEY,
    idFuncion INT NOT NULL,
    idCliente INT NOT NULL,
    asiento VARCHAR(10) NOT NULL,
    precio DECIMAL(8, 2) NOT NULL CHECK (precio >= 0), -- Precio no puede ser negativo
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0), -- Cantidad de entradas debe ser al menos 1
    FOREIGN KEY (idFuncion) REFERENCES Funcion(idFuncion), 
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

go

