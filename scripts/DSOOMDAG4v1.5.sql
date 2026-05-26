CREATE SCHEMA IF NOT EXISTS filmate_db;
USE filmate_db;
-- 1. MÓDULO DE SEGURIDAD Y USUARIOS

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE -- 'Admin', 'Cliente'
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    estado ENUM('Activo', 'Bloqueado', 'Inactivo') DEFAULT 'Activo',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

-- 2. MÓDULO DE CATÁLOGO Y CONTENIDO (RF01, RF02, RF18)

CREATE TABLE pelicula (
    id_pelicula INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    sinopsis TEXT,
    duracion_minutos INT,
    clasificacion_edad VARCHAR(10),
    url_poster VARCHAR(255),
    url_trailer VARCHAR(255),
    categoria_cartelera ENUM('Estreno', 'Preventa', 'Cartelera', 'Proximamente') DEFAULT 'Proximamente',
    estado_registro ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE genero (
    id_genero INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE pelicula_genero (
    id_pelicula INT NOT NULL,
    id_genero INT NOT NULL,
    PRIMARY KEY (id_pelicula, id_genero),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero) ON DELETE CASCADE
);

-- Tabla de Elenco / Actores (RF01, RF18)
CREATE TABLE actor (
    id_actor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE pelicula_actor (
    id_pelicula INT NOT NULL,
    id_actor INT NOT NULL,
    personaje VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_pelicula, id_actor),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
    FOREIGN KEY (id_actor) REFERENCES actor(id_actor) ON DELETE CASCADE
);

CREATE TABLE banner_home (
    id_banner INT AUTO_INCREMENT PRIMARY KEY,
    id_pelicula INT,
    imagen_url VARCHAR(255) NOT NULL,
    orden INT NOT NULL,
    is_activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula)
);

-- 3. MÓDULO DE INTERACCIÓN Y COMUNIDAD

CREATE TABLE resena (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_pelicula INT NOT NULL,
    calificacion_estrellas DECIMAL(2,1) CHECK (calificacion_estrellas BETWEEN 1 AND 5),
    comentario TEXT,
    estado_moderacion ENUM('Aprobado', 'Pendiente', 'Oculto') DEFAULT 'Aprobado',
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula)
);

CREATE TABLE favorito (
    id_usuario INT NOT NULL,
    id_pelicula INT NOT NULL,
    fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_pelicula),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE
);

-- 4. MÓDULO DE INFRAESTRUCTURA

CREATE TABLE cine (
    id_cine INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    ciudad VARCHAR(100),
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE sala (
    id_sala INT AUTO_INCREMENT PRIMARY KEY,
    id_cine INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    formato_sala VARCHAR(20),
    capacidad_total INT NOT NULL,
    FOREIGN KEY (id_cine) REFERENCES cine(id_cine)
);

CREATE TABLE asiento (
    id_asiento INT AUTO_INCREMENT PRIMARY KEY,
    id_sala INT NOT NULL,
    fila VARCHAR(5) NOT NULL,
    numero INT NOT NULL,
    coord_x INT,
    coord_y INT,
    estado_fisico ENUM('Disponible', 'Mantenimiento', 'Inhabilitado') DEFAULT 'Disponible',
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala),
    UNIQUE (id_sala, fila, numero)
);

-- 5. MÓDULO DE PROGRAMACIÓN Y TARIFAS

CREATE TABLE funcion (
    id_funcion INT AUTO_INCREMENT PRIMARY KEY,
    id_pelicula INT NOT NULL,
    id_sala INT NOT NULL,
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME NOT NULL,
    idioma VARCHAR(50),
    formato VARCHAR(20),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula),
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala)
);

CREATE TABLE funcion_asiento (
    id_funcion INT NOT NULL,
    id_asiento INT NOT NULL,
    estado ENUM('Disponible', 'Reservado', 'Vendido') DEFAULT 'Disponible',
    PRIMARY KEY (id_funcion, id_asiento),
    FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion) ON DELETE CASCADE,
    FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento) ON DELETE CASCADE
);

CREATE TABLE tarifa (
    id_tarifa INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(8,2) NOT NULL,
    dia_aplica ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo', 'Todos') DEFAULT 'Todos'
);

CREATE TABLE promocion (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cupon VARCHAR(20) UNIQUE NOT NULL,
    porcentaje_descuento DECIMAL(5,2),
    monto_descuento DECIMAL(8,2),
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    limite_usos INT
);


-- 6. MÓDULO DE VENTAS Y CHECKOUT
-- 

CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_funcion INT NOT NULL,
    id_promocion INT NULL,
    fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME NOT NULL,
    monto_subtotal DECIMAL(10,2) NOT NULL,
    descuento_aplicado DECIMAL(10,2) DEFAULT 0.00,
    monto_total DECIMAL(10,2) NOT NULL,
    estado_pago ENUM('Pendiente', 'Pagado', 'Cancelado', 'Reembolsado') DEFAULT 'Pendiente',
    metodo_pago VARCHAR(50),
    transaccion_id VARCHAR(100),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),
    FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion)
);

CREATE TABLE boleto (
    id_boleto INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_funcion INT NOT NULL,
    id_asiento INT NOT NULL,
    id_tarifa INT NOT NULL,
    codigo_qr VARCHAR(255) UNIQUE NOT NULL,
    precio_pagado DECIMAL(8,2) NOT NULL,
    estado_ingreso ENUM('Vigente', 'Usado') DEFAULT 'Vigente',
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),
    FOREIGN KEY (id_asiento) REFERENCES asiento(id_asiento),
    FOREIGN KEY (id_tarifa) REFERENCES tarifa(id_tarifa),
    UNIQUE (id_funcion, id_asiento) 
);
--  MÓDULO DE DULCERÍA Y CONFITERÍA 

CREATE TABLE categoria_snack (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    orden_visual INT NOT NULL DEFAULT 0, 
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE producto_snack (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio_actual DECIMAL(8,2) NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    is_activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categoria_snack(id_categoria) ON DELETE CASCADE
);


CREATE TABLE reserva_snack (
    id_reserva INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(8,2) NOT NULL, 
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    PRIMARY KEY (id_reserva, id_producto),
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto_snack(id_producto)
);

-- 7. ÍNDICES DE RENDIMIENTO Y OPTIMIZACIÓN

CREATE INDEX idx_funcion_fecha ON funcion(fecha_hora_inicio);
CREATE INDEX idx_resena_pelicula ON resena(id_pelicula);
CREATE INDEX idx_reserva_usuario ON reserva(id_usuario);


INSERT INTO rol (nombre) VALUES 
('Admin'), 
('Cliente');

INSERT INTO usuario (id_rol, nombres, apellidos, correo, password_hash, estado) VALUES
(1, 'Valeria', 'Campos', 'admin@filmate.com', '$2y$10$abcdefghijklmnopqrstuv', 'Activo'),
(2, 'Jorge', 'Salinas', 'jsalinas88@gmail.com', '$2y$10$zyxwvutsrqponmlkjihgfe', 'Activo'),
(2, 'Camila', 'Reyes', 'camila.reyes@hotmail.com', '$2y$10$1234567890abcdefghijkl', 'Activo');

INSERT INTO pelicula (titulo, sinopsis, duracion_minutos, clasificacion_edad, url_poster, url_trailer, categoria_cartelera) VALUES
('Dune: Parte Dos', 'Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia.', 166, '+14', 'https://img.filmate.com/posters/dune2.jpg', 'https://youtube.com/dune2', 'Cartelera'),
('Intensa-Mente 2', 'Alegría, Tristeza, Furia, Temor y Desagrado reciben a nuevas emociones en el cuartel general.', 96, 'APT', 'https://img.filmate.com/posters/insideout2.jpg', 'https://youtube.com/io2', 'Estreno'),
('Deadpool & Wolverine', 'Wolverine se recupera de sus heridas cuando se cruza con Deadpool, juntos formarán un equipo inesperado.', 127, '+18', 'https://img.filmate.com/posters/dp3.jpg', 'https://youtube.com/dp3', 'Preventa');

INSERT INTO genero (nombre) VALUES 
('Ciencia Ficción'), ('Animación'), ('Acción'), ('Comedia'), ('Fantasía');

INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES 
(1, 1), (1, 3),
(2, 2), (2, 4),
(3, 3), (3, 4);

INSERT INTO actor (nombre) VALUES 
('Timothée Chalamet'), ('Zendaya'), ('Amy Poehler'), ('Ryan Reynolds'), ('Hugh Jackman');

INSERT INTO pelicula_actor (id_pelicula, id_actor, personaje) VALUES 
(1, 1, 'Paul Atreides'),
(1, 2, 'Chani'),
(2, 3, 'Alegría (Voz)'),
(3, 4, 'Wade Wilson / Deadpool'),
(3, 5, 'Logan / Wolverine');

INSERT INTO banner_home (id_pelicula, imagen_url, orden, is_activo) VALUES
(2, 'https://img.filmate.com/banners/insideout2_wide.jpg', 1, TRUE),
(3, 'https://img.filmate.com/banners/deadpool_wide.jpg', 2, TRUE),
(1, 'https://img.filmate.com/banners/dune_wide.jpg', 3, TRUE);

INSERT INTO resena (id_usuario, id_pelicula, calificacion_estrellas, comentario, estado_moderacion) VALUES
(2, 1, 5.0, 'Visualmente espectacular. Una obra maestra de la ciencia ficción moderna, superó a la primera parte.', 'Aprobado'),
(3, 1, 4.5, 'Me encantó la banda sonora, aunque se siente un poco larga hacia el final.', 'Aprobado');

INSERT INTO favorito (id_usuario, id_pelicula) VALUES 
(2, 1), (2, 3),
(3, 2);

INSERT INTO cine (nombre, direccion, ciudad, estado) VALUES 
('Filmate Norte', 'Mall Aventura 550', 'Trujillo', TRUE);

INSERT INTO sala (id_cine, nombre, formato_sala, capacidad_total) VALUES 
(1, 'Sala 1 - MACRO XE', '2D', 6),
(1, 'Sala 2 - VIP', '2D', 4);

INSERT INTO asiento (id_sala, fila, numero, coord_x, coord_y, estado_fisico) VALUES
(1, 'A', 1, 0, 0, 'Disponible'), (1, 'A', 2, 1, 0, 'Disponible'), (1, 'A', 3, 2, 0, 'Disponible'),
(1, 'B', 1, 0, 1, 'Disponible'), (1, 'B', 2, 1, 1, 'Disponible'), (1, 'B', 3, 2, 1, 'Disponible');

INSERT INTO asiento (id_sala, fila, numero, coord_x, coord_y, estado_fisico) VALUES
(2, 'A', 1, 0, 0, 'Disponible'), (2, 'A', 2, 1, 0, 'Disponible'),
(2, 'B', 1, 0, 1, 'Disponible'), (2, 'B', 2, 1, 1, 'Disponible');

INSERT INTO tarifa (nombre, precio, dia_aplica) VALUES 
('General', 22.50, 'Todos'), 
('Niños y Tercera Edad', 16.00, 'Todos'), 
('Martes Loco', 12.00, 'Martes');

INSERT INTO promocion (codigo_cupon, porcentaje_descuento, monto_descuento, fecha_inicio, fecha_fin, limite_usos) VALUES
('FILMATE2026', 10.00, NULL, '2026-05-01 00:00:00', '2026-12-31 23:59:59', 500);

INSERT INTO funcion (id_pelicula, id_sala, fecha_hora_inicio, fecha_hora_fin, idioma, formato) VALUES
(1, 1, '2026-05-25 19:00:00', '2026-05-25 22:00:00', 'Subtitulada', 'MACRO XE'),
(2, 2, '2026-05-25 16:00:00', '2026-05-25 18:00:00', 'Doblada', 'VIP');

INSERT INTO funcion_asiento (id_funcion, id_asiento, estado) VALUES
(1, 1, 'Vendido'), (1, 2, 'Vendido'), (1, 3, 'Disponible'),
(1, 4, 'Disponible'), (1, 5, 'Disponible'), (1, 6, 'Disponible');

INSERT INTO reserva (id_usuario, id_funcion, id_promocion, fecha_expiracion, monto_subtotal, descuento_aplicado, monto_total, estado_pago, metodo_pago, transaccion_id) VALUES
(2, 1, NULL, '2026-05-25 18:50:00', 45.00, 0.00, 45.00, 'Pagado', 'Tarjeta de Crédito', 'TXN-987654ABC');

INSERT INTO boleto (id_reserva, id_funcion, id_asiento, id_tarifa, codigo_qr, precio_pagado, estado_ingreso) VALUES
(1, 1, 1, 1, 'QR_TK_1001_FUNC1_AS1', 22.50, 'Vigente'),
(1, 1, 2, 1, 'QR_TK_1002_FUNC1_AS2', 22.50, 'Vigente');

INSERT INTO categoria_snack (nombre, orden_visual, estado) VALUES 
('Combos', 1, TRUE), 
('Cancha / Popcorn', 2, TRUE), 
('Bebidas', 3, TRUE);

INSERT INTO producto_snack (id_categoria, nombre, descripcion, precio_actual, url_imagen, is_activo) VALUES
(1, 'Combo Pareja', '1 Cancha Gigante + 2 Gaseosas Medianas', 35.00, 'https://img.filmate.com/snacks/combo_pareja.png', TRUE),
(1, 'Combo Familiar', '2 Canchas Gigantes + 4 Gaseosas Medianas + 2 Nachos', 65.00, 'https://img.filmate.com/snacks/combo_fam.png', TRUE),
(3, 'Gaseosa Grande 32oz', 'Coca Cola, Sprite, Fanta o Inka Kola', 12.00, 'https://img.filmate.com/snacks/gaseosa_gde.png', TRUE);

INSERT INTO reserva_snack (id_reserva, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 35.00);
