USE smartmushroom_db;

CREATE TABLE tipo_cogumelo (
    idCogumelo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    temperaturaMin DECIMAL(5,2) NOT NULL,
    temperaturaMax DECIMAL(5,2) NOT NULL,
    umidadeMin DECIMAL(5,2) NOT NULL,
    umidadeMax DECIMAL(5,2) NOT NULL,
    co2Max DECIMAL(10,2) NOT NULL,
    iluminacaoMin DECIMAL(10,2) NOT NULL,
    iluminacaoMax DECIMAL(10,2) NOT NULL
);
