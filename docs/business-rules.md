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
- O instante da finalização deve ser registrado em `finalizado_em`.
- O lote não deve receber novas coletas ou acionamentos ocorridos depois de `finalizado_em`.
- Coletas e acionamentos ocorridos enquanto o lote estava ativo podem ser sincronizados posteriormente.
- A ação deve ser registrada para auditoria.

### Ao reabrir

- O sistema deve verificar se a sala está disponível.
- O status deve voltar para `ativo`.
- `finalizado_em` deve voltar para `NULL`.
- O usuário deve confirmar a ação.
- O motivo da reabertura deve ser registrado na auditoria.
- A ação deve ser registrada para auditoria.

### Proteções de interface

- A finalização deve exigir confirmação.
- O aplicativo deve oferecer a opção de desfazer imediatamente.
- A reabertura posterior deve utilizar uma ação separada e claramente identificada.

## RN-003 — Coletas atrasadas e sincronização offline

O sistema deve distinguir o momento em que uma coleta foi realizada do momento em que ela foi recebida pela API.

Uma coleta pode ser recebida depois da finalização do lote quando tiver sido realizada enquanto o lote ainda estava ativo.

### Regras

- `medido_em` deve representar o momento original da medição.
- `recebido_em` deve representar o momento em que a API recebeu a coleta.
- `medido_em` não pode ser anterior a `lote.iniciado_em`.
- Em lotes finalizados, `medido_em` não pode ser posterior a `lote.finalizado_em`.
- Coletas realizadas enquanto o lote estava ativo podem ser armazenadas posteriormente.
- Coletas realizadas depois da finalização devem ser rejeitadas.
- Cada coleta enviada pelo ESP32 deve possuir um `identificador_externo` único.
- O reenvio de uma coleta já armazenada não deve criar duplicidade.
- As leituras devem permanecer agrupadas na coleta correspondente.

### Objetivo

Permitir que o ESP32 armazene coletas localmente durante falhas de conexão e faça a sincronização quando o servidor voltar, sem perda ou duplicação de dados.

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
- Cada sensor deve representar uma única grandeza e uma única localização.
- Um equipamento físico capaz de medir mais de uma grandeza deve ser representado por mais de um sensor lógico.
- Um DHT22 deve ser representado por um sensor lógico de temperatura e outro de umidade.
- A localização `composto` somente pode ser utilizada com a grandeza `temperatura` nesta primeira versão.
- A grandeza `co2` somente pode utilizar a localização `ambiente` nesta primeira versão.
- Sensores com localização `externo` são observacionais e não geram alertas baseados nos limites da configuração do lote.
- Um sensor pode ser desativado sem excluir suas leituras anteriores.
- Sensores desativados não devem receber novas leituras.

### Coletas

- Cada ciclo de medição realizado pelo ESP32 deve gerar uma coleta.
- A coleta deve pertencer a um lote.
- A coleta deve registrar o momento da medição e o momento do recebimento.
- Cada coleta deve possuir um identificador externo único para evitar duplicidade durante sincronizações.
- Uma coleta pode possuir várias leituras, uma para cada sensor utilizado.

### Leituras

- Cada leitura deve pertencer a uma coleta.
- Cada leitura deve pertencer ao sensor que produziu a medição.
- Cada leitura deve armazenar um único valor.
- Uma coleta pode possuir no máximo uma leitura por sensor.
- O sensor utilizado deve pertencer à mesma sala do lote associado à coleta.
- Valores inválidos de hardware, como `NaN`, não devem ser armazenados.

## RN-006 — Comandos e histórico dos atuadores

Todo comando ou acionamento local de um atuador deve gerar um registro em `controle_atuador`.

O sistema deve distinguir um comando solicitado do estado efetivamente aplicado ao equipamento.

### Regras

- O registro deve identificar o atuador, o estado e os instantes relacionados à operação.
- O lote pode ser registrado quando o acionamento estiver relacionado a um cultivo ativo.
- A origem deve distinguir ação manual, automação online e automação local.
- Ações manuais devem registrar o usuário responsável.
- Ações automáticas devem manter o usuário como `NULL`.
- Quando disponível, deve ser registrado o motivo do acionamento.
- Cada registro deve possuir um `identificador_externo` único.
- Eventos offline podem ser sincronizados posteriormente sem gerar duplicidade.
- Comandos criados pela API devem iniciar com `status_execucao` igual a `pendente`.
- Ações realizadas localmente pelo ESP32 podem ser registradas diretamente como `aplicado`.
- O ESP32 deve atualizar o comando para `aplicado` quando confirmar sua execução.
- Um comando que não puder ser executado deve assumir o estado `falhou`.
- `aplicado_em` deve ser preenchido quando `status_execucao` for `aplicado`.
- O estado efetivo do atuador deve considerar somente registros com `status_execucao` igual a `aplicado`.
- O estado efetivo deve ser obtido pelo registro mais recente, ordenado por `aplicado_em` e `id_controle_atuador`.
- Depois da criação, somente `status_execucao` e `aplicado_em` podem ser atualizados.
- Os demais dados do registro não devem ser alterados ou excluídos durante o uso normal.

## RN-007 — Exclusão e preservação de dados

Dados operacionais e históricos não devem ser excluídos fisicamente durante o uso normal do sistema.

### Regras

- Lotes devem ser finalizados, não excluídos.
- Sensores, atuadores, salas, cogumelos e fases podem ser desativados.
- A desativação não deve remover registros históricos relacionados.
- Leituras, coletas, configurações, mudanças de fase, controles de atuadores, alertas e auditorias devem ser preservados.
- A atualização controlada de `status_execucao` e `aplicado_em` não deve alterar os dados originais do comando.
- Alterações no estado de um alerta não devem apagar seu histórico.
- Exclusões físicas devem existir somente para manutenção administrativa controlada ou dados fictícios.
- Uma exclusão física autorizada deve ser registrada para auditoria.

## RN-008 — Alertas

O sistema deve gerar alertas quando uma medição violar a configuração válida para o lote naquele momento ou quando ocorrer uma falha operacional monitorada.

### Tipos de condição

Os alertas podem representar:

- temperatura abaixo do limite;
- temperatura acima do limite;
- umidade abaixo do limite;
- umidade acima do limite;
- CO₂ acima do limite;
- falha de sensor;
- falha de atuador;
- falha de comunicação;
- outra condição prevista pela aplicação.

### Regras

- O alerta deve identificar o lote e o tipo da condição.
- Quando aplicável, o alerta deve identificar o sensor, o atuador e a leitura relacionados.
- O alerta deve registrar o valor observado e o limite de referência quando essas informações existirem.
- O alerta deve possuir severidade `aviso` ou `critico`.
- O alerta deve possuir os estados `aberto`, `reconhecido` e `resolvido`.
- O reconhecimento deve registrar o usuário e o horário.
- Reconhecer um alerta não significa que a condição foi resolvida.
- Alertas ambientais devem ser resolvidos automaticamente quando a condição voltar aos limites permitidos.
- Uma resolução manual deve registrar o usuário responsável.
- O sistema deve evitar vários alertas `aberto` ou `reconhecido` para a mesma combinação de lote, tipo, sensor e atuador.
- Sensores externos não devem gerar alertas baseados nos limites da configuração do lote.
- Alertas de tipos diferentes podem estar relacionados à mesma leitura.
- Alertas resolvidos devem permanecer no histórico.

## RN-009 — Usuários, permissões e auditoria

O sistema deve diferenciar usuários com perfil `administrador` de usuários com perfil `operador`.

### Administradores

Podem gerenciar usuários, salas, cogumelos, fases, sensores, atuadores e operações administrativas.

### Operadores

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

Comandos manuais devem ser auditados mesmo quando também estiverem registrados em `controle_atuador`, pois representam uma ação humana.

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