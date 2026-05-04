CREATE DATABASE recetas_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE recetas_app;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('admin', 'usuario') NOT NULL DEFAULT 'usuario',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recetas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    usuario_id INT NOT NULL,
    creada_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    receta_id INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    cantidad VARCHAR(60),
    FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE CASCADE
);

CREATE TABLE pasos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    receta_id INT NOT NULL,
    numero_paso INT NOT NULL,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE CASCADE
);

CREATE TABLE comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    receta_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE menus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    dia_semana ENUM('lunes','martes','miercoles','jueves','viernes','sabado','domingo') NOT NULL,
    usuario_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE menu_recetas (
    menu_id INT NOT NULL,
    receta_id INT NOT NULL,
    PRIMARY KEY (menu_id, receta_id),
    FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE,
    FOREIGN KEY (receta_id) REFERENCES recetas(id) ON DELETE CASCADE
);

ALTER TABLE recetas ADD COLUMN imagen VARCHAR(255) DEFAULT NULL;

CREATE USER "aimar"@"%" identified by "1234ai";

ALTER TABLE recetas ADD COLUMN imagen VARCHAR(255) DEFAULT NULL;

ALTER TABLE ingredientes 
ADD COLUMN categoria ENUM('proteina', 'vegetal', 'carbohidrato', 'otro') 
DEFAULT 'otro';
