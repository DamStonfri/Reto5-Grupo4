
-- VISTAS  
-- ====================================================================

-- Recetas con el nombre de su autor
-- Abstrae el JOIN entre recetas y usuarios
CREATE OR REPLACE VIEW vista_recetas_completas AS
SELECT
    r.id,
    r.titulo,
    r.descripcion,
    r.imagen,
    r.creada_en,
    u.nombre   AS autor,
    u.email    AS email_autor,
    u.rol      AS rol_autor
FROM recetas r
JOIN usuarios u ON r.usuario_id = u.id;

-- Vista 2: Comentarios con datos del usuario y de la receta
-- Útil para mostrar todos los comentarios del sistema de un vistazo
CREATE VIEW vista_comentarios_detalle AS
SELECT
    c.id             AS comentario_id,
    c.contenido,
    c.creado_en,
    u.nombre         AS nombre_usuario,
    u.email          AS email_usuario,
    r.titulo         AS titulo_receta,
    r.id             AS receta_id
FROM comentarios c
JOIN usuarios  u ON c.usuario_id  = u.id
JOIN recetas   r ON c.receta_id   = r.id;

-- Vista 3: Menús con sus recetas y el autor de cada receta
-- Combina menus, menu_recetas, recetas y usuarios
CREATE VIEW vista_menus_completos AS
SELECT
    m.id             AS menu_id,
    m.nombre         AS nombre_menu,
    m.dia_semana,
    u_menu.nombre    AS creador_menu,
    r.id             AS receta_id,
    r.titulo         AS titulo_receta,
    r.imagen         AS imagen_receta,
    u_rec.nombre     AS autor_receta
FROM menus m
JOIN usuarios    u_menu ON m.usuario_id    = u_menu.id
JOIN menu_recetas   mr  ON m.id            = mr.menu_id
JOIN recetas         r  ON mr.receta_id    = r.id
JOIN usuarios    u_rec  ON r.usuario_id    = u_rec.id;


--  Usuarios y privilegios
-- ========================================================================================

-- Usuario de sólo lectura para la app web
CREATE USER IF NOT EXISTS 'recetas_lector'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT ON recetas_app.vista_recetas_completas TO 'recetas_lector'@'localhost';
GRANT SELECT ON recetas_app.vista_comentarios_detalle TO 'recetas_lector'@'localhost';
GRANT SELECT ON recetas_app.vista_menus_completos TO 'recetas_lector'@'localhost';

-- Usuario de aplicación: puede leer y escribir datos, pero NO borrar la BD
CREATE USER IF NOT EXISTS 'recetas_app'@'localhost' IDENTIFIED BY '1234!';
GRANT SELECT, INSERT, UPDATE, DELETE ON recetas_app.* TO 'recetas_app'@'localhost';

-- Usuario administrador: ya lo cree anteriormente, con nombre aimar y contraseña 1234ai
CREATE USER "aimar"@"%" identified by "1234ai";
GRANT ALL PRIVILEGES ON recetas_app.* TO "aimar"@"%";

-- aqui hago un revoke para eliminar el permiso de DELETE al usuario recetas_app ya que no debe de tener ese privilegio
-- (sólo el admin puede borrar comentarios directamente en BD)
REVOKE DELETE ON recetas_app.comentarios FROM 'recetas_app'@'localhost';

--   FUNCIONES
-- =========================================================================================

-- Devuelve cuántas recetas tiene un usuario
DELIMITER //
CREATE FUNCTION contar_recetas_usuario(p_usuario_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;

    SELECT COUNT(*) INTO total
    FROM recetas
    WHERE usuario_id = p_usuario_id;

    RETURN total;
END//
DELIMITER ;

-- Devuelve cuántos comentarios tiene una receta
DELIMITER //
CREATE FUNCTION contar_comentarios_receta(p_receta_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM comentarios
    WHERE receta_id = p_receta_id;
    RETURN total;
END//
DELIMITER ;

--   PROCEDIMIENTOS 
-- ============================================================

-- Procedimiento 1: Obtiene el resumen de una receta
DELIMITER //
CREATE PROCEDURE obtener_resumen_receta(
    IN  p_receta_id         INT,
    OUT p_titulo            VARCHAR(150),
    OUT p_autor             VARCHAR(100),
    OUT p_num_ingredientes  INT,
    OUT p_num_pasos         INT
)
BEGIN
    -- (control de errores)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_titulo           = NULL;
        SET p_autor            = NULL;
        SET p_num_ingredientes = -1;
        SET p_num_pasos        = -1;
        ROLLBACK;
    END;

    SELECT r.titulo, u.nombre
    INTO   p_titulo, p_autor
    FROM   recetas r
    JOIN   usuarios u ON r.usuario_id = u.id
    WHERE  r.id = p_receta_id;

    SET p_num_ingredientes = (
        SELECT COUNT(*) FROM ingredientes WHERE receta_id = p_receta_id
    );

    SET p_num_pasos = (
        SELECT COUNT(*) FROM pasos WHERE receta_id = p_receta_id
    );
END//
DELIMITER ;

-- Procedimiento para llamar a las dos funciones
DELIMITER //

CREATE PROCEDURE obtener_totales_usuario_y_receta(
    IN  p_usuario_id INT,
    IN  p_receta_id  INT,
    OUT p_total_recetas_usuario INT,
    OUT p_total_comentarios_receta INT
)
BEGIN
    SET p_total_recetas_usuario = contar_recetas_usuario(p_usuario_id);
    SET p_total_comentarios_receta = contar_comentarios_receta(p_receta_id);
END//

DELIMITER ;

-- 3 Elimina un menú y sus recetas asociadas de forma segura
DELIMITER //
CREATE PROCEDURE eliminar_menu_completo(
    IN  p_menu_id  INT,
    OUT p_mensaje  VARCHAR(200)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar el menú.';
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM menus WHERE id = p_menu_id) THEN
        SET p_mensaje = 'Error: el menú no existe.';
        ROLLBACK;
    ELSE
        DELETE FROM menu_recetas WHERE menu_id = p_menu_id;
        DELETE FROM menus         WHERE id     = p_menu_id;
        COMMIT;
        SET p_mensaje = 'Menú eliminado correctamente.';
    END IF;
END//
DELIMITER ;

-- TRIGGERS  
-- ==============================================================================================================

-- Trigger 1
--   Impide que una persona ponga un comentario nulo o con menos de 3 caracteres
DELIMITER //
CREATE TRIGGER trg_validar_comentario
BEFORE INSERT ON comentarios
FOR EACH ROW
BEGIN
-- Aqui me he ayudado de chatgpt ya que no sabia como hacerlo bien(linea 215)
    IF NEW.contenido IS NULL OR CHAR_LENGTH(TRIM(NEW.contenido)) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El comentario debe tener al menos 3 caracteres.';
    END IF;
    -- Eliminar espacios extra al inicio y al final
    SET NEW.contenido = TRIM(NEW.contenido);
END//
DELIMITER ;


-- Trigger 2 CREAR FUNCION 
--   Mejora el titulo (primera letra mayuscula, sin espacios extra)
DELIMITER //
CREATE TRIGGER trg_normalizar_receta
BEFORE INSERT ON recetas
FOR EACH ROW
BEGIN
-- TRIM quita espacios y CHAR_LENGHT devuelve el numero de caracteres
    IF NEW.titulo IS NULL OR CHAR_LENGTH(TRIM(NEW.titulo)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El título de la receta no puede estar vacío.';
    END IF;
    -- Normalizar: trim + primera letra en mayúscula
    SET NEW.titulo = CONCAT(
        UPPER(LEFT(TRIM(NEW.titulo), 1)),
        LOWER(SUBSTRING(TRIM(NEW.titulo), 2))
	-- substring saca una aprte del texto
    );
END//
DELIMITER ;

-- Trigger 3 
--   Cuando se borra una receta, elimina automáticamente sus ingredientes,
DELIMITER //
CREATE TRIGGER trg_limpiar_receta
AFTER DELETE ON recetas
FOR EACH ROW
BEGIN
    DELETE FROM ingredientes WHERE receta_id = OLD.id;
    DELETE FROM pasos WHERE receta_id = OLD.id;
    DELETE FROM comentarios WHERE receta_id = OLD.id;
    DELETE FROM menu_recetas WHERE receta_id = OLD.id;
END//
DELIMITER ;