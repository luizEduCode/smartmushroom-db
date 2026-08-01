-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: smartmushroom_db
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

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
-- Table structure for table `alerta`
--

DROP TABLE IF EXISTS `alerta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alerta` (
  `idAlerta` int(11) NOT NULL AUTO_INCREMENT,
  `idLote` int(11) NOT NULL,
  `idAtuador` int(11) DEFAULT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idAlerta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `atuador`
--

DROP TABLE IF EXISTS `atuador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atuador` (
  `idAtuador` int(11) NOT NULL AUTO_INCREMENT,
  `idSala` int(11) NOT NULL,
  `nomeAtuador` varchar(100) NOT NULL,
  `tipoAtuador` enum('umidade','temperatura','co2','luz') NOT NULL,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idAtuador`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cogumelo`
--

DROP TABLE IF EXISTS `cogumelo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cogumelo` (
  `idCogumelo` int(11) NOT NULL AUTO_INCREMENT,
  `nomeCogumelo` varchar(100) NOT NULL,
  `descricao` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idCogumelo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `configuracao`
--

DROP TABLE IF EXISTS `configuracao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracao` (
  `idConfig` int(11) NOT NULL AUTO_INCREMENT,
  `idLote` int(11) NOT NULL,
  `idUsuario` int(11) DEFAULT 0,
  `umidadeMin` decimal(5,2) NOT NULL,
  `umidadeMax` decimal(5,2) NOT NULL,
  `temperaturaMin` decimal(5,2) NOT NULL,
  `temperaturaMax` decimal(5,2) NOT NULL,
  `co2Max` decimal(7,2) NOT NULL,
  `luz` enum('ligado','desligado') NOT NULL DEFAULT 'ligado',
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idConfig`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `controle_atuador`
--

DROP TABLE IF EXISTS `controle_atuador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `controle_atuador` (
  `idControle` int(11) NOT NULL AUTO_INCREMENT,
  `idAtuador` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL DEFAULT 0,
  `idLote` int(11) NOT NULL,
  `statusAtuador` enum('ativo','inativo') NOT NULL DEFAULT 'ativo',
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idControle`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fase_cultivo`
--

DROP TABLE IF EXISTS `fase_cultivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fase_cultivo` (
  `idFaseCultivo` int(11) NOT NULL AUTO_INCREMENT,
  `nomeFaseCultivo` varchar(100) NOT NULL,
  `idCogumelo` int(11) NOT NULL,
  `descricaoFaseCultivo` varchar(200) DEFAULT NULL,
  `temperaturaMin` decimal(5,2) NOT NULL,
  `temperaturaMax` decimal(5,2) NOT NULL,
  `umidadeMin` decimal(5,2) NOT NULL,
  `umidadeMax` decimal(5,2) NOT NULL,
  `co2Max` decimal(7,2) NOT NULL,
  PRIMARY KEY (`idFaseCultivo`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `historico_fase`
--

DROP TABLE IF EXISTS `historico_fase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_fase` (
  `idHistorico` int(11) NOT NULL AUTO_INCREMENT,
  `idLote` int(11) NOT NULL,
  `idFaseCultivo` int(11) NOT NULL,
  `dataMudanca` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idHistorico`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leitura`
--

DROP TABLE IF EXISTS `leitura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leitura` (
  `idLeitura` int(11) NOT NULL AUTO_INCREMENT,
  `idLote` int(11) NOT NULL,
  `umidade` decimal(5,2) NOT NULL,
  `temperatura` decimal(5,2) NOT NULL,
  `co2` decimal(7,2) NOT NULL,
  `luz` enum('ligado','desligado') NOT NULL DEFAULT 'ligado',
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idLeitura`)
) ENGINE=InnoDB AUTO_INCREMENT=16409 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log_sistema`
--

DROP TABLE IF EXISTS `log_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_sistema` (
  `idLog` int(11) NOT NULL AUTO_INCREMENT,
  `idUsuario` int(11) DEFAULT NULL,
  `acao` varchar(255) NOT NULL,
  `detalhes` varchar(255) DEFAULT NULL,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idLog`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lote`
--

DROP TABLE IF EXISTS `lote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lote` (
  `idLote` int(11) NOT NULL AUTO_INCREMENT,
  `idSala` int(11) NOT NULL,
  `idCogumelo` int(11) NOT NULL,
  `dataInicio` date NOT NULL,
  `dataFim` date DEFAULT NULL,
  `status` enum('ativo','finalizado') NOT NULL DEFAULT 'ativo',
  PRIMARY KEY (`idLote`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sala`
--

DROP TABLE IF EXISTS `sala`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sala` (
  `idSala` int(11) NOT NULL AUTO_INCREMENT,
  `nomeSala` varchar(100) NOT NULL,
  `descricaoSala` varchar(200) DEFAULT NULL,
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idSala`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `nomeUsuario` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `tipo` enum('admin','usuario') NOT NULL DEFAULT 'usuario',
  `dataCriacao` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idUsuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'smartmushroom_db'
--

--
-- Dumping routines for database 'smartmushroom_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `GerarDadosLeitura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GerarDadosLeitura`(
    IN p_dataInicio DATE,
    IN p_dataFim DATE,
    IN p_idLote INT,
    IN p_umidadeMin DECIMAL(5,2),
    IN p_umidadeMax DECIMAL(5,2),
    IN p_temperaturaMin DECIMAL(5,2),
    IN p_temperaturaMax DECIMAL(5,2),
    IN p_co2Max DECIMAL(7,2)
)
BEGIN
    DECLARE v_dataAtual DATE;
    DECLARE v_hora INT;
    DECLARE v_umidade DECIMAL(5,2);
    DECLARE v_temperatura DECIMAL(5,2);
    DECLARE v_co2 DECIMAL(7,2);
    DECLARE v_luz VARCHAR(10);
    DECLARE i INT;

    SET v_dataAtual = p_dataInicio;

    WHILE v_dataAtual <= p_dataFim DO
        SET v_hora = 0;

        WHILE v_hora < 24 DO
            
            -- Licht ligado entre 06:00 e 18:00
            IF v_hora >= 6 AND v_hora < 18 THEN
                SET v_luz = 'ligado';
            ELSE
                SET v_luz = 'desligado';
            END IF;

            -- 3 leituras por hora
            SET i = 1;
            WHILE i <= 3 DO
                
                SET v_umidade = p_umidadeMin + (RAND() * (p_umidadeMax - p_umidadeMin));
                SET v_temperatura = p_temperaturaMin + (RAND() * (p_temperaturaMax - p_temperaturaMin));
                SET v_co2 = RAND() * p_co2Max;

                INSERT INTO leitura (idLote, umidade, temperatura, co2, luz, dataCriacao)
                VALUES (
                    p_idLote,
                    ROUND(v_umidade, 2),
                    ROUND(v_temperatura, 2),
                    ROUND(v_co2, 2),
                    v_luz,
                    ADDTIME(
                        CONCAT(v_dataAtual, ' ', LPAD(v_hora, 2, '0'), ':00:00'),
                        SEC_TO_TIME(FLOOR(RAND() * 3600))
                    )
                );

                SET i = i + 1;
            END WHILE;

            SET v_hora = v_hora + 1;

        END WHILE;

        SET v_dataAtual = DATE_ADD(v_dataAtual, INTERVAL 1 DAY);
    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:56:38
