CREATE DATABASE Cinetik

USE Cinetik

CREATE TABLE Sala (
    idSala INT IDENTITY(1,1) PRIMARY KEY,
    tipoSala VARCHAR(50) NOT NULL,
    capacidadSala INT NOT NULL CHECK (capacidadSala > 0)
);
GO

CREATE TABLE Pelicula (
    idPelicula INT IDENTITY(1,1) PRIMARY KEY,
    tituloPelicula VARCHAR(100) NOT NULL,
    generoPelicula VARCHAR(50) NOT NULL,
    duracionPelicula INT NOT NULL CHECK (duracionPelicula > 0),
    clasificacionPelicula VARCHAR(20) NOT NULL
);
GO

CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    nombreCliente1 VARCHAR(50) NOT NULL,
    nombreCliente2 VARCHAR(50), 
    apellidoCliente1 VARCHAR(50) NOT NULL,
    apellidoCliente2 VARCHAR(50),
    telefonoCliente VARCHAR(20),
    emailCliente VARCHAR(100) UNIQUE
);
GO

CREATE TABLE Funcion (
    idFuncion INT IDENTITY(1,1) PRIMARY KEY,
    idSala INT NOT NULL,
    idPelicula INT NOT NULL,
    fechaHoraFuncion DATETIME NOT NULL,
    FOREIGN KEY (idSala) REFERENCES Sala(idSala) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idPelicula) REFERENCES Pelicula(IdPelicula) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE Entrada (
    idEntrada INT IDENTITY(1,1) PRIMARY KEY,
    idFuncion INT NOT NULL,
    idCliente INT NOT NULL,
    precioEntrada DECIMAL(8, 2) NOT NULL CHECK (precioEntrada >= 0), 
    cantidadEntradas INT NOT NULL CHECK (cantidadEntradas > 0),
    FOREIGN KEY (idFuncion) REFERENCES Funcion(idFuncion) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE Asiento (
    idAsiento INT IDENTITY(1,1) PRIMARY KEY,
    idEntrada INT NOT NULL,
    asiento VARCHAR(10) NOT NULL,
    FOREIGN KEY (idEntrada) REFERENCES Entrada(idEntrada) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT UQ_Asiento_Entrada UNIQUE (idEntrada, asiento)
);
GO


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

-- Trigger para verificar disponibilidad de asientos antes de insertar un nuevo asiento
CREATE TRIGGER trg_verificar_asiento_unico
ON Asiento
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Asiento a
        JOIN inserted i
        ON a.idEntrada = i.idEntrada AND a.asiento = i.asiento
    )
    BEGIN
        RAISERROR ('El asiento ya está ocupado para esta entrada.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Asiento (idEntrada, asiento)
        SELECT idEntrada, asiento
        FROM inserted;
    END
END;
GO

--Trigger para validar capacidad de la sala antes de insertar una nueva función
CREATE TRIGGER trg_validar_capacidad_sala
ON Entrada
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @idFuncion INT, @cantidadEntradas INT, @idSala INT, @capacidadSala INT;

    SELECT @idFuncion = idFuncion, @cantidadEntradas = cantidadEntradas
    FROM inserted;

    SELECT @idSala = f.idSala
    FROM Funcion f
    WHERE f.idFuncion = @idFuncion;

    SELECT @capacidadSala = s.capacidadSala
    FROM Sala s
    WHERE s.idSala = @idSala;

    IF (SELECT SUM(e.cantidadEntradas) 
        FROM Entrada e 
        WHERE e.idFuncion = @idFuncion) > @capacidadSala
    BEGIN
        RAISERROR ('La cantidad total de entradas supera la capacidad de la sala.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


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

-- DELETE: Eliminar película
CREATE PROCEDURE EliminarPelicula
    @idPelicula INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM Funcion WHERE idPelicula = @idPelicula)
        BEGIN
            DELETE FROM Funcion WHERE idPelicula = @idPelicula;
        END

        DELETE FROM Pelicula WHERE idPelicula = @idPelicula;

        COMMIT TRANSACTION;
        PRINT 'Película eliminada con éxito.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Ocurrió un error durante la eliminación de la película.';
        THROW;
    END CATCH
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
    IF NOT EXISTS (SELECT 1 FROM Pelicula WHERE idPelicula = @idPelicula)
    BEGIN
        PRINT 'La película con el ID ' + CAST(@idPelicula AS VARCHAR) + ' no existe.';
        RETURN;
    END

    INSERT INTO Funcion (idSala, idPelicula, fechaHoraFuncion)
    VALUES (@idSala, @idPelicula, @fechaHoraFuncion);
END;
GO


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

--DELETE: Eliminar una funcion
CREATE PROCEDURE EliminarFuncion
    @idFuncion INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Funcion WHERE idFuncion = @idFuncion)
        BEGIN
            PRINT 'La función no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DELETE FROM Funcion WHERE idFuncion = @idFuncion;

        COMMIT TRANSACTION;
        PRINT 'Función eliminada con éxito.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Ocurrió un error durante la eliminación de la función.';
        THROW;
    END CATCH
END;
GO


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
        a.asiento 
    FROM Entrada e
    JOIN Asiento a ON e.idEntrada = a.idEntrada 
    WHERE e.idFuncion = @idFuncion; 
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

EXEC InsertarSala '2D', 100;
EXEC InsertarSala '3D', 120;
EXEC InsertarSala '3D', 80;
EXEC InsertarSala '3D', 150;
EXEC InsertarSala '2D', 200;
EXEC InsertarSala '2D', 250;
EXEC InsertarSala '3D', 180;
EXEC InsertarSala '2D', 50;
EXEC InsertarSala '3D', 90;
EXEC InsertarSala 'IMAX', 110;
GO


EXEC InsertarPelicula 'Deadpool & Wolverine', 'Acción', 127, 'R';
EXEC InsertarPelicula 'Avengers: Endgame', 'Acción', 181, 'PG-13';
EXEC InsertarPelicula 'Titanic', 'Drama/Romance', 195, 'PG-13';
EXEC InsertarPelicula 'El Rey León', 'Animación/Aventura', 88, 'G';
EXEC InsertarPelicula 'Inception', 'Ciencia ficción', 148, 'PG-13';
EXEC InsertarPelicula 'El Padrino', 'Crimen/Drama', 175, 'R';
EXEC InsertarPelicula 'Jurassic Park', 'Ciencia ficción/Aventura', 127, 'PG-13';
EXEC InsertarPelicula 'The Dark Knight', 'Acción/Crimen', 152, 'PG-13';
EXEC InsertarPelicula 'Forrest Gump', 'Drama/Romance', 142, 'PG-13';
EXEC InsertarPelicula 'Matrix', 'Ciencia ficción', 136, 'R';
GO

EXEC InsertarCliente 'Juan', 'Carlos', 'Pérez', 'García', '1155710020', 'juan.perez@gmail.com';
EXEC InsertarCliente 'Ana', 'María', 'López', NULL, '1130034777', 'analopez@hotmail.com.ar';
EXEC InsertarCliente 'Luis', NULL, 'Gómez', 'Martínez', '1197456560', 'luisgomez@gmail.com';
EXEC InsertarCliente 'Pedro', 'Alejandro', 'Ramírez', NULL, '1102326980', 'pedro.r@gmail.com';
EXEC InsertarCliente 'Laura', NULL, 'Fernández', 'Flores', '1123987456', 'laurafer@hotmail.com.ar';
EXEC InsertarCliente 'Pablo', NULL, 'Hernández', 'Suárez', '1198765432', 'pablohernandez@gmail.com';
EXEC InsertarCliente 'Elena', 'Sofía', 'Díaz', 'Villalba', '1187653210', 'elena.diaz.villalba@hotmail.com.ar';
EXEC InsertarCliente 'Carlos', NULL, 'Torres', NULL, '1165421987', 'carlostorres@gmail.com';
EXEC InsertarCliente 'Raquel', 'Marina', 'Vázquez', NULL, '1132154857', 'raquelvazquez@hotmail.com.ar';
EXEC InsertarCliente 'Agustín', NULL, 'López', NULL, '654987321', 'aguslopez@gmail.com';
EXEC InsertarCliente 'Martín', NULL, 'González', 'Pérez', '1151234567', 'martin.g@gmail.com';
EXEC InsertarCliente 'Carla', 'María', 'Rodríguez', NULL, '1145671234', 'carlamr@hotmail.com';
EXEC InsertarCliente 'Facundo', 'Emiliano', 'Sánchez', 'Domínguez', '1198765432', 'facu_sanchez@gmail.com';
EXEC InsertarCliente 'Rocío', NULL, 'Fernández', NULL, '1165432198', 'rocio.fernandez@gmail.com';
EXEC InsertarCliente 'Julieta', 'Estefanía', 'Díaz', 'López', '1132145678', 'julietad@hotmail.com';
EXEC InsertarCliente 'Tomás', NULL, 'Pereyra', 'Silva', '1123456789', 'tomasp@gmail.com';
EXEC InsertarCliente 'Lucía', 'Sofía', 'Martínez', 'Cruz', '1145678912', 'lucia.mc@hotmail.com';
EXEC InsertarCliente 'Santiago', 'Andrés', 'Vázquez', NULL, '1156781234', 'santiago.v@gmail.com';
EXEC InsertarCliente 'Camila', NULL, 'Torres', NULL, '1167891234', 'camila.t@gmail.com';
EXEC InsertarCliente 'Matías', 'Federico', 'Gómez', 'Ruiz', '1191234567', 'matias.g@gmail.com';
GO


-- Funciones en distintas salas
EXEC InsertarFuncion 1, 1, '2024-11-07 11:00:00'; -- Deadpool & Wolverine en Sala 1
EXEC InsertarFuncion 2, 2, '2024-11-07 13:00:00'; -- Avengers: Endgame en Sala 2
EXEC InsertarFuncion 3, 3, '2024-11-07 17:00:00'; -- Titanic en Sala 3
EXEC InsertarFuncion 4, 4, '2024-11-07 19:30:00'; -- El Rey León en Sala 4
EXEC InsertarFuncion 5, 5, '2024-11-07 21:30:00'; -- Inception en Sala 5
EXEC InsertarFuncion 6, 6, '2024-11-08 10:00:00'; -- El Padrino en Sala 6
EXEC InsertarFuncion 7, 7, '2024-11-08 12:30:00'; -- Jurassic Park en Sala 7
EXEC InsertarFuncion 8, 8, '2024-11-08 16:00:00'; -- The Dark Knight en Sala 8
EXEC InsertarFuncion 9, 9, '2024-11-08 18:30:00'; -- Forrest Gump en Sala 9
EXEC InsertarFuncion 10, 10, '2024-11-08 20:30:00'; -- Matrix en Sala 10
EXEC InsertarFuncion 1, 1, '2024-11-09 11:00:00'; -- Deadpool & Wolverine en Sala 1
EXEC InsertarFuncion 2, 2, '2024-11-09 13:00:00'; -- Avengers: Endgame en Sala 2
EXEC InsertarFuncion 3, 3, '2024-11-09 15:30:00'; -- Titanic en Sala 3
EXEC InsertarFuncion 4, 4, '2024-11-09 18:00:00'; -- El Rey León en Sala 4
EXEC InsertarFuncion 5, 5, '2024-11-09 20:30:00'; -- Inception en Sala 5
EXEC InsertarFuncion 6, 6, '2024-11-10 14:00:00'; -- El Padrino en Sala 6
EXEC InsertarFuncion 7, 7, '2024-11-10 16:30:00'; -- Jurassic Park en Sala 7
EXEC InsertarFuncion 8, 8, '2024-11-10 19:00:00'; -- The Dark Knight en Sala 8
EXEC InsertarFuncion 9, 9, '2024-11-10 21:00:00'; -- Forrest Gump en Sala 9
EXEC InsertarFuncion 10, 10, '2024-11-11 14:30:00'; -- Matrix en Sala 10
EXEC InsertarFuncion 1, 1, '2024-11-12 11:00:00'; -- Deadpool & Wolverine en Sala 1
EXEC InsertarFuncion 2, 2, '2024-11-12 13:30:00'; -- Avengers: Endgame en Sala 2
EXEC InsertarFuncion 3, 3, '2024-11-12 16:00:00'; -- Titanic en Sala 3
EXEC InsertarFuncion 4, 4, '2024-11-12 18:30:00'; -- El Rey León en Sala 4
EXEC InsertarFuncion 5, 5, '2024-11-12 21:00:00'; -- Inception en Sala 5

GO





EXEC InsertarEntrada 1, 1, 6000.00, 4; 
EXEC InsertarEntrada 2, 2, 7600.00, 5; 
EXEC InsertarEntrada 3, 3, 6000.00, 3; 
EXEC InsertarEntrada 4, 4, 7600.00, 1; 
EXEC InsertarEntrada 5, 5, 6000.00, 11; 
EXEC InsertarEntrada 6, 6, 7600.00, 6;  
EXEC InsertarEntrada 7, 7, 6000.00, 3; 
EXEC InsertarEntrada 8, 8, 7600.00, 5; 
EXEC InsertarEntrada 9, 9, 6000.00, 6; 
EXEC InsertarEntrada 10, 10, 10000.00, 4; 
EXEC InsertarEntrada 11, 11, 6000.00, 5; 
EXEC InsertarEntrada 12, 12, 7600.00, 1; 
EXEC InsertarEntrada 13, 13, 6000.00, 5; 
EXEC InsertarEntrada 14, 14, 7600.00, 8; 
EXEC InsertarEntrada 15, 15, 6000.00, 7; 
EXEC InsertarEntrada 16, 16, 7600.00, 5;  
EXEC InsertarEntrada 17, 17, 6000.00, 9; 
EXEC InsertarEntrada 18, 18, 7600.00, 12; 
EXEC InsertarEntrada 19, 19, 6000.00, 11; 
EXEC InsertarEntrada 20, 20, 10000.00, 4; 
GO

EXEC InsertarAsiento 1, 'A1';
EXEC InsertarAsiento 1, 'A2';
EXEC InsertarAsiento 2, 'B1';
EXEC InsertarAsiento 2, 'B2';
EXEC InsertarAsiento 2, 'B3';
EXEC InsertarAsiento 3, 'C1';
EXEC InsertarAsiento 4, 'D1';
EXEC InsertarAsiento 4, 'D2';
EXEC InsertarAsiento 4, 'D3';
EXEC InsertarAsiento 4, 'D4';
EXEC InsertarAsiento 5, 'E1';
EXEC InsertarAsiento 5, 'E2';
EXEC InsertarAsiento 6, 'F1';
EXEC InsertarAsiento 6, 'F2';
EXEC InsertarAsiento 6, 'F3';
EXEC InsertarAsiento 6, 'F4';
EXEC InsertarAsiento 6, 'F5';
EXEC InsertarAsiento 7, 'G1';
EXEC InsertarAsiento 7, 'G2';
EXEC InsertarAsiento 8, 'H1';
EXEC InsertarAsiento 8, 'H2';
EXEC InsertarAsiento 8, 'H3';
EXEC InsertarAsiento 9, 'I1';
EXEC InsertarAsiento 10, 'J1';
EXEC InsertarAsiento 10, 'J2';
EXEC InsertarAsiento 10, 'J3';
EXEC InsertarAsiento 10, 'J4';
GO

--CONSULTAS PARA EL FUNCIONAMIENTO DEL SISTEMA

-- Vista para todas las funciones de una película específica
CREATE VIEW VistaFuncionesPorPelicula AS
SELECT f.idFuncion, f.fechaHoraFuncion, s.capacidadSala, p.tituloPelicula
FROM Funcion f
JOIN Sala s ON f.idSala = s.idSala
JOIN Pelicula p ON f.idPelicula = p.idPelicula;
GO


-- Vista para obtener las entradas disponibles para una función
CREATE VIEW VistaEntradasDisponiblesPorFuncion AS
SELECT f.idFuncion, f.fechaHoraFuncion, SUM(e.cantidadEntradas) AS entradasVendidas, s.capacidadSala - SUM(e.cantidadEntradas) AS entradasDisponibles
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Sala s ON f.idSala = s.idSala
GROUP BY f.idFuncion, f.fechaHoraFuncion, s.capacidadSala;
GO

-- Vista para obtener las películas más vistas (cantidad de entradas vendidas)
CREATE VIEW VistaPeliculasMasVistas AS
SELECT p.tituloPelicula, SUM(e.cantidadEntradas) AS totalEntradasVendidas
FROM Entrada e
JOIN Funcion f ON e.idFuncion = f.idFuncion
JOIN Pelicula p ON f.idPelicula = p.idPelicula
GROUP BY p.tituloPelicula;
GO

-- Vista para obtener todas las funciones programadas para un intervalo de fechas
CREATE VIEW VistaFuncionesPorIntervaloFechas AS
SELECT f.idFuncion, f.fechaHoraFuncion, s.idSala AS NumeroSala, s.tipoSala
FROM Funcion f
JOIN Sala s ON f.idSala = s.idSala
JOIN Pelicula p ON f.idPelicula = p.idPelicula
WHERE f.fechaHoraFuncion BETWEEN '2024-11-01' AND '2024-11-30';
GO

CREATE VIEW VistaPeliculasPorGenero AS
SELECT p.generoPelicula, 
       SUM(e.cantidadEntradas) AS totalEntradas,  
       SUM(e.precioEntrada * e.cantidadEntradas) AS recaudacion  
FROM Pelicula p
JOIN Funcion f ON p.idPelicula = f.idPelicula
JOIN Entrada e ON f.idFuncion = e.idFuncion
GROUP BY p.generoPelicula;
GO



-- Vista para obtener la recaudación total del cine por día
CREATE VIEW VistaRecaudacionPorDia AS
SELECT CAST(f.fechaHoraFuncion AS DATE) AS Fecha, SUM(e.precioEntrada * e.cantidadEntradas) AS RecaudacionDiaria
FROM Funcion f
JOIN Entrada e ON f.idFuncion = e.idFuncion
GROUP BY CAST(f.fechaHoraFuncion AS DATE);
GO


SELECT * FROM VistaFuncionesPorPelicula
WHERE tituloPelicula = 'Deadpool & Wolverine';

SELECT * FROM VistaEntradasDisponiblesPorFuncion
WHERE idFuncion = 18;

SELECT * FROM VistaPeliculasMasVistas
ORDER BY totalEntradasVendidas DESC;

SELECT * FROM VistaFuncionesPorIntervaloFechas;

SELECT * FROM VistaPeliculasPorGenero
ORDER BY recaudacion DESC;

SELECT * FROM VistaRecaudacionPorDia
WHERE Fecha BETWEEN '2024-11-01' AND '2024-11-15';

GO


-- FUNCIONES

-- Función para verificar si un asiento está disponible en una entrada específica
CREATE FUNCTION dbo.fn_AsientoDisponible (@idEntrada INT, @asiento VARCHAR(10))
RETURNS BIT
AS
BEGIN
    RETURN (CASE WHEN EXISTS (SELECT 1 FROM Asiento WHERE idEntrada = @idEntrada AND asiento = @asiento) THEN 0 ELSE 1 END);
END;
GO

-- Función para calcular la recaudación total por una función específica
CREATE FUNCTION dbo.fn_RecaudacionTotalPorFuncion (@idFuncion INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @recaudacionTotal DECIMAL(10, 2);
    SELECT @recaudacionTotal = SUM(e.precioEntrada * e.cantidadEntradas)
    FROM Entrada e
    WHERE e.idFuncion = @idFuncion;
    RETURN @recaudacionTotal;
END;
GO

-- Función para obtener el total de entradas vendidas por una película específica
CREATE FUNCTION dbo.fn_CantidadEntradasVendidasPorPelicula (@tituloPelicula VARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @cantidadVendida INT;
    SELECT @cantidadVendida = SUM(e.cantidadEntradas)
    FROM Entrada e
    JOIN Funcion f ON e.idFuncion = f.idFuncion
    JOIN Pelicula p ON f.idPelicula = p.idPelicula
    WHERE p.tituloPelicula = @tituloPelicula;
    RETURN @cantidadVendida;
END;
GO

-- Función para obtener el total de entradas vendidas por sala
CREATE FUNCTION dbo.fn_EntradasVendidasPorSala (@idSala INT)
RETURNS INT
AS
BEGIN
    DECLARE @totalEntradas INT;
    SELECT @totalEntradas = SUM(e.cantidadEntradas)
    FROM Entrada e
    JOIN Funcion f ON e.idFuncion = f.idFuncion
    WHERE f.idSala = @idSala;
    RETURN @totalEntradas;
END;
GO

-- Funcion para mostrar recaudado en total en x día
CREATE FUNCTION dbo.fn_RecaudacionPorDia (@fecha DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @recaudacion DECIMAL(10, 2);
    SELECT @recaudacion = SUM(e.precioEntrada * e.cantidadEntradas)
    FROM Funcion f
    JOIN Entrada e ON f.idFuncion = e.idFuncion
    WHERE CAST(f.fechaHoraFuncion AS DATE) = @fecha;
    RETURN ISNULL(@recaudacion, 0);
END;
GO

-- Función para listar los asientos ocupados en una función específica
CREATE FUNCTION dbo.fn_AsientosOcupadosPorFuncion (@idFuncion INT)
RETURNS TABLE
AS
RETURN (
    SELECT a.asiento
    FROM Asiento a
    JOIN Entrada e ON a.idEntrada = e.idEntrada
    WHERE e.idFuncion = @idFuncion
);
GO


SELECT dbo.fn_AsientoDisponible(1, 'A1') AS AsientoDisponible; --Devuelve 0 o 1 dependiendo si está ocupado o no

SELECT dbo.fn_RecaudacionTotalPorFuncion(1) AS TotalRecaudado;

SELECT dbo.fn_CantidadEntradasVendidasPorPelicula('Deadpool & Wolverine') AS TotalEntradasVendidas;

SELECT dbo.fn_EntradasVendidasPorSala(3) AS TotalEntradasVendidas;

SELECT * FROM dbo.fn_AsientosOcupadosPorFuncion(2);

SELECT dbo.fn_RecaudacionPorDia('2024-11-08') AS TotalRecaudadoEnElDia
GO 




