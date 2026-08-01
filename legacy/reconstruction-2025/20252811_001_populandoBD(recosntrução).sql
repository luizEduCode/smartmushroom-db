-- ================================
-- TABELA: usuario
-- ================================

INSERT INTO usuario (nomeUsuario, email, senha, tipo) 
VALUES (
    'Administrador', 
    'admin@smartmushroom.com', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',  -- senha: "password"
    'admin'
);

-- ================================
-- TABELA: sala
-- ================================
INSERT INTO sala (nomeSala, descricaoSala)
VALUES 
('Sala 01', 'Estufa climatizada Cogumelos'),
('Sala 02', 'Estufa climatizada Cogumelos'),
('Sala 03', 'Estufa climatizada Cogumelos'),
('Sala 04', 'Estufa climatizada Cogumelos');

-- ================================
-- TABELA: cogumelo
-- ================================
INSERT INTO cogumelo (nomeCogumelo, descricao)
VALUES 
('Shimeji Branco', 'Pleurotus Ostreatus'),
('Champignon', 'Agaricus Bisporus'),
('Shitake', 'Lentinula Edodes');

-- ================================
-- TABELA: fase_cultivo
-- ================================
-- Shimeji (Pleurotus ostreatus) — idCogumelo = 1
INSERT INTO fase_cultivo (nomeFaseCultivo, idCogumelo, descricaoFaseCultivo, temperaturaMin, temperaturaMax, umidadeMin, umidadeMax, co2Max)
VALUES
('Colonização', 1, 'Crescimento do micélio no substrato em ambiente escuro e úmido até colonização completa', 20, 24, 65, 75, 1500),
('Indução',      1, 'Transição ambiental: troca de ar, leve luminosidade e estímulo para primórdios', 16, 20, 80, 90, 1200),
('Frutificação', 1, 'Formação dos corpos frutíferos — crescimento dos cogumelos até colheita', 17, 20, 85, 95, 1000);

INSERT INTO atuador (idSala, nomeAtuador, tipoAtuador)
VALUES
(1, 'umidificador', 'umidade'),
(1, 'aquecedor', 'temperatura'),
(1, 'exaustor', 'co2'),
(1, 'iluminacao', 'luz');
-- Champignon (Agaricus bisporus) — idCogumelo = 2
INSERT INTO fase_cultivo (nomeFaseCultivo, idCogumelo, descricaoFaseCultivo, temperaturaMin, temperaturaMax, umidadeMin, umidadeMax, co2Max)
VALUES
('Colonização',         2, 'Corrida do micélio no composto até colonização completa', 23, 23, 90, 92, 2000),
('Indução / Iniciação', 2, 'Rebaixamento” de temperatura e umidade para induzir primórdios', 16, 18, 85, 90, 2000),
('Frutificação',        2, 'Formação e crescimento dos cogumelos após cobertura', 16, 18, 85, 90, 1000);

-- Shitake (Lentinula edodes) — idCogumelo = 3
INSERT INTO fase_cultivo (nomeFaseCultivo, idCogumelo, descricaoFaseCultivo, temperaturaMin, temperaturaMax, umidadeMin, umidadeMax, co2Max)
VALUES
('Colonização', 3, 'Crescimento do micélio nas toras ou substrato até colonização total', 20, 25, 70, 80, 1500),
('Indução',     3, 'Choque térmico ou imersão das toras e aumento de aeração + luminosidade para induzir primórdios', 10, 18, 80, 90, 1200),
('Frutificação',3, 'Crescimento dos corpos frutíferos após indução, com ventilação adequada', 14, 18, 85, 95, 1000);


-- ================================
-- TABELA: atuador
-- ================================

