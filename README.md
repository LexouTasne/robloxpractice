# MainUI

Hub de interface (GUI) para Roblox com abas laterais e controles personalizáveis.

Criado como script executável em um executor/exploit de client.

## Funcionalidades

- Botão flutuante circular para abrir/fechar o hub
- 3 abas no menu lateral:
  - **Main** — Campo de visão (FOV) + restaurar padrões
  - **Pulo** — JumpPower personalizado, pulo infinito
  - **Velocidade** — WalkSpeed personalizado
- Controles com suporte a mouse e toque
- Janela arrastável
- Configurações reaplicadas após o personagem renascer

## Como usar

1. Abra o jogo no Roblox.
2. Sincronize o executor com o Roblox (attach/inject).
3. Copie o conteúdo de `MainUI.lua` e cole no campo de input do executor.
4. Pressione Executar.

## Estrutura

- `MainUI.lua` — script principal (LocalScript para executor)

## Arquivos

- `MainUI.lua` — código principal do hub
- `README.md` — este arquivo

## Aviso

Este script altera valores de personagem e câmera no lado do cliente. Use por sua própria conta e risco.
