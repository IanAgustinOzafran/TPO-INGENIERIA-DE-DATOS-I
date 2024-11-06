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

CREATE TABLE Entrada (
    idEntrada INT IDENTITY(1,1) PRIMARY KEY,
    idFuncion INT NOT NULL,
    idCliente INT NOT NULL,
    precioEntrada DECIMAL(8, 2) NOT NULL CHECK (precioEntrada >= 0), 
    cantidadEntradas INT NOT NULL DEFAULT 1 CHECK (cantidadEntradas > 0),
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
INSERT INTO Sala (tipoSala, capacidad) VALUES
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

INSERT INTO Pelicula (titulo, genero, duracion, clasificacion) VALUES
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R'),
('Deadpool & Wolverine', 'Acción', 127, 'R');

INSERT INTO Cliente ()


