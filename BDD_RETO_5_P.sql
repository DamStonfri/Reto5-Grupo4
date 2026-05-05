CREATE DATABASE  IF NOT EXISTS `recetas_app` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `recetas_app`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: recetas_app
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comentarios`
--

DROP TABLE IF EXISTS `comentarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comentarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `receta_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `contenido` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `receta_id` (`receta_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `comentarios_ibfk_1` FOREIGN KEY (`receta_id`) REFERENCES `recetas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comentarios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comentarios`
--

LOCK TABLES `comentarios` WRITE;
/*!40000 ALTER TABLE `comentarios` DISABLE KEYS */;
INSERT INTO `comentarios` VALUES (15,8,5,'Muy buena pinta!!','2026-05-05 10:15:40'),(16,9,5,'La tortilla tiene muy buena pinta','2026-05-05 10:24:49'),(17,10,6,'No me gusta mucho la avena pero tiene buena pinta !!','2026-05-05 10:29:48'),(18,11,6,'Yo tengo otra receta mejor de ensalada de garbanzos.','2026-05-05 10:30:09'),(19,13,7,'El wrap me gusta mas sin que sea integral','2026-05-05 10:34:58'),(20,12,7,'Que buena pinta tiene !!!','2026-05-05 10:35:12'),(21,14,8,'Yo se hacer mejores batidos.','2026-05-05 10:39:40'),(22,15,8,'Me lo comería ahora mismo','2026-05-05 10:39:54'),(23,17,9,'No me gusta mucho','2026-05-05 10:50:33'),(24,16,9,'Que rico el aguacate','2026-05-05 10:50:43'),(25,19,10,'No me gusta nada','2026-05-05 10:55:16'),(26,18,10,'Mala pinta la verdad','2026-05-05 10:55:30'),(27,20,11,'Buena pintaaaa','2026-05-05 10:57:03'),(28,21,11,'Muy buenooo\r\n','2026-05-05 10:57:17'),(29,22,12,'Muy saludable !\r\n','2026-05-05 11:01:37'),(30,23,12,'Que ricooo','2026-05-05 11:01:46'),(31,25,13,'rico el falafel','2026-05-05 11:10:22'),(32,24,13,'rico el tofu','2026-05-05 11:10:30'),(33,26,14,'hummus rico rico','2026-05-05 11:12:59'),(34,27,14,'muy buena pinta los tacos','2026-05-05 11:13:15'),(35,28,15,'rica sopa','2026-05-05 11:19:00'),(36,29,15,'rico guacamole','2026-05-05 11:19:09');
/*!40000 ALTER TABLE `comentarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_validar_comentario` BEFORE INSERT ON `comentarios` FOR EACH ROW BEGIN
-- Aqui me he ayudado de chatgpt ya que no sabia como hacerlo bien(linea 215)
    IF NEW.contenido IS NULL OR CHAR_LENGTH(TRIM(NEW.contenido)) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El comentario debe tener al menos 3 caracteres.';
    END IF;
    -- Eliminar espacios extra al inicio y al final
    SET NEW.contenido = TRIM(NEW.contenido);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ingredientes`
--

DROP TABLE IF EXISTS `ingredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `receta_id` int NOT NULL,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `categoria` enum('proteina','vegetal','carbohidrato','otro') COLLATE utf8mb4_unicode_ci DEFAULT 'otro',
  PRIMARY KEY (`id`),
  KEY `receta_id` (`receta_id`),
  CONSTRAINT `ingredientes_ibfk_1` FOREIGN KEY (`receta_id`) REFERENCES `recetas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredientes`
--

LOCK TABLES `ingredientes` WRITE;
/*!40000 ALTER TABLE `ingredientes` DISABLE KEYS */;
INSERT INTO `ingredientes` VALUES (18,8,'quinoa','100','carbohidrato'),(19,8,'pechuga de pollo','150','proteina'),(20,8,'aguacate','1/2','vegetal'),(21,8,'tomate','1','vegetal'),(22,8,'aceite','1 cda','otro'),(23,8,'sal y pimienta','A gusto de cada uno','otro'),(24,9,'Claras de huevos','4','proteina'),(25,9,'Espinaca','1 taza','vegetal'),(26,9,'Aceite de oliva','1 cda','otro'),(27,9,'Sal','A gusto de cada uno','proteina'),(28,10,'Avena','50','carbohidrato'),(29,10,'Leche','200','otro'),(30,10,'Chía','1 cda','otro'),(31,10,'Plátano','1/2','otro'),(32,11,'Garbanzos','150','proteina'),(33,11,'tomate','1/2','vegetal'),(34,11,'cebolla','1/4','vegetal'),(35,11,'Aceite','1 cda','otro'),(36,11,'Zumo de limon','1/2','otro'),(37,12,'salmon','150','proteina'),(38,12,'aceite de oliva','1 cdta','otro'),(39,12,'zumo de limon','A gusto de cada uno','otro'),(40,12,'sal','A gusto de cada uno','proteina'),(41,13,'Tortita Integral','1','otro'),(42,13,'Pavo','80','proteina'),(43,13,'lechuga','A gusto Personal','vegetal'),(44,13,'tomate','1/4','vegetal'),(45,13,'Mayonesa ligera','1 cdta ','otro'),(46,14,'Proteína','30','otro'),(47,14,'Leche','250','otro'),(48,14,'Plátano','1','otro'),(49,15,'Arroz integral','80','carbohidrato'),(50,15,'zanahoria','1','vegetal'),(51,15,'calabacin','1/2','vegetal'),(52,15,'aceite','1 cdta','otro'),(53,16,'Pan integral','1 rebanada','carbohidrato'),(54,16,'Aguacate','1/2','vegetal'),(55,16,'Huevo','1','proteina'),(56,16,'Sal','A gusto Personal','proteina'),(62,17,'Lentejas','150','proteina'),(63,17,'Cebolla','1/2','vegetal'),(64,17,'Curry','1 cdta','otro'),(65,17,'Leche de coco','200','otro'),(66,17,'Aceite','1 cdta','otro'),(73,18,'Tofu','150','proteina'),(74,18,'Pimiento','1/2','vegetal'),(75,18,'Salsa de soja','1 cda','otro'),(76,18,'Aceite','1 cdta','otro'),(77,19,'Garbanzos','200','proteina'),(78,19,'tahini','1 cda','otro'),(79,19,'Zumo de limón','1/2 limones','otro'),(80,19,'Agua','2 cds','vegetal'),(84,20,'Pasta','80','carbohidrato'),(85,20,'Tomate triturado','100','vegetal'),(86,20,'calabacin','1/2','vegetal'),(87,21,'tortilla','1','otro'),(88,21,'queso','50','proteina'),(90,22,'platano','1','otro'),(91,22,'huevo','1','proteina'),(92,22,'Avena','40','carbohidrato'),(93,23,'Lentejas','150','proteina'),(94,23,'cebolla','1/2','vegetal'),(95,23,'Ajo','1 diente','vegetal'),(96,23,'Leche de coco','200','otro'),(97,23,'Curry','1 cdta','otro'),(98,23,'cúrcuma','1/2','otro'),(99,23,'Aceite','1 cdta','otro'),(100,24,'Tofu','150','proteina'),(101,24,'Pimiento','1/2','vegetal'),(102,24,'Calabacin','1/2','vegetal'),(103,24,'Salsa de Soja','1 cda','otro'),(104,24,'Aceite ','1 cdta','otro'),(105,25,'Garbanzos','200','proteina'),(106,25,'Ajo','1 Diente','vegetal'),(107,25,'Perejil','A gusto personal','vegetal'),(108,25,'comino','1 cdta','otro'),(109,25,'harina','1 cda','carbohidrato'),(110,26,'Garbanzos','200','proteina'),(111,26,'Tahini','2 cdas','otro'),(112,26,'limón','1','otro'),(113,26,'Ajo','1 diente','vegetal'),(114,26,'Agua','3 cdas','vegetal'),(120,27,'Tortillas','2','otro'),(121,27,'Lentejas','100','proteina'),(122,27,'Lechuga','A gusto personal','vegetal'),(123,27,'Tomate','A gusto personal','vegetal'),(124,27,'salsa','A gusto personal','otro'),(129,28,'Zanahoria','1','vegetal'),(130,28,'Patata','1','carbohidrato'),(131,28,'Puerro','1/2','vegetal'),(132,28,'Agua','500','vegetal'),(133,29,'Aguacate','1','vegetal'),(134,29,'Tomate','1/2','vegetal'),(135,29,'Zumo de Limon','1/2 Limon','otro'),(136,29,'sal','A gusto personal','proteina'),(137,30,'Arroz','80','carbohidrato'),(138,30,'Tofu','150','proteina'),(139,30,'Soja','1 cda','otro'),(140,31,'Lechuga','A gusto oersonal','vegetal'),(141,31,'Tomate','A gusto Personal','vegetal'),(145,32,'zanahoria','1','vegetal'),(146,32,'calabacin','1/2','vegetal'),(147,32,'pimiento','1/2','vegetal');
/*!40000 ALTER TABLE `ingredientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_recetas`
--

DROP TABLE IF EXISTS `menu_recetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_recetas` (
  `menu_id` int NOT NULL,
  `receta_id` int NOT NULL,
  PRIMARY KEY (`menu_id`,`receta_id`),
  KEY `receta_id` (`receta_id`),
  CONSTRAINT `menu_recetas_ibfk_1` FOREIGN KEY (`menu_id`) REFERENCES `menus` (`id`) ON DELETE CASCADE,
  CONSTRAINT `menu_recetas_ibfk_2` FOREIGN KEY (`receta_id`) REFERENCES `recetas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_recetas`
--

LOCK TABLES `menu_recetas` WRITE;
/*!40000 ALTER TABLE `menu_recetas` DISABLE KEYS */;
INSERT INTO `menu_recetas` VALUES (5,9),(7,11),(8,13),(9,14),(9,15),(7,16),(4,18),(5,20),(6,23),(3,24),(4,24),(8,24),(6,25),(7,26),(6,27),(3,28),(8,29),(5,31),(9,31),(3,32),(4,32);
/*!40000 ALTER TABLE `menu_recetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menus` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dia_semana` enum('lunes','martes','miercoles','jueves','viernes','sabado','domingo') COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `menus_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
INSERT INTO `menus` VALUES (3,'Furia del Pacífico','lunes',1),(4,'Susurro Japones','martes',1),(5,'Tormenta Italiana','miercoles',1),(6,'Fuego Balcánico','jueves',1),(7,'Susurro Cítrico','viernes',1),(8,'Onda Fresca','sabado',1),(9,'Eco Suave','domingo',1);
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pasos`
--

DROP TABLE IF EXISTS `pasos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pasos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `receta_id` int NOT NULL,
  `numero_paso` int NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `receta_id` (`receta_id`),
  CONSTRAINT `pasos_ibfk_1` FOREIGN KEY (`receta_id`) REFERENCES `recetas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pasos`
--

LOCK TABLES `pasos` WRITE;
/*!40000 ALTER TABLE `pasos` DISABLE KEYS */;
INSERT INTO `pasos` VALUES (13,8,1,'Lava la quinoa bajo el grifo.'),(14,8,2,'Cuece con 200 ml de agua durante 15 min (hasta que absorba el agua).'),(15,8,3,'Corta el pollo en trozos y salpimenta.'),(16,8,4,'Cocínalo en sartén 6–8 min hasta dorar.'),(17,8,5,'Corta el aguacate y tomate.'),(18,8,6,'Sirve todo junto y añade aceite de oliva.'),(19,9,1,'Lava las espinacas.'),(20,9,2,'Saltéalas 2–3 min.'),(21,9,3,'Añade claras batidas.'),(22,9,4,'Cocina a fuego medio 4–5 min.'),(23,9,5,'Dobla y sirve.'),(24,10,1,'Mezcla avena, leche y chía.'),(25,10,2,'Guarda en la nevera mínimo 6 horas.'),(26,10,3,'Añade el plátano en rodajas antes de comer.'),(27,11,1,'Lava los garbanzos.'),(28,11,2,'Corta tomate y cebolla.'),(29,11,3,'Mezcla todo.'),(30,11,4,'Añade aceite y limón.'),(31,12,1,'Precalienta horno a 180°C.'),(32,12,2,'Coloca el salmón en bandeja.'),(33,12,3,'Añade aceite, sal y limón.'),(34,12,4,'Hornea 12–15 min.'),(35,13,1,'Lava y corta verduras.'),(36,13,2,'Unta la tortilla con mayonesa.'),(37,13,3,'Añade pavo y verduras.'),(38,13,4,'Enrolla bien.'),(39,14,1,'Mete todo en la batidora.'),(40,14,2,'Tritura 30–40 segundos.'),(41,14,3,'Sirve frío.'),(42,15,1,'Cuece el arroz 20 min.'),(43,15,2,'Corta verduras.'),(44,15,3,'Saltéalas 5–7 min.'),(45,15,4,'Mezcla con el arroz.'),(46,16,1,'Tuesta el pan.'),(47,16,2,'Machaca el aguacate.'),(48,16,3,'Fríe o cuece el huevo.'),(49,16,4,'Monta todo encima.'),(54,17,1,'Sofríe la cebolla picada.'),(55,17,2,'Añade curry y mezcla.'),(56,17,3,'Incorpora lentejas y leche de coco.'),(57,17,4,'Cocina 10 min.'),(66,18,1,'Corta el tofu en cubos.'),(67,18,2,'Saltéalo 5 min.'),(68,18,3,'Añade verduras.'),(69,18,4,'Incorpora soja y cocina 3 min más.'),(70,19,1,'Tritura todos los ingredientes.'),(71,19,2,'Añade agua poco a poco.'),(72,19,3,'Ajusta textura y sal.'),(77,20,1,'Cuece la pasta.'),(78,20,2,'Cocina el calabacín.'),(79,20,3,'Añade tomate y cocina 5 min.'),(80,20,4,'Mezcla con la pasta.'),(81,21,1,'Coloca queso en tortilla.'),(82,21,2,'Dobla.'),(83,21,3,'Cocina 3 min por lado.'),(84,22,1,'Tritura todo.'),(85,22,2,'Vierte en sartén.'),(86,22,3,'Cocina 2–3 min por lado.'),(87,23,1,'Pica cebolla y ajo.'),(88,23,2,'Sofríe en aceite 3–4 min.'),(89,23,3,'Añade curry y cúrcuma.'),(90,23,4,'Incorpora lentejas y leche de coco.'),(91,23,5,'Cocina 10–12 min a fuego medio.'),(92,24,1,'Corta tofu en cubos.'),(93,24,2,'Cocínalo 5–6 min hasta dorar.'),(94,24,3,'Añade verduras en tiras.'),(95,24,4,'Saltea 5 min más.'),(96,24,5,'Añade soja y mezcla.'),(97,25,1,'Tritura todo.'),(98,25,2,'Forma bolitas.'),(99,25,3,'Hornea a 180°C durante 20 min.'),(100,26,1,'Tritura todo.'),(101,26,2,'Añade agua poco a poco.'),(102,26,3,'Ajusta textura.'),(107,27,1,'Calienta tortillas.'),(108,27,2,'Añade lentejas calientes.'),(109,27,3,'Incorpora verduras.'),(110,27,4,'Añade salsa.'),(114,28,1,'Corta todo.'),(115,28,2,'Hierve 20 min.'),(116,28,3,'Tritura hasta textura deseada.'),(117,29,1,'Machaca el aguacate.'),(118,29,2,'Añade tomate picado.'),(119,29,3,'Incorpora limón y sal.'),(120,30,1,'Cuece el arroz.'),(121,30,2,'Saltea tofu.'),(122,30,3,'Mezcla con soja.'),(123,31,1,'Lava y corta.'),(124,31,2,'Aliña.'),(130,32,1,'Corta todas las verduras en trozos pequeños.'),(131,32,2,'Calienta el aceite en una sartén.'),(132,32,3,'Añade las verduras.'),(133,32,4,'Cocina 8–10 minutos removiendo.'),(134,32,5,'Añade sal y listo.');
/*!40000 ALTER TABLE `pasos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recetas`
--

DROP TABLE IF EXISTS `recetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recetas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `usuario_id` int NOT NULL,
  `creada_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `imagen` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `recetas_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recetas`
--

LOCK TABLES `recetas` WRITE;
/*!40000 ALTER TABLE `recetas` DISABLE KEYS */;
INSERT INTO `recetas` VALUES (8,'Bowl de pollo con quinoa','Plato completo alto en proteína y carbohidratos complejos, ideal para comidas post-entreno.',4,'2026-05-05 10:13:44','20260505121344_quinoa.webp'),(9,'Tortilla de claras con espinacas','Muy baja en calorías y rica en proteína, perfecta para cenas ligeras.',4,'2026-05-05 10:21:13','20260505122113_tortillaclaraespinaca.webp'),(10,'Avena overnight','Desayuno práctico que se prepara la noche anterior, energético y saciante.',5,'2026-05-05 10:24:15','20260505122415_avenaovernight.webp'),(11,'Ensalada de garbanzos','Opción rápida, rica en fibra y proteína vegetal.',5,'2026-05-05 10:27:09','20260505122709_ensaladagarbanzos.webp'),(12,'Salmón al horno','Fuente excelente de grasas saludables (omega 3) y proteína.',6,'2026-05-05 10:29:27','20260505122927_salmonalhorno.webp'),(13,'Wrap integral de pavo','Comida rápida equilibrada, fácil de llevar.',6,'2026-05-05 10:32:16','20260505123216_wrap.webp'),(14,'Batido proteico','Ideal para recuperación muscular tras entrenar.',7,'2026-05-05 10:34:38','20260505123438_batido.webp'),(15,'Arroz integral con verduras','Plato energético y nutritivo con carbohidratos de liberación lenta.',7,'2026-05-05 10:39:03','20260505123903_arrozintegralc.webp'),(16,'Tostada de aguacate y huevo','Desayuno o cena equilibrada con grasas saludables y proteína.',8,'2026-05-05 10:41:41','20260505124141_tosatada.webp'),(17,'Curry de lentejas (vegano)','Plato vegano muy saciante, rico en proteína vegetal y especias.',8,'2026-05-05 10:45:05','20260505124505_curryvegano.webp'),(18,'Tofu salteado','Alternativa vegetal a la carne, rica en proteína.',9,'2026-05-05 10:49:34','20260505124934_tofusalteado.webp'),(19,'Hummus casero','Dip saludable ideal para snacks o acompañamientos.',9,'2026-05-05 10:52:58','20260505125258_hummus.webp'),(20,'Pasta vegana','Versión ligera y vegetal de un clásico energético.',10,'2026-05-05 10:54:52','20260505125452_pastavegana.webp'),(21,'Quesadilla rápida','Opción sencilla y reconfortante para comidas rápidas.',10,'2026-05-05 10:56:41','20260505125641_quesadilla.webp'),(22,'Pancakes saludables','Desayuno dulce sin azúcares añadidos.',11,'2026-05-05 10:57:58','20260505125758_pankake.webp'),(23,'Curry de lentejas mejorado (vegano)','Versión más sabrosa y especiada, muy completa nutricionalmente.',11,'2026-05-05 11:01:17','20260505130117_currylentejas.webp'),(24,'Tofu salteado con verduras','Plato equilibrado vegano con proteína y fibra.',12,'2026-05-05 11:04:52','20260505130452_tofusalteadoconverura.webp'),(25,'Falafel al horno','Alternativa saludable al falafel frito, crujiente y nutritivo.',12,'2026-05-05 11:08:01','20260505130801_falafel.webp'),(26,'Hummus cremoso','Más suave y untuoso, ideal para untar o dipear.',13,'2026-05-05 11:10:00','20260505131000_hummuscremoso.webp'),(27,'Tacos veganos','Comida divertida y saludable con proteína vegetal.',13,'2026-05-05 11:11:48','20260505131222_tacovegano.webp'),(28,'Sopa de verduras','Ligera, digestiva y perfecta para días fríos.',14,'2026-05-05 11:14:21','20260505131523_sopadeverdura.webp'),(29,'Guacamole clásico','Salsa saludable rica en grasas buenas.',14,'2026-05-05 11:18:37','20260505131837_guacamole.webp'),(30,'Arroz con tofu','Plato básico vegano, económico y saciante.',15,'2026-05-05 11:20:54','20260505132054_arrozcontofu.webp'),(31,'Ensalada basica','Ensalada basica para comer a cualquier hora del día',15,'2026-05-05 11:24:54','20260505132454_ensaladabasica.webp'),(32,'Verduras salteadas simples','plato vegetal muy fácil, ligero y saludable.',16,'2026-05-05 11:27:47','20260505132818_verduras.webp');
/*!40000 ALTER TABLE `recetas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_normalizar_receta` BEFORE INSERT ON `recetas` FOR EACH ROW BEGIN
    CALL sp_normalizar_titulo(NEW.titulo);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_limpiar_receta` AFTER DELETE ON `recetas` FOR EACH ROW BEGIN
    DELETE FROM ingredientes WHERE receta_id = OLD.id;
    DELETE FROM pasos WHERE receta_id = OLD.id;
    DELETE FROM comentarios WHERE receta_id = OLD.id;
    DELETE FROM menu_recetas WHERE receta_id = OLD.id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('admin','usuario') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'usuario',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Aimar Garcia (Admin)','aimargarciacebanc@gmail.com','scrypt:32768:8:1$Ci3aJxLqJXzcVSdY$df539f1cc77da3c115f026366c3813958b57c93aa8d39572979ef2964a2674f0c7264a931a5d791d26ed9f5f6eba4861009a788580951050055a1c4f0b0c6480','admin','2026-04-29 08:21:01'),(2,'Andoni ramirez (Admin)','andoniramirez46@gmail.com','scrypt:32768:8:1$zFSdtoCzNILvthw7$47bdb500298511a5172250cd40c234bcf81b81b178714d8ce1cec0709dbae404e2e22b8d30f802daf054cdb8435b97bfee5ba0e5232b58bec09521fd5acf2c32','admin','2026-04-29 08:21:13'),(3,'Alex segurola (Admin)','dam.alex.cebanc@gmail.com','scrypt:32768:8:1$KSl5tLyBW3AYjIjz$b835b89fe62690c014889318156ccf5a6bba4d3a849ab5c3a189f09b7393e21574509360339d65714b28d48a6fafc6298dae91afc4e8c379cb9e2a382ad6bf47','admin','2026-04-29 08:21:23'),(4,'Unax Gahona','unaxgahona@gmail.com','scrypt:32768:8:1$mpfUjguLGRvFINYA$a4ee0e793a5e3b9de456e5cf49eb7788df5cc382f709139231d29f626df384bda14a08acb08beb86d318636a039361701be4536f7e5f3f06a092e014bdd328c1','usuario','2026-04-30 09:39:52'),(5,'Ibon Ye','ibonye@gmail.com','scrypt:32768:8:1$JKD9hodrOq84nBRW$cdcb717d401aab585536bcfcb27cd0a80d1ee1431bc56ac6bee1026b1f6a2a8c34f95fffc40ecefc930cfc6f9fb23b48a39a3d7987ff326e9153f43a408c5b98','usuario','2026-04-30 09:40:05'),(6,'Ibon Etxegia','ibonetxegia@gmail.com','scrypt:32768:8:1$xUMTGWbGw7NhIBLt$6b00b8abeea8e7039273222b8614e439bd04a171577029d5b6d1d2d7ff1e957eb7a8547b342ae69499c1edd7739be3374c4b1f7f5b19a11fac76e8c2d2f012e4','usuario','2026-04-30 09:40:21'),(7,'Unai Manterola','unaimanterola@gmail.com','scrypt:32768:8:1$INYweMr9I526ijLO$47b6e4c5d0c305731cb8614e6a4d6205668eb8c0a49eaed67e0b1ad351cf2b06f3f2206daa6cf4e5f2c8df889879016ac32d2ab9ee18d4dbbf87b0193dfa3a5a','usuario','2026-04-30 09:40:47'),(8,'Mikel Villa','mikelvilla@gmail.com','scrypt:32768:8:1$B7KdTuLuoRAxdSvn$cf9d57f80d898c976b7d1cab3d397ce153ea4c8dd07ec4d84d7e1e9ee7aef8b51755552c2168509eb75adea209cc88df0822834289ae907565abc84b8019d7e6','usuario','2026-04-30 09:41:25'),(9,'Juan Manuel Martin','juanmanuelmartin@gmail.com','scrypt:32768:8:1$1SGg0lXNJdeyQFo8$0ae542c70f4319614a4c4c2e5b889ee57055e487b206fcacd5eb0d09cd2defae4b4f8b1cb344d3443d15b0c2e6dc596ba640ba73309bc18f59b793b6296255e2','usuario','2026-04-30 09:41:48'),(10,'Xabier Morales ','xabiermorales@gmail.com','scrypt:32768:8:1$WECVi1adKtb330zK$c609c315b310da9c5ff66901af9d501ba3f4fe6ca1a365b69f639b220c7b1f4bbc2ee3aa87a189ad75bc7e18821dc9f514559ea4224c9a3431d0269e18771071','usuario','2026-04-30 09:42:23'),(11,'Xabier Iglesias','xabieriglesias@gmail.com','scrypt:32768:8:1$DhhH7PAjeJs9yDTg$ebd00f738023ad0cff154ed59ef6c5c9211debff412df4707ba466581ed5f72f5e2f6145ae448f33490317f975aa494226e61f7b09a5950a9cf663f1429f3075','usuario','2026-04-30 09:42:41'),(12,'Joseba La Torre','josebalatorre@gmail.com','scrypt:32768:8:1$oR3AraVut0rS55OU$061ff2c8ff611c9fc71a210a919b56c0e5e7e80f7562c36f90e887b73934d5b5a233b3a9fdff279ebd556c32fa5b062a19fe782297822068759c350f59a3d391','usuario','2026-04-30 09:43:05'),(13,'Marko Ansa','markoansa@gmail.com','scrypt:32768:8:1$ZBhQpEMN13LWEO8P$f52583c96e14524f68abc685412b07788fd455a6ec34c3b5dfcb39fb85a2c9e0fde2cacfadf6818bf29ff36d10d26ffffcf3e7072a9134335d445ed51bfc03be','usuario','2026-04-30 09:43:32'),(14,'Hugo Rayo','hugorayo@gmail.com','scrypt:32768:8:1$OOJGRwaGZitQStBk$9dd57b86c1ca9f85770af235973218b2c0c35f1f905e6beea9cc754de7984d54f9c30a46ae392d5492a997075ad349521cfce33a9ff577a559f050ee5e996b68','usuario','2026-04-30 09:44:04'),(15,'Peru Gainza','perugainza@gmail.com','scrypt:32768:8:1$nmDq6SYXUKsfGG6q$85298140eaad75781504ae11966b1dbcc189769f4c99b28c674e3a4384c5d56c29c2fbf0da3d912a5bb5a7d2285afc4ae46f7c7eaa50de3dd7840d9de4d39130','usuario','2026-04-30 09:44:34'),(16,'Jon Murugarren','jonmurugarren@gmail.com','scrypt:32768:8:1$oNdcFGyLbLGGXzxm$337a27fc2e022823a09e64a2497144b93b6867ece260423bdaa2b154014a796e499278e7b17ba1b100ab73a42234e48164e9f6cec28ca5be5aa07f99db12f788','usuario','2026-04-30 09:44:56'),(17,'Andoni Ramirez','andoniramirez@gmail.com','scrypt:32768:8:1$7sD2CSa11LiiAz0s$1dc893362bb61fdb39dfa474e6b1c7b12432c5e05fd0c2858db4ebd185b7cbdcae1c9e5c0abbea20853145a653cc80b9b06803869f0a4c9c2b6623d10d04f378','usuario','2026-04-30 09:46:13'),(18,'Aaron Benitez','aaronbenitez@gmail.com','scrypt:32768:8:1$j1LXxCDfZv8ptSOX$3ed1b6c560bda64bf81a993c0d8e34c5e499b44d87767c25e686862145f9fdcfc2e66f30c715857c1a765059d99e9e37ee8fbd0d9536dd9dc61741afc0c6d66c','usuario','2026-04-30 09:47:29'),(19,'Marta rivas','Martarivas@gmail.com','scrypt:32768:8:1$8jpPIfOvdjMfhXRM$7dc6204590f66dc19692b3b9b0075eb110cac579c97248953c8cd33750692e42c311bbda9489ed3bd1c7f30005eeeba17fa5c3b1435b13f62d4009c73a2e7aa7','usuario','2026-05-05 06:53:35');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_comentarios_detalle`
--

DROP TABLE IF EXISTS `vista_comentarios_detalle`;
/*!50001 DROP VIEW IF EXISTS `vista_comentarios_detalle`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_comentarios_detalle` AS SELECT 
 1 AS `comentario_id`,
 1 AS `contenido`,
 1 AS `creado_en`,
 1 AS `nombre_usuario`,
 1 AS `email_usuario`,
 1 AS `titulo_receta`,
 1 AS `receta_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_menus_completos`
--

DROP TABLE IF EXISTS `vista_menus_completos`;
/*!50001 DROP VIEW IF EXISTS `vista_menus_completos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_menus_completos` AS SELECT 
 1 AS `menu_id`,
 1 AS `nombre_menu`,
 1 AS `dia_semana`,
 1 AS `creador_menu`,
 1 AS `receta_id`,
 1 AS `titulo_receta`,
 1 AS `imagen_receta`,
 1 AS `autor_receta`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_recetas_completas`
--

DROP TABLE IF EXISTS `vista_recetas_completas`;
/*!50001 DROP VIEW IF EXISTS `vista_recetas_completas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_recetas_completas` AS SELECT 
 1 AS `id`,
 1 AS `titulo`,
 1 AS `descripcion`,
 1 AS `imagen`,
 1 AS `creada_en`,
 1 AS `autor`,
 1 AS `email_autor`,
 1 AS `rol_autor`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'recetas_app'
--
/*!50003 DROP FUNCTION IF EXISTS `contar_comentarios_receta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `contar_comentarios_receta`(p_receta_id INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM comentarios
    WHERE receta_id = p_receta_id;
    RETURN total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `contar_recetas_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `contar_recetas_usuario`(p_usuario_id INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT COUNT(*) INTO total
    FROM recetas
    WHERE usuario_id = p_usuario_id;

    RETURN total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `eliminar_menu_completo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_menu_completo`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_resumen_receta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_resumen_receta`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_totales_usuario_y_receta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_totales_usuario_y_receta`(
    IN  p_usuario_id INT,
    IN  p_receta_id  INT,
    OUT p_total_recetas_usuario INT,
    OUT p_total_comentarios_receta INT
)
BEGIN
    SET p_total_recetas_usuario = contar_recetas_usuario(p_usuario_id);
    SET p_total_comentarios_receta = contar_comentarios_receta(p_receta_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_normalizar_titulo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_normalizar_titulo`(INOUT p_titulo VARCHAR(255))
BEGIN
    IF p_titulo IS NULL OR CHAR_LENGTH(TRIM(p_titulo)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El título de la receta no puede estar vacío.';
    END IF;

    SET p_titulo = CONCAT(
        UPPER(LEFT(TRIM(p_titulo), 1)),
        LOWER(SUBSTRING(TRIM(p_titulo), 2))
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vista_comentarios_detalle`
--

/*!50001 DROP VIEW IF EXISTS `vista_comentarios_detalle`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_comentarios_detalle` AS select `c`.`id` AS `comentario_id`,`c`.`contenido` AS `contenido`,`c`.`creado_en` AS `creado_en`,`u`.`nombre` AS `nombre_usuario`,`u`.`email` AS `email_usuario`,`r`.`titulo` AS `titulo_receta`,`r`.`id` AS `receta_id` from ((`comentarios` `c` join `usuarios` `u` on((`c`.`usuario_id` = `u`.`id`))) join `recetas` `r` on((`c`.`receta_id` = `r`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_menus_completos`
--

/*!50001 DROP VIEW IF EXISTS `vista_menus_completos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_menus_completos` AS select `m`.`id` AS `menu_id`,`m`.`nombre` AS `nombre_menu`,`m`.`dia_semana` AS `dia_semana`,`u_menu`.`nombre` AS `creador_menu`,`r`.`id` AS `receta_id`,`r`.`titulo` AS `titulo_receta`,`r`.`imagen` AS `imagen_receta`,`u_rec`.`nombre` AS `autor_receta` from ((((`menus` `m` join `usuarios` `u_menu` on((`m`.`usuario_id` = `u_menu`.`id`))) join `menu_recetas` `mr` on((`m`.`id` = `mr`.`menu_id`))) join `recetas` `r` on((`mr`.`receta_id` = `r`.`id`))) join `usuarios` `u_rec` on((`r`.`usuario_id` = `u_rec`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_recetas_completas`
--

/*!50001 DROP VIEW IF EXISTS `vista_recetas_completas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_recetas_completas` AS select `r`.`id` AS `id`,`r`.`titulo` AS `titulo`,`r`.`descripcion` AS `descripcion`,`r`.`imagen` AS `imagen`,`r`.`creada_en` AS `creada_en`,`u`.`nombre` AS `autor`,`u`.`email` AS `email_autor`,`u`.`rol` AS `rol_autor` from (`recetas` `r` join `usuarios` `u` on((`r`.`usuario_id` = `u`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-05 13:54:20
