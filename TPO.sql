CREATE TABLE Sala (
    idSala INT IDENTITY(1,1) PRIMARY KEY,
    tipoSala VARCHAR(50) NOT NULL,
    capacidadSala INT NOT NULL CHECK (capacidadSala > 0)
);
go

CREATE TABLE Pelicula (
    idPelicula INT IDENTITY(1,1) PRIMARY KEY,
    tituloPelicula VARCHAR(100) NOT NULL,
    generoPelicula VARCHAR(50) NOT NULL,
    duracionPelicula INT NOT NULL CHECK (duracionPelicula > 0),
    clasificacionPelicula VARCHAR(20) NOT NULL
);
go

-- Trigger para validar que la duración de una película sea mayor a 30 minutos
CREATE TRIGGER trg_validar_duracion_pelicula
ON Pelicula
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE duracionPelicula < 30)
    BEGIN
        RAISERROR ('La duración de la película debe ser de al menos 30 minutos.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    nombreCliente1 VARCHAR(50) NOT NULL,
    nombreCliente2 VARCHAR(50), 
    apellidoCliente1 VARCHAR(50) NOT NULL,
    apellidoCliente2 VARCHAR(50),
    telefonoCliente VARCHAR(20),
    emailCliente VARCHAR(100) UNIQUE -- Para evitar emails duplicados
);
go

CREATE TABLE Funcion (
    idFuncion INT IDENTITY(1,1) PRIMARY KEY,
    idSala INT NOT NULL,
    idPelicula INT NOT NULL,
    fechaHoraFuncion DATETIME NOT NULL,
    FOREIGN KEY (idSala) REFERENCES Sala(idSala),
    FOREIGN KEY (idPelicula) REFERENCES Pelicula(idPelicula)
);
go
-- Trigger para inicializar capacidadDisponible en la función igual a la capacidad de la sala
CREATE TRIGGER trg_set_capacidad_disponible
ON Funcion
AFTER INSERT
AS
BEGIN
    UPDATE f
    SET f.capacidadDisponible = s.capacidadSala
    FROM Funcion f
    JOIN inserted i ON f.idFuncion = i.idFuncion
    JOIN Sala s ON s.idSala = i.idSala;
END;
GO


CREATE TABLE Entrada (
    idEntrada INT IDENTITY(1,1) PRIMARY KEY,
    idFuncion INT NOT NULL,
    idCliente INT NOT NULL,
    precioEntrada DECIMAL(8, 2) NOT NULL CHECK (precioEntrada >= 0), 
    cantidadEntradas INT NOT NULL CHECK (cantidadEntradas > 0),
    FOREIGN KEY (idFuncion) REFERENCES Funcion(idFuncion),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);
go


CREATE TABLE Asiento (
    idAsiento INT IDENTITY(1,1) PRIMARY KEY,
    idEntrada INT NOT NULL,
    asiento VARCHAR(10) NOT NULL, -- El número o identificador del asiento (por ejemplo, A1, B2)
    FOREIGN KEY (idEntrada) REFERENCES Entrada(idEntrada)
);
go
-- Stored procedures de Sala
-- CREATE: Insertar una nueva sala
CREATE PROCEDURE InsertarSala (
    @tipoSala VARCHAR(50),
    @capacidadSala INT
)
AS
BEGIN
    INSERT INTO Sala (tipoSala, capacidadSala)
    VALUES (@tipoSala, @capacidadSala);
END;
go

-- READ: Obtener todas las salas
CREATE PROCEDURE ObtenerSalas
AS
BEGIN
    SELECT idSala, tipoSala, capacidadSala
    FROM Sala;
END;
go

-- UPDATE: Actualizar una sala existente
CREATE PROCEDURE ActualizarSala (
    @idSala INT,
    @tipoSala VARCHAR(50),
    @capacidadSala INT
)
AS
BEGIN
    UPDATE Sala
    SET tipoSala = @tipoSala, capacidadSala = @capacidadSala
    WHERE idSala = @idSala;
END;
GO

--Stored procedures para Pelicula
-- CREATE: Insertar una nueva película
CREATE PROCEDURE InsertarPelicula (
    @tituloPelicula VARCHAR(100),
    @generoPelicula VARCHAR(50),
    @duracionPelicula INT,
    @clasificacionPelicula VARCHAR(20)
)
AS
BEGIN
    INSERT INTO Pelicula (tituloPelicula, generoPelicula, duracionPelicula, clasificacionPelicula)
    VALUES (@tituloPelicula, @generoPelicula, @duracionPelicula, @clasificacionPelicula);
END;
go
    

-- READ: Obtener todos los datos de películas
CREATE PROCEDURE ObtenerPeliculas
AS
BEGIN
    SELECT idPelicula, tituloPelicula, generoPelicula, duracionPelicula, clasificacionPelicula
    FROM Pelicula;
END;
go

-- UPDATE: Actualizar una película existente
CREATE PROCEDURE ActualizarPelicula (
    @idPelicula INT,
    @tituloPelicula VARCHAR(100),
    @generoPelicula VARCHAR(50),
    @duracionPelicula INT,
    @clasificacionPelicula VARCHAR(20)
)
AS
BEGIN
    UPDATE Pelicula
    SET tituloPelicula = @tituloPelicula,
        generoPelicula = @generoPelicula,
        duracionPelicula = @duracionPelicula,
        clasificacionPelicula = @clasificacionPelicula
    WHERE idPelicula = @idPelicula;
END;
GO

-- Stored Procedures para Cliente
-- CREATE: Insertar un nuevo cliente
CREATE PROCEDURE InsertarCliente (
    @nombreCliente1 VARCHAR(50),
    @nombreCliente2 VARCHAR(50),
    @apellidoCliente1 VARCHAR(50),
    @apellidoCliente2 VARCHAR(50),
    @telefonoCliente VARCHAR(20),
    @emailCliente VARCHAR(100)
)
AS
BEGIN
    INSERT INTO Cliente (nombreCliente1, nombreCliente2, apellidoCliente1, apellidoCliente2, telefonoCliente, emailCliente)
    VALUES (@nombreCliente1, @nombreCliente2, @apellidoCliente1, @apellidoCliente2, @telefonoCliente, @emailCliente);
END;
go

-- READ: Obtener todos los clientes
CREATE PROCEDURE ObtenerClientes
AS
BEGIN
    SELECT idCliente, nombreCliente1, nombreCliente2, apellidoCliente1, apellidoCliente2, telefonoCliente, emailCliente
    FROM Cliente;
END;
go

-- Actualizar un cliente
CREATE PROCEDURE ActualizarCliente (
    @idCliente INT,
    @nombreCliente1 VARCHAR(50),
    @nombreCliente2 VARCHAR(50),
    @apellidoCliente1 VARCHAR(50),
    @apellidoCliente2 VARCHAR(50),
    @telefonoCliente VARCHAR(20),
    @emailCliente VARCHAR(100)
)
AS
BEGIN
    UPDATE Cliente
    SET nombreCliente1 = @nombreCliente1,
        nombreCliente2 = @nombreCliente2,
        apellidoCliente1 = @apellidoCliente1,
        apellidoCliente2 = @apellidoCliente2,
        telefonoCliente = @telefonoCliente,
        emailCliente = @emailCliente
    WHERE idCliente = @idCliente;
END;
go

-- Stored procedures para Funcion
-- CREATE: Insertar una nueva función
CREATE PROCEDURE InsertarFuncion (
    @idSala INT,
    @idPelicula INT,
    @fechaHoraFuncion DATETIME
)
AS
BEGIN
    INSERT INTO Funcion (idSala, idPelicula, fechaHoraFuncion)
    VALUES (@idSala, @idPelicula, @fechaHoraFuncion);
END;
go

-- READ: Obtener todas las funciones
CREATE PROCEDURE ObtenerFunciones
AS
BEGIN
    SELECT f.idFuncion, f.fechaHoraFuncion, s.tipoSala, p.tituloPelicula
    FROM Funcion f
    JOIN Sala s ON f.idSala = s.idSala
    JOIN Pelicula p ON f.idPelicula = p.idPelicula;
END;
go

-- UPDATE: Actualizar una función por película
CREATE PROCEDURE ActualizarFuncion (
    @idFuncion INT,
    @idSala INT,
    @idPelicula INT,
    @fechaHoraFuncion DATETIME
)
AS
BEGIN
    UPDATE Funcion
    SET idSala = @idSala,
        idPelicula = @idPelicula,
        fechaHoraFuncion = @fechaHoraFuncion
    WHERE idFuncion = @idFuncion;
END;
go

-- Stored procedures para Entrada
-- CREATE: Insertar una nueva entrada
CREATE PROCEDURE InsertarEntrada (
    @idFuncion INT,
    @idCliente INT,
    @precioEntrada DECIMAL(8, 2),
    @cantidadEntradas INT
)
AS
BEGIN
    INSERT INTO Entrada (idFuncion, idCliente, precioEntrada, cantidadEntradas)
    VALUES (@idFuncion, @idCliente, @precioEntrada, @cantidadEntradas);
END;
GO

--READ: Obtener entradas de una función
CREATE PROCEDURE ObtenerEntradasPorFuncion (
    @idFuncion INT
)
AS
BEGIN
    SELECT 
        e.idEntrada, 
        e.idCliente, 
        e.precioEntrada, 
        e.cantidadEntradas, 
        a.asiento  -- Obtenemos el número de asiento de la tabla Asiento
    FROM Entrada e
    JOIN Asiento a ON e.idEntrada = a.idEntrada  -- Realizamos el JOIN con la tabla Asiento
    WHERE e.idFuncion = @idFuncion;  -- Filtramos por la función específica
END;
GO

--UPDATE: Actualizar entrada
CREATE PROCEDURE ActualizarEntrada (
    @idEntrada INT,
    @idFuncion INT,
    @idCliente INT,
    @precioEntrada DECIMAL(8, 2),
    @cantidadEntradas INT
)
AS
BEGIN
    UPDATE Entrada
    SET idFuncion = @idFuncion,
        idCliente = @idCliente,
        precioEntrada = @precioEntrada,
        cantidadEntradas = @cantidadEntradas
    WHERE idEntrada = @idEntrada;
END;
go


-- Stored Procedures para Asiento
-- CREATE: Insertar un nuevo asiento
CREATE PROCEDURE InsertarAsiento (
    @idEntrada INT,
    @asiento VARCHAR(10)
)
AS
BEGIN
    INSERT INTO Asiento (idEntrada, asiento)
    VALUES (@idEntrada, @asiento);
END;
go

-- READ: Obtener todos los asientos asignados
CREATE PROCEDURE ObtenerAsientosPorEntrada (
    @idEntrada INT
)
AS
BEGIN
    SELECT idAsiento, asiento
    FROM Asiento
    WHERE idEntrada = @idEntrada;
END;
go

-- DELETE: Eliminar un asiento
CREATE PROCEDURE EliminarAsiento (
    @idAsiento INT
)
AS
BEGIN
    DELETE FROM Asiento
    WHERE idAsiento = @idAsiento;
END;
GO

-- Inserción de datos para cada tabla
INSERT INTO Sala (tipoSala, capacidadSala) VALUES
('Sala 1', 100),
('Sala 2', 120),
('Sala 3', 80),
('Sala 4', 150),
('Sala 5', 200),
('Sala 6', 250),
('Sala 7', 180),
('Sala 8', 50),
('Sala 9', 90),
('Sala 10', 110);
GO

INSERT INTO Pelicula (tituloPelicula, generoPelicula, duracionPelicula, clasificacionPelicula) VALUES
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Avengers: Endgame', 'Acción', 181, 'PG-13'),
('Titanic', 'Drama/Romance', 195, 'PG-13'),
('El Rey León', 'Animación/Aventura', 88, 'G'),
('Inception', 'Ciencia ficción', 148, 'PG-13'),
('El Padrino', 'Crimen/Drama', 175, 'R'),
('Jurassic Park', 'Ciencia ficción/Aventura', 127, 'PG-13'),
('The Dark Knight', 'Acción/Crimen', 152, 'PG-13'),
('Forrest Gump', 'Drama/Romance', 142, 'PG-13'),
('Matrix', 'Ciencia ficción', 136, 'R');
GO

INSERT INTO Cliente (nombreCliente1, nombreCliente2, apellidoCliente1, apellidoCliente2, telefonoCliente, emailCliente) VALUES
('Juan', 'Carlos', 'Pérez', 'García', '1155710020', 'juan.perez@gmail.com'),
('Ana', 'María', 'López', NULL, '1130034777', 'analopez@hotmail.com.ar'),
('Luis', NULL, 'Gómez', 'Martínez', '1197456560', 'luisgomez@gmail.com'),
('Pedro', 'Alejandro', 'Ramírez', NULL, '1102326980', 'pedro.r@gmail.com'),
('Laura', NULL, 'Fernández', 'Flores', '1123987456', 'laurafer@hotmail.com.ar'),
('Pablo', NULL, 'Hernández', 'Suárez', '1198765432', 'pablohernandez@gmail.com'),
('Elena', 'Sofía', 'Díaz', 'Villalba', '1187653210', 'elena.diaz.villalba@hotmail.com.ar'),
('Carlos', NULL, 'Torres', NULL, '1165421987', 'carlostorres@gmail.com'),
('Raquel', 'Marina', 'Vázquez', NULL, '1132154857', 'raquelvazquez@hotmail.com.ar'),
('Agustín', NULL, 'López', NULL, '654987321', 'aguslopez@gmail.com');
GO


INSERT INTO Funcion (idSala, idPelicula, fechaHoraFuncion) VALUES
(1, 1, '2024-11-07 14:00:00'),
(2, 2, '2024-11-07 16:00:00'),
(3, 3, '2024-11-07 18:00:00'),
(4, 4, '2024-11-07 20:00:00'),
(5, 5, '2024-11-08 14:00:00'),
(6, 6, '2024-11-08 16:00:00'),
(7, 7, '2024-11-08 18:00:00'),
(8, 8, '2024-11-08 20:00:00'),
(9, 9, '2024-11-09 14:00:00'),
(10, 10, '2024-11-09 16:00:00');
GO

INSERT INTO Entrada (idFuncion, idCliente, precioEntrada, cantidadEntradas) VALUES
(1, 1, 10.00, 2),
(2, 2, 12.50, 3),
(3, 3, 8.50, 1),
(4, 4, 15.00, 4),
(5, 5, 20.00, 2),
(6, 6, 18.00, 5),
(7, 7, 22.00, 2),
(8, 8, 16.50, 3),
(9, 9, 14.00, 1),
(10, 10, 19.00, 4);
GO

INSERT INTO Asiento (idEntrada, asiento) VALUES
(1, 'A1'),
(1, 'A2'),
(2, 'B1'),
(2, 'B2'),
(2, 'B3'),
(3, 'C1'),
(4, 'D1'),
(4, 'D2'),
(5, 'E1'),
(6, 'F1');
GO

--CONSULTAS PARA EL FUNCIONAMIENTO DEL SISTEMA

-- Todas las funciones de una película específica
SELECT f.idFuncion, f.fechaHoraFuncion, s.tipoSala, p.tituloPelicula
FROM Funcion f
JOIN Sala s ON f.idSala = s.idSala
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE p.tituloPelicula = 'Deadpool & Wolverine';

-- Entradas de un cliente en específico 
SELECT e.idEntrada, f.fechaHoraFuncion, e.precioEntrada, e.cantidadEntradas
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
WHERE e.idCliente = 3; 

-- Consultar todos los asientos de una entrada específica
SELECT a.asiento
FROM Asiento a
WHERE a.idEntrada = 2;

-- Historial funciones de un cliente
SELECT f.fechaHoraFuncion, a.asiento, p.tituloPelicula
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Asiento a ON e.idEntrada = a.idEntrada
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE e.idCliente = 3;

-- Funciones programadas para un determinado día
SELECT f.idFuncion, f.fechaHoraFuncion, s.tipoSala, p.tituloPelicula
FROM Funcion f
JOIN Sala s ON f.idSala = s.idSala
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE CAST(f.fechaHoraFuncion AS DATE) = '2024-11-07'

-- Entradas disponibles para una función
SELECT f.idFuncion, f.fechaHoraFuncion, SUM(e.cantidadEntradas) AS entradasVendidas, s.capacidadSala - SUM(e.cantidadEntradas) AS entradasDisponibles
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Sala s ON f.idSala = s.idSala
WHERE f.idFuncion = 2 
GROUP BY f.idFuncion, f.fechaHoraFuncion, s.capacidadSala; 

-- Información clientes que compraron entradas para una función
SELECT c.nombreCliente1, c.nombreCliente2, c.apellidoCliente1, c.apellidoCliente2, e.precioEntrada, e.cantidadEntradas, a.asiento
FROM Entrada e
JOIN Cliente c ON e.idCliente = c.idCliente
JOIN Asiento a ON e.idEntrada = a.idEntrada
JOIN Funcion f ON e.idFuncion = f.idFuncion
WHERE f.idFuncion = 1; 

-- Cantidad de entradas vendidas por película
SELECT p.tituloPelicula, SUM(e.cantidadEntradas) AS totalEntradasVendidas
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Pelicula p ON f.idPelicula = p.idPelicula
GROUP BY p.tituloPelicula;

-- Funciones de una película en un intervalo de fechas
SELECT f.idFuncion, f.fechaHoraFuncion, s.tipoSala
FROM Funcion f
JOIN Sala s ON f.idSala = s.idSala
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE p.tituloPelicula = 'Deadpool & Wolverine' AND f.fechaHoraFuncion BETWEEN '2024-11-01' AND '2024-11-30';

-- Total recaudado por una función
SELECT p.tituloPelicula, 
       SUM(e.precioEntrada * e.cantidadEntradas) AS totalRecaudado
FROM Entrada e
JOIN Pelicula p ON e.idPelicula = p.idPelicula
WHERE e.idFuncion = 1
GROUP BY p.tituloPelicula;

-- Funciones de una sala específica
SELECT f.idFuncion, f.fechaHoraFuncion, p.tituloPelicula
FROM Funcion f
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE f.idSala = 1; 

-- Películas más vistas
SELECT p.tituloPelicula, SUM(e.cantidadEntradas) AS totalEntradasVendidas
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Pelicula p ON f.idPelicula = p.idPelicula
GROUP BY p.tituloPelicula
ORDER BY totalEntradasVendidas DESC;
GO
