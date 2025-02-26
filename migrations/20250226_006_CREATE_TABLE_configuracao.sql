USE smartmushroom_db;

CREATE TABLE configuracao (
    idConfig INT AUTO_INCREMENT PRIMARY KEY,
    idSala INT NOT NULL,
    umidadeMin DECIMAL(5,2) NOT NULL,
    umidadeMax DECIMAL(5,2) NOT NULL,
    temperaturaMin DECIMAL(5,2) NOT NULL,
    temperaturaMax DECIMAL(5,2) NOT NULL,
    co2Max DECIMAL(10,2) NOT NULL,
    iluminacaoMin DECIMAL(10,2) NOT NULL,
    iluminacaoMax DECIMAL(10,2) NOT NULL,
    
);
