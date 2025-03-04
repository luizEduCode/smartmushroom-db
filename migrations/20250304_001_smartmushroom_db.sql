-- Criando o banco de dados
CREATE DATABASE smartmushroom_db;
USE smartmushroom_db;

-- Tabela de Salas de Cultivo
CREATE TABLE sala (
    idSala INT AUTO_INCREMENT PRIMARY KEY,
    nomeSala VARCHAR(100) NOT NULL,
    descricaoSala VARCHAR(200),
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Tipos de Cogumelo Cultivados
CREATE TABLE cogumelo (
    idCogumelo INT AUTO_INCREMENT PRIMARY KEY,
    nomeCogumelo VARCHAR(100) NOT NULL,
    descricao VARCHAR(200)
);

-- Tabela de Fase de Cultivo e seus Parâmetros 
CREATE TABLE fase_cultivo (
    idFaseCultivo INT AUTO_INCREMENT PRIMARY KEY,
    nomeFaseCultivo VARCHAR(100) NOT NULL,
    idCogumelo INT NOT NULL,
    descricaoFaseCultivo VARCHAR(200),
    temperaturaMin DECIMAL(5,2) NOT NULL,
    temperaturaMax DECIMAL(5,2) NOT NULL,
    umidadeMin DECIMAL(5,2) NOT NULL,
    umidadeMax DECIMAL(5,2) NOT NULL,
    co2Max DECIMAL(7,2) NOT NULL
);

-- Tabela de Lotes de Cogumelos
CREATE TABLE lote (
    idLote INT AUTO_INCREMENT PRIMARY KEY,
    idSala INT NOT NULL,
    idCogumelo INT NOT NULL,
    dataInicio DATE NOT NULL,
    dataFim DATE NULL,
    status ENUM('ativo', 'finalizado') NOT NULL DEFAULT 'ativo'
);

-- Tabela de Histórico de Mudança de Fase nos Lotes
CREATE TABLE historico_fase (
    idHistorico INT AUTO_INCREMENT PRIMARY KEY,
    idLote INT NOT NULL,
    idFaseCultivo INT NOT NULL,
    dataMudanca TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Leituras Ambientais por Lote
CREATE TABLE leitura (
    idLeitura INT AUTO_INCREMENT PRIMARY KEY,
    idLote INT NOT NULL,
    umidade DECIMAL(5,2) NOT NULL,
    temperatura DECIMAL(5,2) NOT NULL,
    co2 DECIMAL(7,2) NOT NULL,
    luz ENUM('ligado', 'desligado') NOT NULL DEFAULT 'ligado',
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Usuários
CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nomeUsuario VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo ENUM('admin', 'usuario') NOT NULL DEFAULT 'usuario',
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Histórico de Configurações de Parâmetros para Salas
CREATE TABLE configuracao (
    idConfig INT AUTO_INCREMENT PRIMARY KEY,
    idLote INT NOT NULL,
    idUsuario INT NOT NULL,
    umidadeMin DECIMAL(5,2) NOT NULL,
    umidadeMax DECIMAL(5,2) NOT NULL,
    temperaturaMin DECIMAL(5,2) NOT NULL,
    temperaturaMax DECIMAL(5,2) NOT NULL,
    co2Max DECIMAL(7,2) NOT NULL,
    luz ENUM('ligado', 'desligado') NOT NULL DEFAULT 'ligado',
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Histórico de Alertas
CREATE TABLE alerta (
    idAlerta INT AUTO_INCREMENT PRIMARY KEY,
    idLote INT NOT NULL,
    idAtuador INT NULL,
    tipo VARCHAR(50) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Atuadores (umidificador, exaustor, ar-condicionado, etc.)
CREATE TABLE atuador (
    idAtuador INT AUTO_INCREMENT PRIMARY KEY,
    idSala INT NOT NULL,
    nomeAtuador VARCHAR(100) NOT NULL,
    tipoAtuador ENUM('umidade', 'temperatura', 'co2', 'luz') NOT NULL,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Controle de Acionamento dos Atuadores
CREATE TABLE controle_atuador (
    idControle INT AUTO_INCREMENT PRIMARY KEY,
    idAtuador INT NOT NULL,
    idUsuario INT NOT NULL,
    idLote INT NOT NULL,
    statusAtuador ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Log de Sistema para auditoria
CREATE TABLE log_sistema (
    idLog INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NULL,
    acao VARCHAR(255) NOT NULL,
    detalhes VARCHAR(255) ,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Adicionar os relacionamentos (Foreign Keys)
ALTER TABLE fase_cultivo 
ADD CONSTRAINT fk_fase_cultivo_cogumelo FOREIGN KEY (idCogumelo) REFERENCES cogumelo(idCogumelo) ON DELETE CASCADE;

ALTER TABLE lote 
ADD CONSTRAINT fk_lote_sala FOREIGN KEY (idSala) REFERENCES sala(idSala) ON DELETE CASCADE,
ADD CONSTRAINT fk_lote_cogumelo FOREIGN KEY (idCogumelo) REFERENCES cogumelo(idCogumelo) ON DELETE CASCADE;

ALTER TABLE historico_fase 
ADD CONSTRAINT fk_historico_fase_lote FOREIGN KEY (idLote) REFERENCES lote(idLote) ON DELETE CASCADE,
ADD CONSTRAINT fk_historico_fase_cultivo FOREIGN KEY (idFaseCultivo) REFERENCES fase_cultivo(idFaseCultivo) ON DELETE CASCADE;

ALTER TABLE leitura 
ADD CONSTRAINT fk_leitura_lote FOREIGN KEY (idLote) REFERENCES lote(idLote) ON DELETE CASCADE;

ALTER TABLE configuracao 
ADD CONSTRAINT fk_configuracao_lote FOREIGN KEY (idLote) REFERENCES lote(idLote) ON DELETE CASCADE,
ADD CONSTRAINT fk_configuracao_usuario FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE;

ALTER TABLE alerta 
ADD CONSTRAINT fk_alerta_lote FOREIGN KEY (idLote) REFERENCES lote(idLote) ON DELETE CASCADE,
ADD CONSTRAINT fk_alerta_atuador FOREIGN KEY (idAtuador) REFERENCES atuador(idAtuador) ON DELETE SET NULL;

ALTER TABLE atuador 
ADD CONSTRAINT fk_atuador_sala FOREIGN KEY (idSala) REFERENCES sala(idSala) ON DELETE CASCADE;

ALTER TABLE controle_atuador 
ADD CONSTRAINT fk_controle_atuador FOREIGN KEY (idAtuador) REFERENCES atuador(idAtuador) ON DELETE CASCADE,
ADD CONSTRAINT fk_controle_usuario FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
ADD CONSTRAINT fk_controle_lote FOREIGN KEY (idLote) REFERENCES lote(idLote) ON DELETE CASCADE;

ALTER TABLE log_sistema 
ADD CONSTRAINT fk_log_usuario FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario) ON DELETE SET NULL;