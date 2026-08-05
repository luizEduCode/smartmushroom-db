-- SmartMushroom
-- Migration: criação da estrutura inicial
-- Banco de dados: MySQL 8.4 LTS

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE sala (
    id_sala INT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_sala PRIMARY KEY (id_sala),
    CONSTRAINT uq_sala_codigo UNIQUE (codigo)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE cogumelo (
    id_cogumelo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    nome_cientifico VARCHAR(150) NULL,
    linhagem VARCHAR(100) NULL,
    descricao VARCHAR(255) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_cogumelo PRIMARY KEY (id_cogumelo)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE fase_cultivo (
    id_fase_cultivo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_cogumelo INT UNSIGNED NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    ordem TINYINT UNSIGNED NOT NULL,
    temperatura_ambiente_min DECIMAL(5,2) NOT NULL,
    temperatura_ambiente_max DECIMAL(5,2) NOT NULL,
    temperatura_composto_min DECIMAL(5,2) NULL,
    temperatura_composto_max DECIMAL(5,2) NULL,
    umidade_ambiente_min DECIMAL(5,2) NOT NULL,
    umidade_ambiente_max DECIMAL(5,2) NOT NULL,
    co2_max DECIMAL(7,2) NOT NULL,
    fotoperiodo_minutos SMALLINT UNSIGNED NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_fase_cultivo
        PRIMARY KEY (id_fase_cultivo),

    CONSTRAINT uq_fase_cultivo_cogumelo_nome
        UNIQUE (id_cogumelo, nome),

    CONSTRAINT uq_fase_cultivo_cogumelo_ordem
        UNIQUE (id_cogumelo, ordem),

    CONSTRAINT fk_fase_cultivo_cogumelo
        FOREIGN KEY (id_cogumelo)
        REFERENCES cogumelo (id_cogumelo)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_fase_cultivo_temperatura_ambiente
        CHECK (temperatura_ambiente_min <= temperatura_ambiente_max),

    CONSTRAINT ck_fase_cultivo_temperatura_composto_preenchimento
        CHECK (
            (temperatura_composto_min IS NULL
                AND temperatura_composto_max IS NULL)
            OR
            (temperatura_composto_min IS NOT NULL
                AND temperatura_composto_max IS NOT NULL)
        ),

    CONSTRAINT ck_fase_cultivo_temperatura_composto
        CHECK (
            temperatura_composto_min IS NULL
            OR temperatura_composto_min <= temperatura_composto_max
        ),

    CONSTRAINT ck_fase_cultivo_umidade_ambiente
        CHECK (
            umidade_ambiente_min BETWEEN 0 AND 100
            AND umidade_ambiente_max BETWEEN 0 AND 100
            AND umidade_ambiente_min <= umidade_ambiente_max
        ),

    CONSTRAINT ck_fase_cultivo_co2
        CHECK (co2_max > 0),

    CONSTRAINT ck_fase_cultivo_fotoperiodo
        CHECK (fotoperiodo_minutos <= 1440)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE usuario (
    id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('administrador', 'operador') NOT NULL
        DEFAULT 'operador',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_usuario
        PRIMARY KEY (id_usuario),

    CONSTRAINT uq_usuario_email
        UNIQUE (email)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE lote (
    id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL,
    id_sala INT UNSIGNED NOT NULL,
    id_cogumelo INT UNSIGNED NOT NULL,
    id_usuario_responsavel INT UNSIGNED NULL,
    status ENUM('ativo', 'finalizado') NOT NULL DEFAULT 'ativo',
    iniciado_em DATETIME(3) NOT NULL,
    finalizado_em DATETIME(3) NULL,
    quantidade_unidades INT UNSIGNED NULL,
    tipo_unidade VARCHAR(30) NULL,
    peso_unitario_kg DECIMAL(8,3) NULL,
    fornecedor_semente VARCHAR(150) NULL,
    observacoes TEXT NULL,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_lote
        PRIMARY KEY (id_lote),

    CONSTRAINT uq_lote_codigo
        UNIQUE (codigo),

    UNIQUE INDEX uq_lote_sala_ativa (
        (CASE
            WHEN status = 'ativo' THEN id_sala
            ELSE NULL
        END)
    ),

    INDEX ix_lote_sala (id_sala),
    INDEX ix_lote_cogumelo (id_cogumelo),
    INDEX ix_lote_usuario_responsavel (id_usuario_responsavel),

    CONSTRAINT fk_lote_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala (id_sala)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_lote_cogumelo
        FOREIGN KEY (id_cogumelo)
        REFERENCES cogumelo (id_cogumelo)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_lote_usuario_responsavel
        FOREIGN KEY (id_usuario_responsavel)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_lote_status_finalizacao
        CHECK (
            (status = 'ativo' AND finalizado_em IS NULL)
            OR
            (status = 'finalizado' AND finalizado_em IS NOT NULL)
        ),

    CONSTRAINT ck_lote_periodo
        CHECK (
            finalizado_em IS NULL
            OR finalizado_em >= iniciado_em
        ),

    CONSTRAINT ck_lote_quantidade_unidades
        CHECK (
            quantidade_unidades IS NULL
            OR quantidade_unidades > 0
        ),

    CONSTRAINT ck_lote_peso_unitario
        CHECK (
            peso_unitario_kg IS NULL
            OR peso_unitario_kg > 0
        )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE historico_fase (
    id_historico_fase INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_lote INT UNSIGNED NOT NULL,
    id_fase_cultivo INT UNSIGNED NOT NULL,
    id_usuario INT UNSIGNED NULL,
    iniciado_em DATETIME(3) NOT NULL,
    observacoes VARCHAR(255) NULL,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_historico_fase
        PRIMARY KEY (id_historico_fase),

    INDEX ix_historico_fase_lote_atual (
        id_lote,
        iniciado_em,
        id_historico_fase
    ),

    INDEX ix_historico_fase_fase_cultivo (id_fase_cultivo),
    INDEX ix_historico_fase_usuario (id_usuario),

    CONSTRAINT fk_historico_fase_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote (id_lote)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_historico_fase_fase_cultivo
        FOREIGN KEY (id_fase_cultivo)
        REFERENCES fase_cultivo (id_fase_cultivo)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_historico_fase_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE configuracao (
    id_configuracao INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_historico_fase INT UNSIGNED NOT NULL,
    id_usuario INT UNSIGNED NULL,
    origem ENUM(
        'padrao_fase',
        'ajuste_usuario',
        'migracao'
    ) NOT NULL,
    temperatura_ambiente_min DECIMAL(5,2) NOT NULL,
    temperatura_ambiente_max DECIMAL(5,2) NOT NULL,
    temperatura_composto_min DECIMAL(5,2) NULL,
    temperatura_composto_max DECIMAL(5,2) NULL,
    umidade_ambiente_min DECIMAL(5,2) NOT NULL,
    umidade_ambiente_max DECIMAL(5,2) NOT NULL,
    co2_max DECIMAL(7,2) NOT NULL,
    fotoperiodo_minutos SMALLINT UNSIGNED NOT NULL,
    observacoes VARCHAR(255) NULL,
    aplicado_em DATETIME(3) NOT NULL,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_configuracao
        PRIMARY KEY (id_configuracao),

    INDEX ix_configuracao_historico_vigente (
        id_historico_fase,
        aplicado_em,
        id_configuracao
    ),

    INDEX ix_configuracao_usuario (id_usuario),

    CONSTRAINT fk_configuracao_historico_fase
        FOREIGN KEY (id_historico_fase)
        REFERENCES historico_fase (id_historico_fase)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_configuracao_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_configuracao_usuario_origem
        CHECK (
            origem <> 'ajuste_usuario'
            OR id_usuario IS NOT NULL
        ),

    CONSTRAINT ck_configuracao_temperatura_ambiente
        CHECK (
            temperatura_ambiente_min
                <= temperatura_ambiente_max
        ),

    CONSTRAINT ck_configuracao_temperatura_composto_preenchimento
        CHECK (
            (temperatura_composto_min IS NULL
                AND temperatura_composto_max IS NULL)
            OR
            (temperatura_composto_min IS NOT NULL
                AND temperatura_composto_max IS NOT NULL)
        ),

    CONSTRAINT ck_configuracao_temperatura_composto
        CHECK (
            temperatura_composto_min IS NULL
            OR temperatura_composto_min
                <= temperatura_composto_max
        ),

    CONSTRAINT ck_configuracao_umidade_ambiente
        CHECK (
            umidade_ambiente_min BETWEEN 0 AND 100
            AND umidade_ambiente_max BETWEEN 0 AND 100
            AND umidade_ambiente_min <= umidade_ambiente_max
        ),

    CONSTRAINT ck_configuracao_co2
        CHECK (co2_max > 0),

    CONSTRAINT ck_configuracao_fotoperiodo
        CHECK (fotoperiodo_minutos <= 1440)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE sensor (
    id_sensor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_sala INT UNSIGNED NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    grandeza ENUM(
        'temperatura',
        'umidade',
        'co2'
    ) NOT NULL,
    localizacao ENUM(
        'ambiente',
        'composto',
        'externo'
    ) NOT NULL,
    descricao VARCHAR(255) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    instalado_em DATETIME(3) NOT NULL,
    desativado_em DATETIME(3) NULL,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_sensor
        PRIMARY KEY (id_sensor),

    CONSTRAINT uq_sensor_sala_codigo
        UNIQUE (id_sala, codigo),


    CONSTRAINT fk_sensor_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala (id_sala)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_sensor_localizacao_composto
        CHECK (
            localizacao <> 'composto'
            OR grandeza = 'temperatura'
        ),

    CONSTRAINT ck_sensor_grandeza_co2
        CHECK (
            grandeza <> 'co2'
            OR localizacao = 'ambiente'
        ),

    CONSTRAINT ck_sensor_ativo_desativado
        CHECK (
            (ativo = TRUE AND desativado_em IS NULL)
            OR
            (ativo = FALSE AND desativado_em IS NOT NULL)
        ),

    CONSTRAINT ck_sensor_periodo_atividade
        CHECK (
            desativado_em IS NULL
            OR desativado_em >= instalado_em
        )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE coleta (
    id_coleta BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_lote INT UNSIGNED NOT NULL,
    identificador_externo CHAR(36) NOT NULL,
    origem ENUM(
        'esp32',
        'manual',
        'migracao'
    ) NOT NULL,
    medido_em DATETIME(3) NOT NULL,
    recebido_em DATETIME(3) NOT NULL,

    CONSTRAINT pk_coleta
        PRIMARY KEY (id_coleta),

    CONSTRAINT uq_coleta_identificador_externo
        UNIQUE (identificador_externo),

    INDEX ix_coleta_lote_medicao (
        id_lote,
        medido_em,
        id_coleta
    ),

    CONSTRAINT fk_coleta_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote (id_lote)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE leitura (
    id_leitura BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_coleta BIGINT UNSIGNED NOT NULL,
    id_sensor INT UNSIGNED NOT NULL,
    valor DECIMAL(10,3) NOT NULL,

    CONSTRAINT pk_leitura
        PRIMARY KEY (id_leitura),

    CONSTRAINT uq_leitura_coleta_sensor
        UNIQUE (id_coleta, id_sensor),

    INDEX ix_leitura_sensor (id_sensor),

    CONSTRAINT fk_leitura_coleta
        FOREIGN KEY (id_coleta)
        REFERENCES coleta (id_coleta)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_leitura_sensor
        FOREIGN KEY (id_sensor)
        REFERENCES sensor (id_sensor)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE atuador (
    id_atuador INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_sala INT UNSIGNED NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM(
        'umidificador',
        'exaustor',
        'ventilador',
        'aquecedor',
        'refrigeracao',
        'iluminacao',
        'outro'
    ) NOT NULL,
    estado_seguro ENUM(
        'ligado',
        'desligado'
    ) NOT NULL DEFAULT 'desligado',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    instalado_em DATETIME(3) NOT NULL,
    desativado_em DATETIME(3) NULL,
    criado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_atuador
        PRIMARY KEY (id_atuador),

    CONSTRAINT uq_atuador_sala_codigo
        UNIQUE (id_sala, codigo),


    CONSTRAINT fk_atuador_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala (id_sala)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_atuador_ativo_desativado
        CHECK (
            (ativo = TRUE AND desativado_em IS NULL)
            OR
            (ativo = FALSE AND desativado_em IS NOT NULL)
        ),

    CONSTRAINT ck_atuador_periodo_atividade
        CHECK (
            desativado_em IS NULL
            OR desativado_em >= instalado_em
        )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE controle_atuador (
    id_controle_atuador BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_atuador INT UNSIGNED NOT NULL,
    id_lote INT UNSIGNED NULL,
    id_usuario INT UNSIGNED NULL,
    identificador_externo CHAR(36) NOT NULL,
    estado ENUM(
        'ligado',
        'desligado'
    ) NOT NULL,
    origem ENUM(
        'manual',
        'automacao_online',
        'automacao_local',
        'migracao'
    ) NOT NULL,
    status_execucao ENUM(
        'pendente',
        'aplicado',
        'falhou'
    ) NOT NULL DEFAULT 'pendente',
    motivo VARCHAR(255) NULL,
    ocorrido_em DATETIME(3) NOT NULL,
    aplicado_em DATETIME(3) NULL,
    registrado_em DATETIME(3) NOT NULL,

    CONSTRAINT pk_controle_atuador
        PRIMARY KEY (id_controle_atuador),

    CONSTRAINT uq_controle_atuador_identificador_externo
        UNIQUE (identificador_externo),

    INDEX ix_controle_atuador_estado_efetivo (
        id_atuador,
        status_execucao,
        aplicado_em,
        id_controle_atuador
    ),

    INDEX ix_controle_atuador_lote (id_lote),
    INDEX ix_controle_atuador_usuario (id_usuario),

    CONSTRAINT fk_controle_atuador_atuador
        FOREIGN KEY (id_atuador)
        REFERENCES atuador (id_atuador)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_controle_atuador_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote (id_lote)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_controle_atuador_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_controle_atuador_usuario_origem
        CHECK (
            (origem = 'manual' AND id_usuario IS NOT NULL)
            OR
            (
                origem IN (
                    'automacao_online',
                    'automacao_local'
                )
                AND id_usuario IS NULL
            )
            OR origem = 'migracao'
        ),

    CONSTRAINT ck_controle_atuador_status_aplicacao
        CHECK (
            (
                status_execucao = 'aplicado'
                AND aplicado_em IS NOT NULL
            )
            OR
            (
                status_execucao IN ('pendente', 'falhou')
                AND aplicado_em IS NULL
            )
        )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE alerta (
    id_alerta INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_lote INT UNSIGNED NOT NULL,
    id_leitura BIGINT UNSIGNED NULL,
    id_sensor INT UNSIGNED NULL,
    id_atuador INT UNSIGNED NULL,
    tipo ENUM(
        'temperatura_baixa',
        'temperatura_alta',
        'umidade_baixa',
        'umidade_alta',
        'co2_alto',
        'falha_sensor',
        'falha_atuador',
        'comunicacao',
        'outro'
    ) NOT NULL,
    severidade ENUM(
        'aviso',
        'critico'
    ) NOT NULL,
    status ENUM(
        'aberto',
        'reconhecido',
        'resolvido'
    ) NOT NULL DEFAULT 'aberto',
    valor_observado DECIMAL(10,3) NULL,
    limite_referencia DECIMAL(10,3) NULL,
    mensagem VARCHAR(255) NOT NULL,
    aberto_em DATETIME(3) NOT NULL,
    reconhecido_em DATETIME(3) NULL,
    id_usuario_reconhecimento INT UNSIGNED NULL,
    resolvido_em DATETIME(3) NULL,
    id_usuario_resolucao INT UNSIGNED NULL,
    atualizado_em DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),

    CONSTRAINT pk_alerta
        PRIMARY KEY (id_alerta),

    UNIQUE INDEX uq_alerta_condicao_ativa (
        (CASE
            WHEN status IN ('aberto', 'reconhecido')
                THEN id_lote
            ELSE NULL
        END),
        (CASE
            WHEN status IN ('aberto', 'reconhecido')
                THEN tipo
            ELSE NULL
        END),
        (CASE
            WHEN status IN ('aberto', 'reconhecido')
                THEN COALESCE(id_sensor, 0)
            ELSE NULL
        END),
        (CASE
            WHEN status IN ('aberto', 'reconhecido')
                THEN COALESCE(id_atuador, 0)
            ELSE NULL
        END)
    ),

    INDEX ix_alerta_lote_status (
        id_lote,
        status,
        aberto_em
    ),

    INDEX ix_alerta_leitura (id_leitura),
    INDEX ix_alerta_sensor (id_sensor),
    INDEX ix_alerta_atuador (id_atuador),
    INDEX ix_alerta_usuario_reconhecimento (
        id_usuario_reconhecimento
    ),
    INDEX ix_alerta_usuario_resolucao (
        id_usuario_resolucao
    ),

    CONSTRAINT fk_alerta_lote
        FOREIGN KEY (id_lote)
        REFERENCES lote (id_lote)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_alerta_leitura
        FOREIGN KEY (id_leitura)
        REFERENCES leitura (id_leitura)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_alerta_sensor
        FOREIGN KEY (id_sensor)
        REFERENCES sensor (id_sensor)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_alerta_atuador
        FOREIGN KEY (id_atuador)
        REFERENCES atuador (id_atuador)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_alerta_usuario_reconhecimento
        FOREIGN KEY (id_usuario_reconhecimento)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_alerta_usuario_resolucao
        FOREIGN KEY (id_usuario_resolucao)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_alerta_reconhecimento
        CHECK (
            (
                reconhecido_em IS NULL
                AND id_usuario_reconhecimento IS NULL
            )
            OR
            (
                reconhecido_em IS NOT NULL
                AND id_usuario_reconhecimento IS NOT NULL
            )
        ),

    CONSTRAINT ck_alerta_status_reconhecido
        CHECK (
            status <> 'reconhecido'
            OR reconhecido_em IS NOT NULL
        ),

    CONSTRAINT ck_alerta_resolucao
        CHECK (
            (
                status = 'resolvido'
                AND resolvido_em IS NOT NULL
            )
            OR
            (
                status IN ('aberto', 'reconhecido')
                AND resolvido_em IS NULL
                AND id_usuario_resolucao IS NULL
            )
        )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE auditoria (
    id_auditoria BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario INT UNSIGNED NULL,
    origem ENUM(
        'usuario',
        'sistema',
        'migracao'
    ) NOT NULL,
    acao VARCHAR(100) NOT NULL,
    entidade VARCHAR(50) NOT NULL,
    id_entidade BIGINT UNSIGNED NULL,
    dados_anteriores JSON NULL,
    dados_novos JSON NULL,
    endereco_ip VARCHAR(45) NULL,
    ocorrido_em DATETIME(3) NOT NULL,

    CONSTRAINT pk_auditoria
        PRIMARY KEY (id_auditoria),

    INDEX ix_auditoria_usuario (id_usuario),

    INDEX ix_auditoria_entidade (
        entidade,
        id_entidade,
        ocorrido_em
    ),

    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT ck_auditoria_usuario_origem
        CHECK (
             origem <> 'usuario'
             OR id_usuario IS NOT NULL
         )
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;