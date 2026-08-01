# Histórico do banco de dados

Esta pasta preserva versões anteriores do banco de dados do SmartMushroom para fins de consulta, auditoria e reconstrução histórica.

Os arquivos deste diretório não devem ser executados automaticamente em ambientes de desenvolvimento, teste ou produção.

## Diretórios

### `original-2025`

Contém os arquivos originalmente versionados no repositório:

- migration inicial;
- dados demonstrativos;
- diagrama MER original.

Essa versão preserva relacionamentos que foram planejados antes da reconstrução do banco.

### `reconstruction-2025`

Contém os scripts utilizados para reconstruir o banco após a corrupção do ambiente anterior:

- criação das tabelas;
- população do banco;
- procedure de geração de leituras fictícias.

Esses arquivos representam uma recuperação emergencial e não uma migration canônica.

### `runtime-snapshot-2026`

Contém a exportação somente da estrutura encontrada no MariaDB 10.4.32 em 1º de agosto de 2026.

Esse snapshot registra o estado executado naquele momento e serve para comparação durante a migração para MySQL 8.4 LTS.

## Aviso

Os arquivos legados podem conter dados fictícios, credenciais demonstrativas, estruturas incompletas e regras incompatíveis com a arquitetura atual.

A fonte oficial do banco será mantida fora deste diretório, por meio das migrations e seeds vigentes.