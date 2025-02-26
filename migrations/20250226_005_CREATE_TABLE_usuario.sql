USE smartmushroom_db;

CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,  -- Armazenar a senha hash (exemplo: bcrypt)
    tipo ENUM('admin', 'usuario') NOT NULL DEFAULT 'usuario',
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
