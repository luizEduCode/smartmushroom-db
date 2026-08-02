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
- O MySQL Workbench será utilizado para administração e modelagem visual, não como fonte exclusiva da estrutura.

## Organização dos arquivos

```text
smartmushroom-db/
├── migrations/  # Alterações estruturais ordenadas
├── seeds/       # Dados essenciais para o funcionamento
├── fixtures/    # Dados fictícios para desenvolvimento e testes
├── scripts/     # Ferramentas de instalação e validação
├── docs/        # Arquitetura e documentação do banco
├── legacy/      # Arquivos históricos que não devem ser executados
├── tests/       # Verificações do schema e das regras
└── README.md

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
temperatura_min
data_criacao
id_lote

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

A precisão de milissegundos permite ordenar eventos próximos e controlar sincronizações realizadas pelos dispositivos.

Exemplos:

- `criado_em`;
- `atualizado_em`;
- `medido_em`;
- `recebido_em`;
- `finalizado_em`;
- `reaberto_em`.

### Datas sem horário

O tipo `DATE` deve ser utilizado somente quando o horário não possuir significado para a regra de negócio.

### Exibição

A API e o aplicativo são responsáveis por converter os valores UTC para o fuso horário do usuário. Inicialmente, o sistema utilizará `America/Sao_Paulo`.

### Leituras offline

A coleta deve registrar separadamente:

- `medido_em`: instante em que o dispositivo realizou a medição;
- `recebido_em`: instante em que a API recebeu a coleta.

Essa separação permite sincronizar dados atrasados sem alterar o momento original da medição.

### Finalização do lote

A finalização deve registrar um instante preciso em `finalizado_em`, permitindo comparar a finalização com o instante `medido_em` das coletas.

## Escopo de propriedade

A versão inicial do SmartMushroom atende uma única propriedade rural.

Não será criada uma entidade `propriedade` nesta etapa. Todas as salas, usuários, sensores, dispositivos e lotes pertencem implicitamente à mesma operação.

### Evolução futura

O suporte a múltiplas propriedades poderá ser introduzido por uma migration futura, adicionando a entidade `propriedade` e seus relacionamentos.

Essa possibilidade não deve aumentar a complexidade do modelo inicial.
