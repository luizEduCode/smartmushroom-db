# Modelo lógico do banco de dados

Este documento descreve as entidades, atributos e relacionamentos do banco de dados do SmartMushroom.

O modelo considera uma única propriedade rural e utiliza nomenclatura em português no padrão `snake_case`.

## Sala

Representa um ambiente físico utilizado para cultivo e monitoramento.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_sala` | `INT UNSIGNED` | Sim | Chave primária interna |
| `codigo` | `VARCHAR(50)` | Sim | Identificador estável e único |
| `nome` | `VARCHAR(100)` | Sim | Nome exibido ao usuário |
| `descricao` | `VARCHAR(255)` | Não | Informações adicionais |
| `ativa` | `BOOLEAN` | Sim | Indica se a sala pode ser utilizada |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Restrições

- `id_sala` é a chave primária.
- `codigo` deve ser único.
- Uma sala com histórico não deve ser excluída durante o uso normal.
- Uma sala desativada não pode receber novos lotes.
- A desativação não remove lotes, sensores, atuadores ou históricos existentes.

### Relacionamentos previstos

Uma sala pode possuir:

- vários lotes ao longo do tempo;
- vários sensores;
- vários atuadores;
- dispositivos de controle e monitoramento.

## Cogumelo

Representa o tipo de cogumelo cultivado, podendo registrar opcionalmente sua espécie e linhagem.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_cogumelo` | `INT UNSIGNED` | Sim | Chave primária interna |
| `nome` | `VARCHAR(100)` | Sim | Nome comum ou comercial |
| `nome_cientifico` | `VARCHAR(150)` | Não | Identificação científica da espécie |
| `linhagem` | `VARCHAR(100)` | Não | Linhagem ou variedade utilizada |
| `descricao` | `VARCHAR(255)` | Não | Informações adicionais |
| `ativo` | `BOOLEAN` | Sim | Indica se pode ser selecionado em novos lotes |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Restrições

- `id_cogumelo` é a chave primária.
- `nome` é obrigatório.
- `nome_cientifico` e `linhagem` são opcionais.
- Um cogumelo utilizado em lotes não deve ser excluído durante o uso normal.
- Um cogumelo desativado permanece no histórico, mas não pode ser selecionado em novos lotes.

### Exemplo

```text
nome: Shimeji Branco
nome_cientifico: Pleurotus ostreatus
linhagem: P-49
```

### Relacionamentos previstos

Um cogumelo pode possuir:

- várias fases de cultivo;
- vários lotes ao longo do tempo.

## Fase de cultivo

Representa uma etapa do cultivo e seus parâmetros ambientais padrão para determinado cogumelo.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_fase_cultivo` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_cogumelo` | `INT UNSIGNED` | Sim | Cogumelo ao qual a fase pertence |
| `nome` | `VARCHAR(100)` | Sim | Nome da fase |
| `descricao` | `VARCHAR(255)` | Não | Informações adicionais |
| `ordem` | `TINYINT UNSIGNED` | Sim | Posição da fase no processo de cultivo |
| `temperatura_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da temperatura ambiente |
| `temperatura_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da temperatura ambiente |
| `temperatura_composto_min` | `DECIMAL(5,2)` | Não | Limite mínimo da temperatura do composto |
| `temperatura_composto_max` | `DECIMAL(5,2)` | Não | Limite máximo da temperatura do composto |
| `umidade_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da umidade relativa |
| `umidade_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da umidade relativa |
| `co2_max` | `DECIMAL(7,2)` | Sim | Limite máximo de CO₂ em ppm |
| `fotoperiodo_minutos` | `SMALLINT UNSIGNED` | Sim | Duração diária da iluminação automática |
| `ativa` | `BOOLEAN` | Sim | Indica se pode ser selecionada |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Restrições

- `id_fase_cultivo` é a chave primária.
- `id_cogumelo` referencia `cogumelo`.
- O nome da fase deve ser único dentro do mesmo cogumelo.
- A ordem deve ser única dentro do mesmo cogumelo.
- Valores mínimos não podem ser maiores que os respectivos valores máximos.
- A umidade relativa deve permanecer entre 0 e 100.
- `co2_max` deve ser maior que zero.
- `fotoperiodo_minutos` deve permanecer entre 0 e 1440.
- As duas temperaturas do composto devem ser preenchidas juntas ou permanecer ambas vazias.
- Uma fase utilizada em históricos não deve ser excluída durante o uso normal.
- Uma fase desativada não pode ser selecionada em novos lotes ou novas mudanças de fase.

### Relacionamentos

- Um cogumelo pode possuir várias fases de cultivo.
- Uma fase pode aparecer em vários históricos de lotes.
- Ao ser aplicada a um lote, seus parâmetros originam uma nova configuração histórica.

## Lote

Representa um ciclo de cultivo realizado em uma sala.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_lote` | `INT UNSIGNED` | Sim | Chave primária interna |
| `codigo` | `VARCHAR(50)` | Sim | Identificação única do lote |
| `id_sala` | `INT UNSIGNED` | Sim | Sala utilizada pelo lote |
| `id_cogumelo` | `INT UNSIGNED` | Sim | Cogumelo cultivado |
| `id_usuario_responsavel` | `INT UNSIGNED` | Não | Usuário responsável pelo lote |
| `status` | Domínio controlado | Sim | Estado atual do lote |
| `iniciado_em` | `DATETIME(3)` | Sim | Instante de início em UTC |
| `finalizado_em` | `DATETIME(3)` | Não | Instante de finalização em UTC |
| `quantidade_unidades` | `INT UNSIGNED` | Não | Quantidade de unidades produtivas |
| `tipo_unidade` | `VARCHAR(30)` | Não | Tipo da unidade, como saco ou bandeja |
| `peso_unitario_kg` | `DECIMAL(8,3)` | Não | Peso médio de cada unidade |
| `fornecedor_semente` | `VARCHAR(150)` | Não | Fornecedor da semente utilizada |
| `observacoes` | `TEXT` | Não | Informações produtivas adicionais |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Estados

O estado inicial utiliza os valores:

- `ativo`;
- `finalizado`.

Novos estados somente devem ser adicionados quando houver uma regra de negócio definida.

### Restrições

- `id_lote` é a chave primária.
- `codigo` deve ser único.
- `id_sala` referencia `sala`.
- `id_cogumelo` referencia `cogumelo`.
- `id_usuario_responsavel` referencia `usuario` quando preenchido.
- Uma sala pode possuir no máximo um lote ativo.
- Um lote ativo deve possuir `finalizado_em` vazio.
- Um lote finalizado deve possuir `finalizado_em` preenchido.
- A reabertura deve limpar `finalizado_em`.
- Quantidade e peso, quando informados, devem ser maiores que zero.
- Uma sala desativada não pode receber um novo lote.
- Um cogumelo desativado não pode ser selecionado em um novo lote.
- Lotes não devem ser excluídos durante o uso normal.

### Relacionamentos

Um lote pertence a:

- uma sala;
- um cogumelo;
- opcionalmente um usuário responsável.

Um lote pode possuir:

- várias mudanças de fase;
- várias configurações;
- várias coletas;
- vários alertas;
- vários registros de acionamento de atuadores.

### Observação sobre a fase atual

A fase atual não será armazenada diretamente em `lote`. Ela será obtida pelo registro mais recente de `historico_fase`, evitando duplicidade de informação.

## Histórico de fase

Registra cada fase aplicada a um lote ao longo do cultivo.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_historico_fase` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_lote` | `INT UNSIGNED` | Sim | Lote que passou pela fase |
| `id_fase_cultivo` | `INT UNSIGNED` | Sim | Fase aplicada |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário que confirmou a mudança |
| `iniciado_em` | `DATETIME(3)` | Sim | Instante em que a fase começou |
| `observacoes` | `VARCHAR(255)` | Não | Motivo ou informação adicional |
| `criado_em` | `DATETIME(3)` | Sim | Instante em que o registro foi salvo |

### Restrições

- `id_historico_fase` é a chave primária.
- `id_lote` referencia `lote`.
- `id_fase_cultivo` referencia `fase_cultivo`.
- `id_usuario` referencia `usuario` quando preenchido.
- A fase deve pertencer ao mesmo cogumelo cultivado no lote.
- Todo lote deve possuir uma fase inicial.
- A fase atual é o registro mais recente de `historico_fase`.
- Registros não devem ser alterados ou excluídos durante o uso normal.
- Uma correção deve gerar um novo registro, preservando o histórico anterior.

### Relacionamentos

- Um lote pode possuir vários registros de fase.
- Uma fase pode aparecer em vários lotes.
- Um histórico de fase pode possuir várias configurações.
- Cada configuração deve referenciar o histórico de fase em que foi aplicada.

## Configuração

Registra os parâmetros ambientais aplicados durante uma fase específica de um lote.

Cada alteração gera um novo registro, preservando as configurações anteriores.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_configuracao` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_historico_fase` | `INT UNSIGNED` | Sim | Fase do lote em que a configuração foi aplicada |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário responsável pelo ajuste |
| `origem` | Domínio controlado | Sim | Origem da configuração |
| `temperatura_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da temperatura ambiente |
| `temperatura_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da temperatura ambiente |
| `temperatura_composto_min` | `DECIMAL(5,2)` | Não | Limite mínimo da temperatura do composto |
| `temperatura_composto_max` | `DECIMAL(5,2)` | Não | Limite máximo da temperatura do composto |
| `umidade_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da umidade relativa |
| `umidade_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da umidade relativa |
| `co2_max` | `DECIMAL(7,2)` | Sim | Limite máximo de CO₂ em ppm |
| `fotoperiodo_minutos` | `SMALLINT UNSIGNED` | Sim | Duração diária da iluminação |
| `observacoes` | `VARCHAR(255)` | Não | Motivo ou detalhe do ajuste |
| `aplicado_em` | `DATETIME(3)` | Sim | Instante em que passou a valer |
| `criado_em` | `DATETIME(3)` | Sim | Instante em que foi salvo |

### Origens iniciais

- `padrao_fase`: parâmetros copiados ao iniciar uma fase;
- `ajuste_usuario`: parâmetros alterados pelo produtor;
- `migracao`: registro importado do sistema anterior.

### Restrições

- `id_configuracao` é a chave primária.
- `id_historico_fase` referencia `historico_fase`.
- `id_usuario` referencia `usuario` quando preenchido.
- `id_lote` não é armazenado, pois é obtido por `historico_fase`.
- Valores mínimos não podem ultrapassar os respectivos valores máximos.
- Umidade deve permanecer entre 0 e 100.
- `co2_max` deve ser maior que zero.
- `fotoperiodo_minutos` deve permanecer entre 0 e 1440.
- As temperaturas do composto devem ser preenchidas juntas ou permanecer ambas vazias.
- Configurações não devem ser alteradas ou excluídas durante o uso normal.
- A configuração vigente é o registro mais recente da fase atual, ordenado por `aplicado_em` e `id_configuracao`.

## sensor

Representa um canal lógico de medição instalado em uma sala.

Um equipamento físico capaz de medir mais de uma grandeza será representado por mais de um sensor lógico. Por exemplo, um DHT22 gera um sensor de temperatura e outro de umidade.

| Campo | Tipo lógico | Obrigatório | Descrição |
|---|---|---:|---|
| id_sensor | INT UNSIGNED | Sim | Identificador interno |
| id_sala | INT UNSIGNED | Sim | Sala onde o sensor está instalado |
| codigo | VARCHAR(50) | Sim | Código estável do sensor dentro da sala |
| nome | VARCHAR(100) | Sim | Nome apresentado ao usuário |
| grandeza | ENUM | Sim | Grandeza medida pelo sensor |
| localizacao | ENUM | Sim | Local onde a medição é realizada |
| descricao | VARCHAR(255) | Não | Informações adicionais |
| ativo | BOOLEAN | Sim | Indica se o sensor pode receber novas leituras |
| instalado_em | DATETIME(3) | Sim | Instante de instalação em UTC |
| desativado_em | DATETIME(3) | Não | Instante de desativação em UTC |
| criado_em | DATETIME(3) | Sim | Instante de criação em UTC |
| atualizado_em | DATETIME(3) | Sim | Instante da última atualização em UTC |

### Valores iniciais

- `grandeza`: `temperatura`, `umidade` ou `co2`;
- `localizacao`: `ambiente`, `composto` ou `externo`;
- a unidade de medida é determinada pela grandeza e não será armazenada em cada sensor;
- o código do sensor deve ser único dentro da sala;
- um sensor inativo permanece associado ao histórico, mas não recebe novas leituras;
- sensores de uma coleta devem pertencer à mesma sala do lote monitorado.

## coleta

Representa um ciclo de medição realizado para um lote. Uma coleta agrupa as leituras produzidas pelos sensores naquele instante.

| Campo | Tipo lógico | Obrigatório | Descrição |
|---|---|---:|---|
| id_coleta | BIGINT UNSIGNED | Sim | Identificador interno |
| id_lote | INT UNSIGNED | Sim | Lote monitorado |
| identificador_externo | CHAR(36) | Sim | UUID utilizado para impedir duplicidade de envios |
| origem | ENUM | Sim | Origem da coleta |
| medido_em | DATETIME(3) | Sim | Instante real da medição em UTC |
| recebido_em | DATETIME(3) | Sim | Instante em que a API recebeu a coleta em UTC |

### Valores iniciais

- `origem`: `esp32`, `manual` ou `migracao`;
- o `identificador_externo` deve ser único;
- o ESP32 gera o identificador antes de armazenar ou enviar a coleta;
- para coletas manuais, a API gera o identificador;
- o reenvio de um identificador já registrado não cria outra coleta;
- uma coleta pode possuir várias leituras, mas somente uma leitura por sensor;
- uma coleta atrasada pode ser recebida após a finalização do lote quando `medido_em` for anterior ou igual a `finalizado_em`;
- `recebido_em` é definido pela API e não pelo equipamento;
- não será criado `criado_em`, pois a coleta é registrada assim que for recebida.