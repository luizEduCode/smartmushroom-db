USE smartmushroom_db;

CREATE TABLE sala (
    idSala INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
