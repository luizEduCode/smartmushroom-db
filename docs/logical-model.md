# Modelo lógico do banco de dados

Este documento descreve as entidades, os atributos e os relacionamentos do banco de dados do SmartMushroom.

O modelo considera uma única propriedade rural, utiliza nomenclatura em português no padrão `snake_case` e armazena instantes em UTC com precisão de milissegundos.

As restrições descritas poderão ser implementadas no MySQL, na API ou em ambos, conforme a capacidade técnica e a necessidade de garantir consistência transacional.

## Sala

Representa um ambiente físico utilizado para cultivo e monitoramento.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_sala` | `INT UNSIGNED` | Sim | Chave primária interna |
| `codigo` | `VARCHAR(50)` | Sim | Identificador estável da sala |
| `nome` | `VARCHAR(100)` | Sim | Nome exibido ao usuário |
| `descricao` | `VARCHAR(255)` | Não | Informações adicionais |
| `ativa` | `BOOLEAN` | Sim | Indica se a sala pode ser utilizada |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Restrições

- `id_sala` é a chave primária.
- `codigo` deve ser único.
- Uma sala com histórico não deve ser excluída durante o uso normal.
- Uma sala desativada não pode receber novos lotes, sensores ou atuadores.
- A desativação não remove lotes, sensores, atuadores ou históricos existentes.

### Relacionamentos

- Uma sala pode possuir vários lotes ao longo do tempo.
- Uma sala pode possuir vários sensores.
- Uma sala pode possuir vários atuadores.

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

### Relacionamentos

- Um cogumelo pode possuir várias fases de cultivo.
- Um cogumelo pode aparecer em vários lotes ao longo do tempo.

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

- Uma fase de cultivo pertence a um cogumelo.
- Uma fase de cultivo pode aparecer em vários históricos de fase.
- Ao ser aplicada a um lote, seus parâmetros originam uma nova configuração histórica.

## Lote

Representa um ciclo de cultivo realizado em uma sala.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_lote` | `INT UNSIGNED` | Sim | Chave primária interna |
| `codigo` | `VARCHAR(50)` | Sim | Identificação estável do lote |
| `id_sala` | `INT UNSIGNED` | Sim | Sala utilizada pelo lote |
| `id_cogumelo` | `INT UNSIGNED` | Sim | Cogumelo cultivado |
| `id_usuario_responsavel` | `INT UNSIGNED` | Não | Usuário responsável pelo lote |
| `status` | `ENUM` | Sim | Estado atual do lote |
| `iniciado_em` | `DATETIME(3)` | Sim | Instante de início em UTC |
| `finalizado_em` | `DATETIME(3)` | Não | Instante de finalização em UTC |
| `quantidade_unidades` | `INT UNSIGNED` | Não | Quantidade de unidades produtivas |
| `tipo_unidade` | `VARCHAR(30)` | Não | Tipo da unidade, como saco ou bandeja |
| `peso_unitario_kg` | `DECIMAL(8,3)` | Não | Peso médio de cada unidade |
| `fornecedor_semente` | `VARCHAR(150)` | Não | Fornecedor da semente utilizada |
| `observacoes` | `TEXT` | Não | Informações produtivas adicionais |
| `criado_em` | `DATETIME(3)` | Sim | Momento do cadastro em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Momento da última alteração em UTC |

### Valores iniciais

- `status`: `ativo` ou `finalizado`.

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
- A reabertura deve limpar `finalizado_em` e somente pode ocorrer se a sala não possuir outro lote ativo.
- `finalizado_em` não pode ser anterior a `iniciado_em`.
- Quantidade e peso, quando informados, devem ser maiores que zero.
- Uma sala desativada não pode receber um novo lote.
- Um cogumelo desativado não pode ser selecionado em um novo lote.
- Lotes não devem ser excluídos durante o uso normal.

### Relacionamentos

- Um lote pertence a uma sala.
- Um lote pertence a um cogumelo.
- Um lote pode possuir um usuário responsável.
- Um lote pode possuir vários históricos de fase.
- Um lote pode possuir várias configurações por meio de seus históricos de fase.
- Um lote pode possuir várias coletas.
- Um lote pode possuir vários alertas.
- Um lote pode aparecer em vários registros de controle de atuadores.

### Observação sobre a fase atual

A fase atual não será armazenada diretamente em `lote`. Ela será obtida pelo registro mais recente de `historico_fase`, ordenado por `iniciado_em` e `id_historico_fase`, evitando duplicidade de informação.

## Histórico de fase

Registra cada fase aplicada a um lote ao longo do cultivo.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_historico_fase` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_lote` | `INT UNSIGNED` | Sim | Lote que passou pela fase |
| `id_fase_cultivo` | `INT UNSIGNED` | Sim | Fase aplicada |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário que confirmou a mudança |
| `iniciado_em` | `DATETIME(3)` | Sim | Instante em que a fase começou em UTC |
| `observacoes` | `VARCHAR(255)` | Não | Motivo ou informação adicional |
| `criado_em` | `DATETIME(3)` | Sim | Instante em que o registro foi salvo em UTC |

### Restrições

- `id_historico_fase` é a chave primária.
- `id_lote` referencia `lote`.
- `id_fase_cultivo` referencia `fase_cultivo`.
- `id_usuario` referencia `usuario` quando preenchido.
- A fase deve pertencer ao mesmo cogumelo cultivado no lote.
- Todo lote deve possuir uma fase inicial.
- A fase atual é o registro mais recente, ordenado por `iniciado_em` e `id_historico_fase`.
- Registros não devem ser alterados ou excluídos durante o uso normal.
- Uma correção deve gerar um novo registro compensatório, preservando o histórico anterior.

### Relacionamentos

- Um histórico de fase pertence a um lote.
- Um histórico de fase referencia uma fase de cultivo.
- Um histórico de fase pode registrar o usuário que confirmou a mudança.
- Um histórico de fase pode possuir várias configurações.

## Configuração

Registra os parâmetros ambientais aplicados durante uma fase específica de um lote.

Cada alteração gera um novo registro, preservando as configurações anteriores.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_configuracao` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_historico_fase` | `INT UNSIGNED` | Sim | Histórico de fase em que a configuração foi aplicada |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário responsável pelo ajuste |
| `origem` | `ENUM` | Sim | Origem da configuração |
| `temperatura_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da temperatura ambiente |
| `temperatura_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da temperatura ambiente |
| `temperatura_composto_min` | `DECIMAL(5,2)` | Não | Limite mínimo da temperatura do composto |
| `temperatura_composto_max` | `DECIMAL(5,2)` | Não | Limite máximo da temperatura do composto |
| `umidade_ambiente_min` | `DECIMAL(5,2)` | Sim | Limite mínimo da umidade relativa |
| `umidade_ambiente_max` | `DECIMAL(5,2)` | Sim | Limite máximo da umidade relativa |
| `co2_max` | `DECIMAL(7,2)` | Sim | Limite máximo de CO₂ em ppm |
| `fotoperiodo_minutos` | `SMALLINT UNSIGNED` | Sim | Duração diária da iluminação |
| `observacoes` | `VARCHAR(255)` | Não | Motivo ou detalhe do ajuste |
| `aplicado_em` | `DATETIME(3)` | Sim | Instante em que passou a valer em UTC |
| `criado_em` | `DATETIME(3)` | Sim | Instante em que foi salvo em UTC |

### Valores iniciais

- `origem`: `padrao_fase`, `ajuste_usuario` ou `migracao`.

### Restrições

- `id_configuracao` é a chave primária.
- `id_historico_fase` referencia `historico_fase`.
- `id_usuario` referencia `usuario` quando preenchido.
- `id_usuario` é obrigatório quando `origem` for `ajuste_usuario`.
- `id_lote` não é armazenado, pois é obtido por `historico_fase`.
- Valores mínimos não podem ultrapassar os respectivos valores máximos.
- A umidade relativa deve permanecer entre 0 e 100.
- `co2_max` deve ser maior que zero.
- `fotoperiodo_minutos` deve permanecer entre 0 e 1440.
- As temperaturas do composto devem ser preenchidas juntas ou permanecer ambas vazias.
- Configurações não devem ser alteradas ou excluídas durante o uso normal.
- A configuração vigente é o registro mais recente da fase atual, ordenado por `aplicado_em` e `id_configuracao`.

### Relacionamentos

- Uma configuração pertence a um histórico de fase.
- Uma configuração pode registrar o usuário responsável pelo ajuste.
- O lote da configuração é obtido por meio de `historico_fase`.

## Sensor

Representa um canal lógico de medição instalado em uma sala.

Um equipamento físico capaz de medir mais de uma grandeza será representado por mais de um sensor lógico. Por exemplo, um DHT22 gera um sensor de temperatura e outro de umidade.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_sensor` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_sala` | `INT UNSIGNED` | Sim | Sala onde o sensor está instalado |
| `codigo` | `VARCHAR(50)` | Sim | Identificador estável do sensor dentro da sala |
| `nome` | `VARCHAR(100)` | Sim | Nome apresentado ao usuário |
| `grandeza` | `ENUM` | Sim | Grandeza medida pelo sensor |
| `localizacao` | `ENUM` | Sim | Local onde a medição é realizada |
| `descricao` | `VARCHAR(255)` | Não | Informações adicionais |
| `ativo` | `BOOLEAN` | Sim | Indica se o sensor pode receber novas leituras |
| `instalado_em` | `DATETIME(3)` | Sim | Instante de instalação em UTC |
| `desativado_em` | `DATETIME(3)` | Não | Instante de desativação em UTC |
| `criado_em` | `DATETIME(3)` | Sim | Instante de criação em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Instante da última atualização em UTC |

### Valores iniciais

- `grandeza`: `temperatura`, `umidade` ou `co2`.
- `localizacao`: `ambiente`, `composto` ou `externo`.
- `temperatura` utiliza graus Celsius.
- `umidade` utiliza porcentagem de umidade relativa.
- `co2` utiliza partes por milhão.

### Restrições

- `id_sensor` é a chave primária.
- `id_sala` referencia `sala`.
- A combinação de `id_sala` e `codigo` deve ser única.
- A localização `composto` somente pode ser utilizada com a grandeza `temperatura` nesta primeira versão.
- A grandeza `co2` somente pode utilizar a localização `ambiente` nesta primeira versão.
- Sensores com localização `externo` são utilizados para observação e não geram alertas baseados nos limites da configuração do lote.
- Um sensor inativo permanece associado ao histórico, mas não recebe novas leituras.
- Quando `ativo` for falso, `desativado_em` deve estar preenchido.
- Sensores de uma coleta devem pertencer à mesma sala do lote monitorado.

### Relacionamentos

- Um sensor pertence a uma sala.
- Um sensor pode possuir várias leituras.
- Um sensor pode estar relacionado a vários alertas.

## Coleta

Representa um ciclo de medição realizado para um lote. Uma coleta agrupa as leituras produzidas pelos sensores naquele instante.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_coleta` | `BIGINT UNSIGNED` | Sim | Chave primária interna |
| `id_lote` | `INT UNSIGNED` | Sim | Lote monitorado |
| `identificador_externo` | `CHAR(36)` | Sim | UUID utilizado para impedir duplicidade de envios |
| `origem` | `ENUM` | Sim | Origem da coleta |
| `medido_em` | `DATETIME(3)` | Sim | Instante real da medição em UTC |
| `recebido_em` | `DATETIME(3)` | Sim | Instante de recebimento ou importação em UTC |

### Valores iniciais

- `origem`: `esp32`, `manual` ou `migracao`.

### Restrições

- `id_coleta` é a chave primária.
- `id_lote` referencia `lote`.
- `identificador_externo` deve ser único.
- O ESP32 gera `identificador_externo` antes de armazenar ou enviar uma coleta de origem `esp32`.
- A API gera `identificador_externo` para uma coleta de origem `manual`.
- O processo de migração gera `identificador_externo` para uma coleta de origem `migracao`.
- O reenvio de um identificador já registrado não cria outra coleta.
- Uma coleta pode possuir várias leituras, mas somente uma leitura por sensor.
- `medido_em` não pode ser anterior a `lote.iniciado_em`.
- Uma coleta atrasada pode ser recebida após a finalização quando `medido_em` estiver entre `lote.iniciado_em` e `lote.finalizado_em`.
- `recebido_em` é definido pela API ou pelo processo de migração, nunca pelo equipamento.
- `criado_em` não é armazenado, pois a coleta é registrada assim que for recebida ou importada.

### Relacionamentos

- Uma coleta pertence a um lote.
- Uma coleta pode possuir várias leituras.

## Leitura

Representa um valor produzido por um sensor dentro de uma coleta.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_leitura` | `BIGINT UNSIGNED` | Sim | Chave primária interna |
| `id_coleta` | `BIGINT UNSIGNED` | Sim | Coleta à qual a leitura pertence |
| `id_sensor` | `INT UNSIGNED` | Sim | Sensor lógico que produziu o valor |
| `valor` | `DECIMAL(10,3)` | Sim | Valor medido |

### Restrições

- `id_leitura` é a chave primária.
- `id_coleta` referencia `coleta`.
- `id_sensor` referencia `sensor`.
- A combinação de `id_coleta` e `id_sensor` deve ser única.
- O instante da medição é obtido por meio de `coleta.medido_em`.
- A grandeza, a localização e a unidade são determinadas por `sensor`.
- Um sensor que falhar pode não possuir leitura naquela coleta.
- Valores inválidos de hardware, como `NaN`, não devem ser enviados ao banco.
- O sensor deve pertencer à sala do lote relacionado à coleta.
- Uma leitura registrada não deve ser alterada ou excluída durante o uso normal.

### Relacionamentos

- Uma leitura pertence a uma coleta.
- Uma leitura pertence a um sensor.
- Uma leitura pode originar alertas de tipos diferentes durante seu processamento, mas não pode originar alertas duplicados do mesmo tipo.

## Usuário

Representa uma pessoa autorizada a acessar e operar o SmartMushroom.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_usuario` | `INT UNSIGNED` | Sim | Chave primária interna |
| `nome` | `VARCHAR(100)` | Sim | Nome do usuário |
| `email` | `VARCHAR(150)` | Sim | E-mail utilizado na autenticação |
| `senha_hash` | `VARCHAR(255)` | Sim | Hash seguro da senha |
| `perfil` | `ENUM` | Sim | Nível de permissão |
| `ativo` | `BOOLEAN` | Sim | Indica se o usuário pode acessar o sistema |
| `criado_em` | `DATETIME(3)` | Sim | Instante de criação em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Instante da última alteração em UTC |

### Valores iniciais

- `perfil`: `administrador` ou `operador`.

### Restrições

- `id_usuario` é a chave primária.
- `email` deve ser único, sem diferenciação entre letras maiúsculas e minúsculas.
- A senha nunca deve ser armazenada diretamente.
- Usuários relacionados ao histórico não devem ser excluídos.
- Um usuário desativado não pode autenticar.
- Alterações de usuários e permissões devem ser registradas em `auditoria`.
- Recuperação de senha e confirmação de e-mail ficam fora da primeira versão.

### Relacionamentos

- Um usuário pode ser responsável por vários lotes.
- Um usuário pode confirmar vários históricos de fase.
- Um usuário pode realizar vários ajustes de configuração.
- Um usuário pode solicitar vários controles manuais de atuadores.
- Um usuário pode reconhecer ou resolver vários alertas.
- Um usuário pode estar relacionado a vários registros de auditoria.

## Atuador

Representa um equipamento controlado pelo SmartMushroom.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_atuador` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_sala` | `INT UNSIGNED` | Sim | Sala onde o equipamento está instalado |
| `codigo` | `VARCHAR(50)` | Sim | Identificador estável do atuador dentro da sala |
| `nome` | `VARCHAR(100)` | Sim | Nome apresentado ao usuário |
| `tipo` | `ENUM` | Sim | Tipo do equipamento |
| `estado_seguro` | `ENUM` | Sim | Estado adotado em reinicializações ou falhas |
| `ativo` | `BOOLEAN` | Sim | Indica se o atuador pode receber comandos |
| `instalado_em` | `DATETIME(3)` | Sim | Instante da instalação em UTC |
| `desativado_em` | `DATETIME(3)` | Não | Instante da desativação em UTC |
| `criado_em` | `DATETIME(3)` | Sim | Instante de criação em UTC |
| `atualizado_em` | `DATETIME(3)` | Sim | Instante da última alteração em UTC |

### Valores iniciais

- `tipo`: `umidificador`, `exaustor`, `ventilador`, `aquecedor`, `refrigeracao`, `iluminacao` ou `outro`.
- `estado_seguro`: `ligado` ou `desligado`.

### Restrições

- `id_atuador` é a chave primária.
- `id_sala` referencia `sala`.
- A combinação de `id_sala` e `codigo` deve ser única.
- `ativo` indica disponibilidade e não o estado ligado ou desligado.
- O estado efetivo é determinado pelo registro `aplicado` mais recente de `controle_atuador`, ordenado por `aplicado_em` e `id_controle_atuador`.
- Atuadores relacionados ao histórico não devem ser excluídos.
- Atuadores inativos não podem receber novos comandos.
- Quando `ativo` for falso, `desativado_em` deve estar preenchido.
- A primeira versão utiliza somente controle binário.
- O controle proporcional de potência ou velocidade fica para uma evolução futura.

### Relacionamentos

- Um atuador pertence a uma sala.
- Um atuador pode possuir vários registros de controle.
- Um atuador pode estar relacionado a vários alertas.

## Controle de atuador

Representa um comando solicitado ou uma mudança de estado realizada localmente. A confirmação de execução permite distinguir o comando desejado do estado efetivamente aplicado pelo ESP32.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_controle_atuador` | `BIGINT UNSIGNED` | Sim | Chave primária interna |
| `id_atuador` | `INT UNSIGNED` | Sim | Atuador controlado |
| `id_lote` | `INT UNSIGNED` | Não | Lote relacionado ao acionamento |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário responsável por uma ação manual |
| `identificador_externo` | `CHAR(36)` | Sim | UUID utilizado para impedir duplicidade de registros |
| `estado` | `ENUM` | Sim | Estado solicitado ou aplicado ao atuador |
| `origem` | `ENUM` | Sim | Origem do comando ou acionamento |
| `status_execucao` | `ENUM` | Sim | Situação da execução do comando |
| `motivo` | `VARCHAR(255)` | Não | Explicação do acionamento |
| `ocorrido_em` | `DATETIME(3)` | Sim | Instante em que o comando ou acionamento foi gerado em UTC |
| `aplicado_em` | `DATETIME(3)` | Não | Instante em que o ESP32 confirmou a execução em UTC |
| `registrado_em` | `DATETIME(3)` | Sim | Instante em que o sistema registrou ou importou o evento em UTC |

### Valores iniciais

- `estado`: `ligado` ou `desligado`.
- `origem`: `manual`, `automacao_online`, `automacao_local` ou `migracao`.
- `status_execucao`: `pendente`, `aplicado` ou `falhou`.

### Restrições

- `id_controle_atuador` é a chave primária.
- `id_atuador` referencia `atuador`.
- `id_lote` referencia `lote` quando preenchido.
- `id_usuario` referencia `usuario` quando preenchido.
- `id_usuario` é obrigatório quando `origem` for `manual`.
- `id_usuario` deve permanecer vazio em ações automáticas.
- `id_lote` pode permanecer vazio durante manutenção ou quando não houver lote ativo.
- Quando preenchido, o lote deve pertencer à mesma sala do atuador.
- Quando `id_lote` estiver preenchido, `ocorrido_em` não pode ser anterior a `lote.iniciado_em`.
- Para um lote finalizado, `ocorrido_em` não pode ser posterior a `lote.finalizado_em`.
- Um evento ocorrido enquanto o lote estava ativo pode ser sincronizado depois da finalização.
- `identificador_externo` deve ser único.
- A API gera o identificador para ações manuais e automações online.
- O ESP32 gera o identificador para ações realizadas pela automação local.
- O processo de migração gera o identificador para registros de origem `migracao`.
- Reenvios do mesmo identificador não criam novos registros.
- Comandos originados pela API iniciam com `status_execucao` igual a `pendente`.
- Ações executadas localmente pelo ESP32 podem ser registradas diretamente como `aplicado`.
- `aplicado_em` é obrigatório quando `status_execucao` for `aplicado`.
- `aplicado_em` deve permanecer vazio quando `status_execucao` for `pendente` ou `falhou`.
- O estado efetivo do atuador considera apenas registros com `status_execucao` igual a `aplicado`.
- Eventos recebidos com atraso não substituem eventos aplicados posteriormente.
- Somente `status_execucao` e `aplicado_em` podem ser atualizados após a criação; os demais dados permanecem imutáveis.

### Relacionamentos

- Um registro de controle pertence a um atuador.
- Um registro de controle pode estar relacionado a um lote.
- Um registro de controle manual referencia o usuário que solicitou a ação.

## Alerta

Representa uma condição anormal detectada durante o monitoramento ou controle de um lote.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_alerta` | `INT UNSIGNED` | Sim | Chave primária interna |
| `id_lote` | `INT UNSIGNED` | Sim | Lote relacionado ao alerta |
| `id_leitura` | `BIGINT UNSIGNED` | Não | Leitura que originou o alerta |
| `id_sensor` | `INT UNSIGNED` | Não | Sensor relacionado ao alerta |
| `id_atuador` | `INT UNSIGNED` | Não | Atuador relacionado ao alerta |
| `tipo` | `ENUM` | Sim | Condição que gerou o alerta |
| `severidade` | `ENUM` | Sim | Nível de importância |
| `status` | `ENUM` | Sim | Situação atual do alerta |
| `valor_observado` | `DECIMAL(10,3)` | Não | Valor que originou o alerta |
| `limite_referencia` | `DECIMAL(10,3)` | Não | Limite vigente quando o alerta foi aberto |
| `mensagem` | `VARCHAR(255)` | Sim | Explicação apresentada ao usuário |
| `aberto_em` | `DATETIME(3)` | Sim | Instante em que a condição foi detectada em UTC |
| `reconhecido_em` | `DATETIME(3)` | Não | Instante em que o alerta foi reconhecido em UTC |
| `id_usuario_reconhecimento` | `INT UNSIGNED` | Não | Usuário que reconheceu o alerta |
| `resolvido_em` | `DATETIME(3)` | Não | Instante em que o alerta foi resolvido em UTC |
| `id_usuario_resolucao` | `INT UNSIGNED` | Não | Usuário que confirmou uma resolução manual |
| `atualizado_em` | `DATETIME(3)` | Sim | Instante da última alteração do alerta em UTC |

### Valores iniciais

- `tipo`: `temperatura_baixa`, `temperatura_alta`, `umidade_baixa`, `umidade_alta`, `co2_alto`, `falha_sensor`, `falha_atuador`, `comunicacao` ou `outro`.
- `severidade`: `aviso` ou `critico`.
- `status`: `aberto`, `reconhecido` ou `resolvido`.

### Restrições

- `id_alerta` é a chave primária.
- `id_lote` referencia `lote`.
- `id_leitura` referencia `leitura` quando preenchido.
- `id_sensor` referencia `sensor` quando preenchido.
- `id_atuador` referencia `atuador` quando preenchido.
- `id_usuario_reconhecimento` referencia `usuario` quando preenchido.
- `id_usuario_resolucao` referencia `usuario` quando preenchido.
- Um alerta inicia com `status` igual a `aberto`.
- Reconhecer um alerta não significa que a condição foi resolvida.
- `id_usuario_reconhecimento` e `reconhecido_em` devem ser preenchidos juntos.
- `resolvido_em` deve ser preenchido quando `status` for `resolvido`.
- `id_usuario_resolucao` permanece vazio quando a resolução for automática.
- `atualizado_em` deve ser atualizado sempre que o estado do alerta ou os dados de reconhecimento e resolução forem alterados.
- Enquanto existir um alerta `aberto` ou `reconhecido` para a mesma combinação de `id_lote`, `tipo`, `id_sensor` e `id_atuador`, outro alerta equivalente não deve ser criado.
- Quando `id_leitura` e `id_sensor` estiverem preenchidos, ambos devem representar o mesmo sensor.
- Alertas ambientais são resolvidos automaticamente pela API quando a condição retorna aos limites permitidos.
- `valor_observado` e `limite_referencia` podem permanecer vazios em falhas de comunicação ou equipamento.
- O sensor, a leitura e o atuador informados devem ser compatíveis com a sala do lote.
- Após a criação, somente `status`, `reconhecido_em`, `id_usuario_reconhecimento`, `resolvido_em`, `id_usuario_resolucao` e `atualizado_em` podem ser alterados.
- Alertas não devem ser excluídos durante o uso normal.

### Relacionamentos

- Um alerta pertence a um lote.
- Um alerta pode estar relacionado a uma leitura.
- Um alerta pode estar relacionado a um sensor.
- Um alerta pode estar relacionado a um atuador.
- Um alerta pode registrar o usuário que o reconheceu.
- Um alerta pode registrar o usuário que confirmou sua resolução manual.

## Auditoria

Representa o histórico de ações relevantes realizadas no SmartMushroom. Substitui e amplia a antiga tabela `log_sistema`.

### Atributos

| Coluna | Tipo lógico | Obrigatória | Descrição |
|---|---|---:|---|
| `id_auditoria` | `BIGINT UNSIGNED` | Sim | Chave primária interna |
| `id_usuario` | `INT UNSIGNED` | Não | Usuário responsável pela ação |
| `origem` | `ENUM` | Sim | Origem da ação |
| `acao` | `VARCHAR(100)` | Sim | Ação executada |
| `entidade` | `VARCHAR(50)` | Sim | Tabela ou conceito afetado |
| `id_entidade` | `BIGINT UNSIGNED` | Não | Identificador do registro afetado |
| `dados_anteriores` | `JSON` | Não | Estado do registro antes da ação |
| `dados_novos` | `JSON` | Não | Estado do registro depois da ação |
| `endereco_ip` | `VARCHAR(45)` | Não | Endereço IP da requisição |
| `ocorrido_em` | `DATETIME(3)` | Sim | Instante em que a ação ocorreu em UTC |

### Valores iniciais

- `origem`: `usuario`, `sistema` ou `migracao`.

### Restrições

- `id_auditoria` é a chave primária.
- `id_usuario` referencia `usuario` quando preenchido.
- `id_usuario` é obrigatório quando `origem` for `usuario`.
- `id_usuario` pode permanecer vazio para ações do sistema ou de migração.
- `acao` e `entidade` devem utilizar valores em `snake_case` definidos pela aplicação.
- `id_entidade` não possui chave estrangeira direta, pois pode representar registros de diferentes tabelas.
- `dados_anteriores` e `dados_novos` são opcionais.
- Senhas, hashes, tokens e outros segredos nunca devem ser registrados.
- Registros de auditoria não devem ser alterados ou excluídos.
- Leituras, coletas e acionamentos automáticos não devem gerar auditoria individual.
- Comandos manuais de atuadores devem gerar auditoria, mesmo quando também estiverem registrados em `controle_atuador`, pois representam uma ação humana.
- Eventos que já possuem tabelas históricas próprias não devem ser duplicados sem necessidade.
- Ações administrativas e alterações relevantes de negócio devem ser auditadas.

### Relacionamentos

- Um registro de auditoria pode estar relacionado a um usuário.
- `entidade` e `id_entidade` formam uma referência lógica, sem chave estrangeira, para o registro afetado.

## Resumo dos relacionamentos

| Origem | Cardinalidade | Destino | Chave estrangeira |
|---|---:|---|---|
| `sala` | `1:N` | `lote` | `lote.id_sala` |
| `sala` | `1:N` | `sensor` | `sensor.id_sala` |
| `sala` | `1:N` | `atuador` | `atuador.id_sala` |
| `cogumelo` | `1:N` | `fase_cultivo` | `fase_cultivo.id_cogumelo` |
| `cogumelo` | `1:N` | `lote` | `lote.id_cogumelo` |
| `usuario` | `1:N` | `lote` | `lote.id_usuario_responsavel` |
| `lote` | `1:N` | `historico_fase` | `historico_fase.id_lote` |
| `fase_cultivo` | `1:N` | `historico_fase` | `historico_fase.id_fase_cultivo` |
| `usuario` | `1:N` | `historico_fase` | `historico_fase.id_usuario` |
| `historico_fase` | `1:N` | `configuracao` | `configuracao.id_historico_fase` |
| `usuario` | `1:N` | `configuracao` | `configuracao.id_usuario` |
| `lote` | `1:N` | `coleta` | `coleta.id_lote` |
| `coleta` | `1:N` | `leitura` | `leitura.id_coleta` |
| `sensor` | `1:N` | `leitura` | `leitura.id_sensor` |
| `atuador` | `1:N` | `controle_atuador` | `controle_atuador.id_atuador` |
| `lote` | `1:N` | `controle_atuador` | `controle_atuador.id_lote` |
| `usuario` | `1:N` | `controle_atuador` | `controle_atuador.id_usuario` |
| `lote` | `1:N` | `alerta` | `alerta.id_lote` |
| `leitura` | `1:N` | `alerta` | `alerta.id_leitura` |
| `sensor` | `1:N` | `alerta` | `alerta.id_sensor` |
| `atuador` | `1:N` | `alerta` | `alerta.id_atuador` |
| `usuario` | `1:N` | `alerta` | `alerta.id_usuario_reconhecimento` |
| `usuario` | `1:N` | `alerta` | `alerta.id_usuario_resolucao` |
| `usuario` | `1:N` | `auditoria` | `auditoria.id_usuario` |

A notação `1:N` representa um relacionamento de um para muitos. Quando a chave estrangeira é opcional, cada registro do destino pode referenciar zero ou um registro da origem. A relação representada por `auditoria.entidade` e `auditoria.id_entidade` é lógica e não possui chave estrangeira física.
