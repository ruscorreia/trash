r# ManAI Vim Plugin

Integração do ManAI com Vim/Neovim para consultas diretas no editor.

## 📦 Instalação

### Opção 1: vim-plug (Recomendado)
Adicione ao seu `.vimrc`/`init.vim`:
```vim
Plug 'ruscorreia/manai-vim-plugin'
```

### Opção 2: Script Automático
```bash
curl -sSL https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/install.sh | bash
```

## ⚙️ Configuração
```vim
" Exemplo mínimo
let g:manai_api_key = 'sua_chave'
let g:manai_language = 'pt'
```

## 🚀 Uso Básico
```vim
:ManAI "Explique o conceito de monad em Haskell"
```

## 📜 Licença
MIT