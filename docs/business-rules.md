# Regras de negócio

Este documento registra as regras de negócio que devem ser respeitadas pela API e protegidas pelo banco de dados quando tecnicamente possível.

## RN-001 — Um lote ativo por sala

Cada sala pode possuir, no máximo, um lote com status `ativo`.

Uma sala pode manter vários lotes finalizados em seu histórico. A existência desses lotes não impede a criação de um novo lote ativo.

### Responsabilidades

- A API deve verificar a disponibilidade da sala e retornar uma resposta compreensível.
- O banco de dados deve impedir que dois lotes ativos sejam associados à mesma sala.
- A finalização de um lote deve liberar a sala para um novo lote.

### Exemplos

Situação válida:

- Sala 1 — Lote 10 — `finalizado`
- Sala 1 — Lote 15 — `finalizado`
- Sala 1 — Lote 20 — `ativo`

Situação inválida:

- Sala 1 — Lote 20 — `ativo`
- Sala 1 — Lote 21 — `ativo`

## RN-002 — Finalização e reabertura de lote

A finalização de um lote não exclui seus dados e pode ser desfeita.

Um lote finalizado pode ser reaberto somente quando sua sala não possuir outro lote ativo.

### Ao finalizar

- O status deve mudar de `ativo` para `finalizado`.
- A data de finalização deve ser registrada.
- O lote deve deixar de receber novas leituras e acionamentos.
- A ação deve ser registrada para auditoria.

### Ao reabrir

- O sistema deve verificar se a sala está disponível.
- O status deve voltar para `ativo`.
- A data de finalização deve voltar para `NULL`.
- O usuário deve confirmar a ação.
- O motivo da reabertura deve ser registrado.
- A ação deve ser registrada para auditoria.

### Proteções de interface

- A finalização deve exigir confirmação.
- O aplicativo deve oferecer a opção de desfazer imediatamente.
- A reabertura posterior deve utilizar uma ação separada e claramente identificada.

## RN-003 — Leituras atrasadas e sincronização offline

O sistema deve distinguir o momento em que uma leitura foi realizada do momento em que ela foi recebida pela API.

Uma leitura pode ser recebida depois da finalização do lote quando tiver sido realizada enquanto o lote ainda estava ativo.

### Regras

- Leituras realizadas enquanto o lote estava ativo podem ser armazenadas posteriormente.
- Leituras realizadas depois da finalização devem ser rejeitadas.
- Cada leitura enviada pelo dispositivo deve possuir um identificador único.
- O reenvio de uma leitura já armazenada não deve criar duplicidade.
- O momento original da medição deve ser preservado.
- O momento em que a API recebeu a leitura também deve ser registrado.

### Objetivo

Permitir que o ESP32 armazene leituras localmente durante falhas de conexão e faça a sincronização quando o servidor voltar, sem perda ou duplicação de dados.

## RN-004 — Mudança de fase e configuração do lote

Ao mudar a fase de cultivo de um lote, os parâmetros padrão da nova fase devem originar uma nova configuração para o lote.

A mudança de fase e a criação da configuração devem formar uma única operação.

### Regras

- A fase selecionada deve pertencer ao mesmo cogumelo cultivado no lote.
- A mudança deve criar um novo registro no histórico de fases.
- Os parâmetros padrão da nova fase devem ser copiados para uma nova configuração.
- O usuário pode ajustar os parâmetros antes de confirmar a mudança.
- Configurações anteriores devem permanecer preservadas.
- Se o registro da fase ou da configuração falhar, nenhuma das duas alterações deve ser confirmada.
- O histórico não deve ser reescrito ou excluído durante operações normais.

## RN-005 — Sensores e coletas ambientais

Cada sala pode possuir uma quantidade variável de sensores.

Os sensores A1, A2, A3, B1, B2 e B3 representam uma configuração possível, não colunas fixas do banco de dados.

### Sensores

- Cada sensor deve pertencer a uma sala.
- Cada sensor deve identificar o tipo de grandeza medida.
- O sensor pode representar um ponto no composto ou no ambiente.
- Um sensor pode ser desativado sem excluir suas leituras anteriores.
- Sensores desativados não devem receber novas leituras.

### Coletas

- Cada ciclo de medição realizado pelo dispositivo deve gerar uma coleta.
- A coleta deve pertencer a um lote.
- A coleta deve registrar o momento da medição e o momento do recebimento.
- Cada coleta deve possuir um identificador externo único para evitar duplicidade durante sincronizações.
- Uma coleta pode possuir várias leituras, uma para cada sensor utilizado.

### Leituras

- Cada leitura deve pertencer a uma coleta.
- Cada leitura deve pertencer ao sensor que produziu a medição.
- Cada leitura deve armazenar uma única grandeza e um único valor.
- O sensor utilizado deve pertencer à mesma sala do lote associado à coleta.

## RN-006 — Histórico de acionamento dos atuadores

Toda mudança de estado de um atuador deve gerar um registro histórico.

### Regras

- O registro deve identificar o atuador, o lote, o estado e o horário.
- A origem deve distinguir ação manual, automação online e controle local offline.
- Ações manuais devem registrar o usuário responsável.
- Ações automáticas devem manter o usuário como `NULL`.
- Quando disponível, deve ser registrado o motivo do acionamento.
- Eventos offline podem ser sincronizados posteriormente sem gerar duplicidade.
- Registros históricos de acionamento não devem ser alterados ou excluídos durante o uso normal.

## RN-007 — Exclusão e preservação de dados

Dados operacionais e históricos não devem ser excluídos fisicamente durante o uso normal do sistema.

### Regras

- Lotes devem ser finalizados ou arquivados, não excluídos.
- Sensores, atuadores, salas, cogumelos e fases podem ser desativados.
- A desativação não deve remover registros históricos relacionados.
- Leituras, coletas, configurações, mudanças de fase, acionamentos e auditorias devem ser preservados.
- Exclusões físicas devem existir somente para manutenção administrativa controlada ou dados fictícios.
- Uma exclusão física autorizada deve ser registrada para auditoria.

## RN-008 — Alertas

O sistema deve gerar alertas quando uma medição violar a configuração válida para o lote naquele momento.

### Regras

- O alerta deve identificar o lote, o sensor, a grandeza, o valor medido e o limite violado.
- Quando possível, o alerta deve referenciar a leitura que o originou.
- O alerta deve possuir os estados `aberto`, `reconhecido` e `resolvido`.
- O reconhecimento deve registrar o usuário e o horário.
- A resolução deve registrar quando a condição voltou ao normal ou foi encerrada manualmente.
- O sistema deve evitar vários alertas abertos para a mesma condição, sensor e lote.
- Alertas resolvidos devem permanecer no histórico.

## RN-009 — Usuários, permissões e auditoria

O sistema deve diferenciar usuários administradores de usuários operacionais.

### Administradores

Podem gerenciar usuários, salas, cogumelos, fases, sensores, atuadores e operações administrativas.

### Usuários operacionais

Podem acompanhar salas, operar lotes, ajustar parâmetros, controlar atuadores e reconhecer alertas conforme suas permissões.

### Auditoria

Devem ser registradas, no mínimo:

- criação, finalização e reabertura de lotes;
- mudança de fase;
- alteração de parâmetros;
- comandos manuais em atuadores;
- reconhecimento e resolução manual de alertas;
- alterações cadastrais relevantes;
- exclusões físicas administrativas.

Cada registro deve identificar a ação, o horário, a origem e o usuário responsável quando houver.

## RN-010 — Iluminação programada e acionamento temporário

A iluminação automática deve seguir o fotoperíodo definido na configuração vigente do lote.

### Fotoperíodo

- O fotoperíodo deve ser armazenado em minutos.
- A programação automática começa diariamente às 06:00 no horário da propriedade.
- O horário de término é calculado a partir da duração configurada.
- Uma fase com `fotoperiodo_minutos` igual a zero não recebe iluminação automática.
- Ao iniciar ou alterar uma fase, o fotoperíodo padrão deve ser copiado para a configuração do lote.
- Alterações no fotoperíodo devem gerar uma nova configuração, preservando o histórico.

### Acionamento manual

- Quando a iluminação programada estiver desligada, o produtor pode ligá-la manualmente.
- O acionamento manual deve ser temporário e não altera o fotoperíodo.
- O tempo padrão do acionamento manual é de 60 minutos.
- O usuário pode desligar a iluminação antes do encerramento do temporizador.
- O ESP32 deve controlar o desligamento localmente, inclusive durante falhas de conexão.
- O acionamento e o desligamento devem ser registrados no histórico dos atuadores.

### Evolução futura

Horários personalizados e programações diferentes por dia da semana poderão ser adicionados posteriormente, caso se tornem necessários.