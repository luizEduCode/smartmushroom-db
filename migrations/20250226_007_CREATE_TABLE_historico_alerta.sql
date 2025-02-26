USE smartmushroom_db;

CREATE TABLE historico_alerta (
    idAlerta INT AUTO_INCREMENT PRIMARY KEY,
    idSala INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,  -- Exemplo: 'Temperatura Alta', 'CO2 Excedido'
    valor DECIMAL(10,2) NOT NULL,
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idSala) REFERENCES sala(idSala) ON DELETE CASCADE
);

