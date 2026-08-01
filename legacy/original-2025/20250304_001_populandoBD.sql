-- Inserindo dados na tabela sala
INSERT INTO sala (nomeSala, descricaoSala) VALUES
('Sala 1', 'Estufa principal para cultivo de cogumelos Shimeji'),
('Sala 2', 'Estufa secundária para testes com cogumelos variados');

-- Inserindo dados na tabela cogumelo
INSERT INTO cogumelo (nomeCogumelo, descricao) VALUES
('Shimeji', 'Pleurotus ostreatus - cogumelo comestível popular no Brasil'),
('Champignon', 'Agaricus bisporus - cogumelo amplamente cultivado'),
('Shiitake', 'Lentinula edodes - conhecido pelo sabor e propriedades nutricionais');

-- Inserindo dados na tabela fase_cultivo
INSERT INTO fase_cultivo (nomeFaseCultivo, idCogumelo, descricaoFaseCultivo, temperaturaMin, temperaturaMax, umidadeMin, umidadeMax, co2Max) VALUES
('Colonização', 1, 'Fase inicial de crescimento do micélio', 20.00, 25.00, 65.00, 70.00, 5000.00),
('Frutificação', 1, 'Fase de desenvolvimento do cogumelo', 18.00, 22.00, 85.00, 90.00, 600.00),
('Colonização', 2, 'Fase inicial de crescimento do Champignon', 22.00, 25.00, 65.00, 70.00, 5000.00),
('Frutificação', 2, 'Fase de desenvolvimento do Champignon', 16.00, 20.00, 85.00, 90.00, 600.00);

-- Inserindo dados na tabela lote
INSERT INTO lote (idSala, idCogumelo, dataInicio, status) VALUES
(1, 1, '2025-02-01', 'ativo'),
(2, 2, '2025-02-15', 'ativo');

-- Inserindo dados na tabela historico_fase
INSERT INTO historico_fase (idLote, idFaseCultivo, dataMudanca) VALUES
(1, 1, NOW()),
(2, 3, NOW());

-- Inserindo dados na tabela leitura
INSERT INTO leitura (idLote, umidade, temperatura, co2, luz) VALUES
(1, 80.00, 21.50, 550.00, 'ligado'),
(2, 88.00, 18.00, 400.00, 'desligado');

-- Inserindo dados na tabela usuario
INSERT INTO usuario (nomeUsuario, email, senha, tipo) VALUES
('Admin', 'admin@smartmushroom.com', '123456', 'admin'),
('Usuário Teste', 'usuario@smartmushroom.com', '123456', 'usuario');

-- Inserindo dados na tabela configuracao
INSERT INTO configuracao (idLote, idUsuario, umidadeMin, umidadeMax, temperaturaMin, temperaturaMax, co2Max, luz) VALUES
(1, 1, 75.00, 90.00, 19.00, 23.00, 600.00, 'ligado'),
(2, 2, 80.00, 95.00, 17.00, 21.00, 500.00, 'desligado');

-- Inserindo dados na tabela alerta
INSERT INTO alerta (idLote, tipo, valor) VALUES
(1, 'Temperatura alta', 24.00),
(2, 'CO2 abaixo do ideal', 350.00);

-- Inserindo dados na tabela atuador
INSERT INTO atuador (idSala, nomeAtuador, tipoAtuador) VALUES
(1, 'Umidificador', 'umidade'),
(1, 'Exaustor', 'co2'),
(2, 'Aquecedor', 'temperatura');

-- Inserindo dados na tabela controle_atuador
INSERT INTO controle_atuador (idAtuador, idUsuario, idLote, statusAtuador) VALUES
(1, 1, 1, 'ativo'),
(2, 2, 2, 'ativo');

-- Inserindo dados na tabela log_sistema
INSERT INTO log_sistema (idUsuario, acao, detalhes) VALUES
(1, 'Inserção de novo lote', 'Lote 1 criado para cultivo de Shimeji'),
(2, 'Mudança de configuração', 'Usuário alterou os parâmetros ambientais da Sala 2');
