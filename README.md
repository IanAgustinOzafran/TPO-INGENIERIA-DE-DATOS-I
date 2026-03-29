# TPO-INGENIERIA-DE-DATOS-

# 🎬 Cinetik - Sistema de Gestión de Cine

## 📌 Descripción
**Cinetik** es una base de datos desarrollada en **SQL Server** para gestionar el funcionamiento de un cine.  
El sistema permite administrar **salas, películas, clientes, funciones, entradas y asientos**.

El proyecto utiliza **tablas, restricciones (constraints), triggers y stored procedures** para garantizar la integridad de los datos y permitir operaciones de gestión sobre el sistema.

---

# 🗄️ Estructura de la Base de Datos

La base de datos está compuesta por las siguientes tablas principales:

## 🏢 Sala
Almacena la información de las salas del cine.

Campos:
- `idSala` – Identificador de la sala
- `tipoSala` – Tipo de sala (2D, 3D, IMAX)
- `capacidadSala` – Capacidad máxima de la sala

---

## 🎥 Pelicula
Contiene la información de las películas disponibles.

Campos:
- `idPelicula` – Identificador de la película
- `tituloPelicula` – Título de la película
- `generoPelicula` – Género
- `duracionPelicula` – Duración en minutos
- `clasificacionPelicula` – Clasificación por edad

---

## 👤 Cliente
Almacena la información de los clientes.

Campos:
- `idCliente` – Identificador del cliente
- `nombreCliente1`
- `nombreCliente2`
- `apellidoCliente1`
- `apellidoCliente2`
- `telefonoCliente`
- `emailCliente`

---

## 🎟️ Funcion
Representa una función de una película en una sala y horario determinado.

Campos:
- `idFuncion` – Identificador de la función
- `idSala` – Sala donde se proyecta
- `idPelicula` – Película proyectada
- `fechaHoraFuncion` – Fecha y hora de la función

---

## 🎫 Entrada
Representa la compra de entradas para una función.

Campos:
- `idEntrada` – Identificador de la entrada
- `idFuncion` – Función asociada
- `idCliente` – Cliente que compró la entrada
- `precioEntrada` – Precio de la entrada
- `cantidadEntradas` – Cantidad de entradas compradas

---

## 💺 Asiento
Representa el asiento asignado a una entrada.

Campos:
- `idAsiento` – Identificador del asiento
- `idEntrada` – Entrada asociada
- `asiento` – Código del asiento

---

# ⚙️ Triggers

El sistema incluye triggers para asegurar la integridad de los datos.

### Validación de duración de película
Verifica que la duración de una película sea **mayor o igual a 30 minutos**.

### Validación de asientos duplicados
Evita que se pueda asignar el mismo asiento más de una vez para una misma entrada.

### Validación de capacidad de sala
Controla que la cantidad total de entradas vendidas para una función **no supere la capacidad de la sala**.

---

# 🧠 Stored Procedures

Se implementaron stored procedures para realizar las operaciones principales del sistema.

## Sala
- `InsertarSala`
- `ObtenerSalas`
- `ActualizarSala`

## Pelicula
- `InsertarPelicula`
- `ObtenerPeliculas`
- `ActualizarPelicula`
- `EliminarPelicula`

## Cliente
- `InsertarCliente`
- `ObtenerClientes`
- `ActualizarCliente`

## Funcion
- `InsertarFuncion`
- `ObtenerFunciones`
- `ActualizarFuncion`
- `EliminarFuncion`

## Entrada
- `InsertarEntrada`
- `ObtenerEntradasPorFuncion`
- `ActualizarEntrada`

## Asiento
- `InsertarAsiento`
- `ObtenerAsientosPorEntrada`
- `EliminarAsiento`

---

# 📊 Datos de prueba

El script incluye inserciones de datos de ejemplo para probar el funcionamiento del sistema, incluyendo:

- Salas
- Películas
- Clientes
- Funciones
- Entradas
- Asientos
