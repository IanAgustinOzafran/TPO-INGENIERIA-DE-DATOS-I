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

-- Trigger para inicializar capacidadDisponible en la función igual a la capacidad de la sala
CREATE TRIGGER trg_set_capacidad_disponible
ON Funcion
AFTER INSERT
AS
BEGIN
    UPDATE Funcion
    SET capacidadDisponible = (SELECT capacidadSala FROM Sala WHERE Sala.idSala = Funcion.idSala)
    FROM Funcion
    JOIN inserted ON Funcion.idFuncion = inserted.idFuncion;
END;
go

go

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

-- Trigger para validar la capacidad de la sala antes de insertar una entrada
CREATE TRIGGER trg_validar_capacidad_funcion
ON Entrada
AFTER INSERT
AS
BEGIN
    DECLARE @idFuncion INT, @cantidadEntradas INT;
    SELECT @idFuncion = idFuncion, @cantidadEntradas = cantidadEntradas FROM inserted;
    
    IF (SELECT capacidadDisponible FROM Funcion WHERE idFuncion = @idFuncion) < @cantidadEntradas
    BEGIN
        RAISERROR ('La cantidad de entradas excede la capacidad disponible de la sala.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        UPDATE Funcion
        SET capacidadDisponible = capacidadDisponible - @cantidadEntradas
        WHERE idFuncion = @idFuncion;
    END
END;
go

CREATE TABLE Asiento (
    idAsiento INT IDENTITY(1,1) PRIMARY KEY,
    idEntrada INT NOT NULL,
    asiento VARCHAR(10) NOT NULL, -- El número o identificador del asiento (por ejemplo, A1, B2)
    FOREIGN KEY (idEntrada) REFERENCES Entrada(idEntrada)
);

-- Stored procedures de Sala
-- CREATE: Insertar una nueva sala
CREATE PROCEDURE sp_InsertarSala(
    IN p_tipoSala VARCHAR(50), 
    IN p_capacidadSala INT 
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la inserción de sala' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO Sala (tipoSala, capacidadSala) 
    VALUES (p_tipoSala, p_capacidadSala); 
    COMMIT;
END;
GO

-- READ: Obtener todos los datos de salas
CREATE PROCEDURE sp_ObtenerSalas()
BEGIN
    SELECT * FROM Sala;
END;
GO

-- UPDATE: Actualizar una sala existente
CREATE PROCEDURE sp_ActualizarSala(
    IN p_idSala INT, 
    IN p_tipoSala VARCHAR(50), 
    IN p_capacidadSala INT 
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la actualización de sala' AS mensaje;
    END;

    START TRANSACTION;
    UPDATE Sala 
    SET tipoSala = p_tipoSala, capacidadSala = p_capacidadSala 
    WHERE idSala = p_idSala;
    COMMIT;
END;
GO

-- DELETE: Eliminar una sala
CREATE PROCEDURE sp_EliminarSala(
    IN p_idSala INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la eliminación de sala' AS mensaje;
    END;

    START TRANSACTION;
    DELETE FROM Sala WHERE idSala = p_idSala;
    COMMIT;
END;
GO

--Stored procedures para Pelicula
-- CREATE: Insertar una nueva película
CREATE PROCEDURE sp_InsertarPelicula(
    IN p_tituloPelicula VARCHAR(100),
    IN p_generoPelicula VARCHAR(50),  
    IN p_duracionPelicula INT, 
    IN p_clasificacionPelicula VARCHAR(20) 
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la inserción de película' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO Pelicula (tituloPelicula, generoPelicula, duracionPelicula, clasificacionPelicula) 
    VALUES (p_tituloPelicula, p_generoPelicula, p_duracionPelicula, p_clasificacionPelicula); 
    COMMIT;
END;
GO

-- READ: Obtener todos los datos de películas
CREATE PROCEDURE sp_ObtenerPeliculas()
BEGIN
    SELECT * FROM Pelicula;
END;
GO

-- UPDATE: Actualizar una película existente
CREATE PROCEDURE sp_ActualizarPelicula(
    IN p_idPelicula INT, 
    IN p_tituloPelicula VARCHAR(100), 
    IN p_generoPelicula VARCHAR(50), 
    IN p_duracionPelicula INT, 
    IN p_clasificacionPelicula VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la actualización de película' AS mensaje;
    END;

    START TRANSACTION;
    UPDATE Pelicula 
    SET tituloPelicula = p_tituloPelicula, generoPelicula = p_generoPelicula, 
        duracionPelicula = p_duracionPelicula, clasificacionPelicula = p_clasificacionPelicula
    WHERE idPelicula = p_idPelicula; -- Corregido nombre de las columnas
    COMMIT;
END;
GO

-- DELETE: Eliminar una película
CREATE PROCEDURE sp_EliminarPelicula(
    IN p_idPelicula INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la eliminación de película' AS mensaje;
    END;

    START TRANSACTION;
    DELETE FROM Pelicula WHERE idPelicula = p_idPelicula;
    COMMIT;
END;
GO

-- Stored Procedures para Cliente
-- CREATE: Insertar un nuevo cliente
CREATE PROCEDURE sp_InsertarCliente(
    IN p_nombreCliente1 VARCHAR(50), 
    IN p_nombreCliente2 VARCHAR(50), 
    IN p_apellidoCliente1 VARCHAR(50), 
    IN p_apellidoCliente2 VARCHAR(50), 
    IN p_telefonoCliente VARCHAR(20), 
    IN p_emailCliente VARCHAR(100) 
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la inserción de cliente' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO Cliente (nombreCliente1, nombreCliente2, apellidoCliente1, apellidoCliente2, telefonoCliente, emailCliente) 
    VALUES (p_nombreCliente1, p_nombreCliente2, p_apellidoCliente1, p_apellidoCliente2, p_telefonoCliente, p_emailCliente); 
    COMMIT;
END;
GO

-- Stored procedures para Funcion
-- CREATE: Insertar una nueva función
CREATE PROCEDURE sp_InsertarFuncion(
    IN p_idSala INT, 
    IN p_idPelicula INT, 
    IN p_fechaHora DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la inserción de función' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO Funcion (idSala, idPelicula, fechaHora) 
    VALUES (p_idSala, p_idPelicula, p_fechaHora);
    COMMIT;
END;
GO

-- READ: Obtener todas las funciones
CREATE PROCEDURE sp_ObtenerFunciones()
BEGIN
    SELECT * FROM Funcion;
END;
GO

-- UPDATE: Actualizar una función existente
CREATE PROCEDURE sp_ActualizarFuncion(
    IN p_idFuncion INT, 
    IN p_idSala INT, 
    IN p_idPelicula INT, 
    IN p_fechaHora DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la actualización de función' AS mensaje;
    END;

    START TRANSACTION;
    UPDATE Funcion 
    SET idSala = p_idSala, idPelicula = p_idPelicula, fechaHora = p_fechaHora
    WHERE idFuncion = p_idFuncion;
    COMMIT;
END;
GO

-- DELETE: Eliminar una función
CREATE PROCEDURE sp_EliminarFuncion(
    IN p_idFuncion INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la eliminación de función' AS mensaje;
    END;

    START TRANSACTION;
    DELETE FROM Funcion WHERE idFuncion = p_idFuncion;
    COMMIT;
END;
GO

-- Stored Procedures para Asiento
-- CREATE: Insertar un nuevo asiento
CREATE PROCEDURE sp_InsertarAsiento(
    IN p_idEntrada INT, 
    IN p_asiento VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la inserción de asiento' AS mensaje;
    END;

    START TRANSACTION;
    INSERT INTO Asiento (idEntrada, asiento) 
    VALUES (p_idEntrada, p_asiento);
    COMMIT;
END;
GO

-- READ: Obtener todos los asientos asignados
CREATE PROCEDURE sp_ObtenerAsientos()
BEGIN
    SELECT * FROM Asiento;
END;
GO

-- DELETE: Eliminar un asiento
CREATE PROCEDURE sp_EliminarAsiento(
    IN p_idAsiento INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la eliminación de asiento' AS mensaje;
    END;

    START TRANSACTION;
    DELETE FROM Asiento WHERE idAsiento = p_idAsiento;
    COMMIT;
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
WHERE DATE(f.fechaHoraFuncion) = '2024-11-07'; 

-- Entradas disponibles para una función
SELECT f.idFuncion, SUM(e.cantidadEntradas) AS entradasVendidas, s.capacidadSala - SUM(e.cantidadEntradas) AS entradasDisponibles
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Sala s ON f.idSala = s.idSala
WHERE f.idFuncion = 2 
GROUP BY f.idFuncion, s.capacidadSala;

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
SELECT SUM(e.precioEntrada * e.cantidadEntradas) AS totalRecaudado
FROM Entrada e
WHERE e.idFuncion = 1; 

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










