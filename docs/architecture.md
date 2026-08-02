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