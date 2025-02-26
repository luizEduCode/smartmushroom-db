USE smartmushroom_db;

CREATE TABLE leitura (
    idLeitura INT AUTO_INCREMENT PRIMARY KEY,
    idSala INT NOT NULL,
    umidade DECIMAL(5,2) NOT NULL,      -- Umidade relativa em %
    temperatura DECIMAL(5,2) NOT NULL,  -- Temperatura em °C
    co2 DECIMAL(10,2) NOT NULL,         -- Nível de CO₂ em ppm
    iluminacao DECIMAL(10,2) NOT NULL,  -- Nível de iluminação em lux
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);
