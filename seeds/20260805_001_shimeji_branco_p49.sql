-- SmartMushroom
-- Seed: parâmetros iniciais do Shimeji Branco P-49
-- Banco de dados: MySQL 8.4 LTS

SET NAMES utf8mb4;
SET time_zone = '+00:00';

START TRANSACTION;

INSERT INTO cogumelo (
    nome,
    nome_cientifico,
    linhagem
) VALUES (
    'Shimeji Branco',
    'Pleurotus ostreatus',
    'P-49'
);

SET @id_cogumelo_p49 = LAST_INSERT_ID();

INSERT INTO fase_cultivo (
    id_cogumelo,
    nome,
    ordem,
    temperatura_ambiente_min,
    temperatura_ambiente_max,
    temperatura_composto_min,
    temperatura_composto_max,
    umidade_ambiente_min,
    umidade_ambiente_max,
    co2_max,
    fotoperiodo_minutos
) VALUES
(
    @id_cogumelo_p49,
    'Colonização',
    1,
    23.00,
    25.00,
    25.00,
    28.00,
    50.00,
    60.00,
    10000.00,
    0
),
(
    @id_cogumelo_p49,
    'Frutificação',
    2,
    23.00,
    28.00,
    NULL,
    NULL,
    80.00,
    95.00,
    800.00,
    720
);

COMMIT;