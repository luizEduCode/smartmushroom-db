# Arquitetura do banco de dados

## Objetivo

Definir como o banco de dados do SmartMushroom será estruturado, versionado, documentado e implantado de forma reproduzível.

## Decisões fundamentais

- O banco oficial será MySQL 8.4 LTS.
- O repositório `smartmushroom-db` será a fonte oficial da estrutura do banco.
- A estrutura será mantida por migrations SQL sequenciais.
- Migrations publicadas não deverão ser alteradas.
- Dados essenciais serão separados de dados fictícios.
- Backups e dados reais não serão versionados no Git.
- O ambiente local utilizará Docker Compose.
- O MySQL Workbench será utilizado para administração e modelagem visual, não como fonte exclusiva da estrutura.

## Organização dos arquivos

```text
smartmushroom-db/
├── compose.yaml  # Definição do ambiente local
├── .env.example  # Modelo das variáveis de ambiente
├── migrations/   # Alterações estruturais ordenadas
├── seeds/        # Dados essenciais para o funcionamento
├── fixtures/     # Dados fictícios para desenvolvimento e testes
├── scripts/      # Ferramentas de instalação e validação
├── docs/         # Arquitetura e documentação do banco
├── legacy/       # Arquivos históricos que não devem ser executados
├── tests/        # Verificações do schema e das regras
└── README.md
```

## Convenções de nomenclatura

O banco de dados utiliza nomes em português e no padrão `snake_case`.

### Regras

- Tabelas devem possuir nomes no singular.
- Tabelas e colunas devem utilizar letras minúsculas.
- Palavras devem ser separadas por sublinhado.
- Chaves primárias devem utilizar o formato `id_<tabela>`.
- Chaves estrangeiras devem possuir o mesmo nome da chave referenciada.
- Datas de criação e atualização devem seguir um padrão consistente.
- Índices e constraints devem possuir nomes explícitos.

### Exemplos

```text
fase_cultivo
id_fase_cultivo
temperatura_ambiente_min
criado_em
id_lote
```

## Padrão das chaves primárias

O banco utiliza chaves numéricas incrementais sem sinal.

### Tabelas de cadastro e menor volume

Devem utilizar:

```sql
INT UNSIGNED AUTO_INCREMENT
```

Aplicável, inicialmente, a:

- `sala`;
- `usuario`;
- `cogumelo`;
- `fase_cultivo`;
- `lote`;
- `sensor`;
- `atuador`;
- `configuracao`;
- `historico_fase`;
- `alerta`.

### Tabelas históricas de alto volume

Devem utilizar:

```sql
BIGINT UNSIGNED AUTO_INCREMENT
```

Aplicável, inicialmente, a:

- `coleta`;
- `leitura`;
- `controle_atuador`;
- `auditoria`.

### Chaves estrangeiras

Toda chave estrangeira deve possuir exatamente o mesmo tipo da chave primária referenciada, incluindo o atributo `UNSIGNED`.

## Padrão de data e hora

Todos os instantes do sistema devem ser armazenados em UTC.

### Instantes

Eventos que possuem data e hora devem utilizar:

```sql
DATETIME(3)
```

A precisão de milissegundos permite ordenar eventos próximos e controlar sincronizações realizadas pelos equipamentos.

Exemplos:

- `criado_em`;
- `atualizado_em`;
- `medido_em`;
- `recebido_em`;
- `ocorrido_em`;
- `aplicado_em`;
- `registrado_em`;
- `finalizado_em`.

### Datas sem horário

O tipo `DATE` deve ser utilizado somente quando o horário não possuir significado para a regra de negócio.

### Exibição

A API e o aplicativo são responsáveis por converter os valores UTC para o fuso horário do usuário.

Inicialmente, o sistema utilizará `America/Sao_Paulo`.

### Programações em horário local

Horários relacionados à rotina do produtor devem ser interpretados no fuso horário da propriedade.

A iluminação automática inicia às 06:00 em `America/Sao_Paulo`, mas os instantes efetivamente registrados continuam sendo armazenados em UTC.

A API e o firmware são responsáveis pela conversão entre o horário local da programação e UTC.

### Coletas offline

A coleta deve registrar separadamente:

- `medido_em`: instante em que o equipamento realizou a medição;
- `recebido_em`: instante em que a API recebeu ou o processo de migração importou a coleta.

Essa separação permite sincronizar dados atrasados sem alterar o momento original da medição.

### Finalização do lote

A finalização deve registrar um instante preciso em `finalizado_em`, permitindo comparar a finalização com `coleta.medido_em`.

Uma coleta atrasada somente pode ser associada ao lote quando tiver sido medida durante o período em que ele estava ativo.

## Identificadores externos e idempotência

Eventos que podem ser enviados novamente devem possuir um identificador externo único.

O campo `identificador_externo` utiliza um UUID armazenado como `CHAR(36)`.

### Coletas

- O ESP32 gera o identificador antes de armazenar ou enviar uma coleta.
- A API gera o identificador para coletas manuais.
- O processo de migração gera o identificador para registros importados.
- O reenvio do mesmo identificador não cria outra coleta.

### Controle dos atuadores

- A API gera o identificador para comandos manuais e automações online.
- O ESP32 gera o identificador para ações realizadas pela automação local.
- O processo de migração gera o identificador para registros importados.
- O mesmo identificador deve ser reutilizado em todas as tentativas de sincronização.

## Controle e confirmação dos atuadores

Um comando solicitado não significa necessariamente que o equipamento alterou seu estado físico.

A tabela `controle_atuador` distingue o estado desejado da confirmação de execução.

### Estados de execução

```text
pendente → aplicado
         ↘ falhou
```

- `pendente`: o comando foi registrado, mas ainda não foi confirmado pelo ESP32;
- `aplicado`: a execução ocorreu ou foi confirmada;
- `falhou`: o comando não pôde ser executado.

### Instantes

- `ocorrido_em`: momento em que o comando ou acionamento foi gerado;
- `aplicado_em`: momento em que a execução ocorreu ou foi confirmada;
- `registrado_em`: momento em que o sistema registrou ou importou o evento.

O estado efetivo do atuador é determinado pelo registro com `status_execucao` igual a `aplicado` mais recente, ordenado por `aplicado_em` e `id_controle_atuador`.

Após a criação de um registro de controle, somente `status_execucao` e `aplicado_em` podem ser atualizados.

## Escopo de propriedade

A versão inicial do SmartMushroom atende uma única propriedade rural.

Não será criada uma entidade `propriedade` nesta etapa. Todas as salas, usuários, sensores, atuadores e lotes pertencem implicitamente à mesma operação.

### Evolução futura

O suporte a múltiplas propriedades poderá ser introduzido por uma migration futura, adicionando a entidade `propriedade` e seus relacionamentos.

Essa possibilidade não deve aumentar a complexidade do modelo inicial.

## Ambiente local de desenvolvimento

O ambiente local utiliza Docker Compose para executar o MySQL 8.4 LTS de forma isolada e reproduzível.

### Responsabilidades

- O Docker Desktop executa o servidor MySQL.
- O arquivo `compose.yaml` descreve o serviço utilizado pelo projeto.
- O arquivo `.env.example` documenta as variáveis necessárias.
- O arquivo `.env` contém as credenciais locais e não deve ser versionado.
- O volume `mysql_data` preserva os dados entre reinicializações do contêiner.
- O MySQL Workbench é utilizado como cliente gráfico para administração e consultas.

### Conexão local

```text
Host: 127.0.0.1
Porta: 3307
Banco: smartmushroom_db
Usuário: smartmushroom_app
```

A porta `3307` permite que o MySQL 8.4 do projeto coexista temporariamente com o MariaDB antigo na porta `3306`.

### API local

Nesta etapa, a API PHP continua sendo executada pelo Apache do XAMPP.

O módulo MySQL do XAMPP não faz parte do novo ambiente oficial. Ele deve ser iniciado somente quando for necessário consultar o banco MariaDB legado.

A migração do Apache e do PHP para contêineres fica fora do escopo atual e poderá ser avaliada futuramente.