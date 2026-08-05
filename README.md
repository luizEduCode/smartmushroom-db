# SmartMushroom — Banco de dados

Repositório responsável pela estrutura, pelo versionamento e pela documentação do banco de dados do SmartMushroom.

O banco oficial do projeto é o MySQL 8.4 LTS, executado localmente com Docker Compose.

## Tecnologias

- MySQL 8.4 LTS;
- Docker Desktop;
- Docker Compose;
- MySQL Workbench;
- SQL.

## Estrutura do repositório

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

## Pré-requisitos

Para executar o banco localmente, é necessário instalar:

- Docker Desktop com suporte ao WSL 2;
- MySQL Workbench, opcionalmente, para administração visual.

O cliente MySQL não precisa ser instalado diretamente no Windows.

## Configuração inicial

### 1. Clonar o repositório

```powershell
git clone https://github.com/luizEduCode/smartmushroom-db.git
cd smartmushroom-db
```

### 2. Criar o arquivo de ambiente

```powershell
Copy-Item .env.example .env
```

Abra o arquivo `.env` e substitua os valores demonstrativos por credenciais locais.

O arquivo `.env` contém informações sensíveis e não deve ser versionado.

### 3. Iniciar o MySQL

```powershell
docker compose up -d
```

Na primeira execução, o Docker baixa a imagem oficial do MySQL e cria o volume persistente do banco.

### 4. Verificar o ambiente

```powershell
docker compose ps
```

O serviço estará pronto quando a coluna `STATUS` apresentar `healthy`.

## Conexão local

Utilize os seguintes dados no MySQL Workbench ou na API:

```text
Host: 127.0.0.1
Porta: 3307
Banco: smartmushroom_db
Usuário: smartmushroom_app
Senha: valor definido em MYSQL_PASSWORD
```

O usuário `root` deve ser reservado para tarefas administrativas.

A porta `3307` permite que o MySQL 8.4 do projeto coexista temporariamente com o MariaDB legado na porta `3306`.

## Comandos principais

### Iniciar o ambiente

```powershell
docker compose up -d
```

### Consultar o estado

```powershell
docker compose ps
```

### Consultar os logs

```powershell
docker compose logs mysql
```

Para acompanhar os logs continuamente:

```powershell
docker compose logs -f mysql
```

### Parar os serviços

```powershell
docker compose stop
```

Esse comando preserva o contêiner e os dados.

### Iniciar serviços parados

```powershell
docker compose start
```

### Remover o contêiner

```powershell
docker compose down
```

Esse comando remove o contêiner e a rede, mas preserva o volume do banco.

### Remover também os dados locais

```powershell
docker compose down -v
```

> Atenção: a opção `-v` remove o volume e apaga todos os dados do banco local.

## MySQL Workbench

O MySQL Workbench é utilizado como cliente gráfico para:

- executar consultas;
- visualizar schemas e tabelas;
- inspecionar índices e relacionamentos;
- auxiliar na modelagem visual.

O Workbench não é a fonte oficial da estrutura. Toda alteração estrutural deve ser representada por uma migration versionada.

Versões atuais do Workbench podem apresentar um aviso de compatibilidade ao conectar no MySQL 8.4. As operações SQL utilizadas pelo projeto continuam disponíveis.

## Migrations

As migrations ficam na pasta `migrations/` e devem seguir o formato:

```text
YYYYMMDD_NNN_descricao.sql
```

Exemplo:

```text
20260805_001_criar_estrutura_inicial.sql
```

### Regras

- migrations devem ser executadas na ordem do nome do arquivo;
- uma migration publicada não deve ser alterada;
- correções devem ser feitas por uma nova migration;
- cada migration deve possuir uma responsabilidade clara;
- toda migration deve ser testada em um banco criado do zero antes do commit.

Os procedimentos automatizados para aplicação e validação das migrations serão adicionados à pasta `scripts/`.

## Seeds e fixtures

A pasta `seeds/` contém somente dados essenciais para o funcionamento do sistema.

A pasta `fixtures/` contém dados fictícios utilizados em desenvolvimento e testes.

Dados reais de produção não devem ser armazenados nessas pastas nem versionados no Git.

## API local

Nesta etapa, a API PHP continua sendo executada pelo Apache do XAMPP.

O banco utilizado pela API é o MySQL 8.4 executado pelo Docker. O módulo MySQL do XAMPP não faz parte do novo ambiente oficial.

A configuração local da API deverá utilizar a porta `3307` e as credenciais definidas no arquivo `.env` correspondente ao projeto da API.

## Documentação

A documentação do banco está disponível em:

- [`docs/architecture.md`](docs/architecture.md): decisões técnicas e organização do banco;
- [`docs/business-rules.md`](docs/business-rules.md): regras de negócio;
- [`docs/logical-model.md`](docs/logical-model.md): entidades, campos e relacionamentos;
- [`legacy/README.md`](legacy/README.md): origem e finalidade dos arquivos históricos.

## Segurança

- arquivos `.env` não devem ser versionados;
- credenciais reais não devem aparecer em documentação, commits ou capturas de tela;
- backups e dumps locais não devem ser enviados ao Git;
- a API deve utilizar o usuário da aplicação, não o usuário `root`;
- dados reais devem permanecer fora de seeds e fixtures.

## Situação atual

O ambiente MySQL 8.4 está configurado e validado.

A próxima etapa é implementar e testar a migration da estrutura inicial com base no modelo lógico documentado.