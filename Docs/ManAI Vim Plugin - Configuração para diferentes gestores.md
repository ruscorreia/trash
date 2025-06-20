# ManAI Vim Plugin - Configuração para diferentes gestores

## Vim-Plug

Adicione ao seu `.vimrc` ou `~/.config/nvim/init.vim`:

```vim
call plug#begin('~/.vim/plugged')

" ManAI Plugin
Plug 'ruscorreia/manai-vim-plugin'

call plug#end()

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
let g:manai_cache_enabled = 1

```

Depois execute `:PlugInstall` no Vim.

## Vundle

Adicione ao seu `.vimrc`:

```vim
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ruscorreia/manai-vim-plugin'

call vundle#end()
filetype plugin indent on

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
```

Execute `:PluginInstall` no Vim.

## Pathogen

```bash
cd ~/.vim/bundle
git clone https://github.com/ruscorreia/manai-vim-plugin.git
```

## Dein.vim

Adicione ao seu `init.vim`:

```vim
call dein#add('ruscorreia/manai-vim-plugin')
```

## Packer.nvim (Neovim)

Adicione ao seu `init.lua`:

```lua
use {
  'ruscorreia/manai-vim-plugin',
  config = function()
    vim.g.manai_language = 'pt'
    vim.g.manai_window_height = 15
    vim.g.manai_auto_close = 1
  end
}
```

## Instalação Manual

### Para Vim:
```bash
mkdir -p ~/.vim/pack/manai/start/manai-vim/plugin
cd ~/.vim/pack/manai/start/manai-vim/plugin
wget https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/plugin/manai.vim
```

### Para Neovim:
```bash
mkdir -p ~/.config/nvim/pack/manai/start/manai-vim/plugin
cd ~/.config/nvim/pack/manai/start/manai-vim/plugin
wget https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/plugin/manai.vim
```

## Configurações Avançadas

### Personalizar URL da API
```vim
let g:api_url = 'https://sua-api.exemplo.com/api/ManaiAgentHttpTrigger'
let g:manai_function_key = 'sua-chave-personalizada'
```

### Personalizar idioma
```vim
let g:manai_language = 'en'  " inglês
let g:manai_language = 'es'  " espanhol
let g:manai_language = 'fr'  " francês
```

### Desabilitar mapeamentos padrão
```vim
let g:manai_no_mappings = 1
let g:manai_no_advanced_mappings = 1
```

### Configurar cache
```vim
let g:manai_cache_enabled = 1
let g:manai_cache_size = 100
```

### Personalizar janela
```vim
let g:manai_window_height = 20
let g:manai_auto_close = 0  " não fechar automaticamente
```

## Mapeamentos Personalizados

```vim
" Consultas rápidas
nnoremap <leader>mf :ManAI Como encontrar ficheiros?<CR>
nnoremap <leader>mp :ManAI Como ver processos?<CR>
nnoremap <leader>md :ManAI Como ver espaço em disco?<CR>

" Consulta contextual baseada no tipo de ficheiro
autocmd FileType sh nnoremap <buffer> <leader>mh :ManAIContext Como melhorar este script bash?<CR>
autocmd FileType python nnoremap <buffer> <leader>mh :ManAIContext Como executar este código Python no Linux?<CR>

" Consulta da palavra sob cursor com contexto
nnoremap <leader>mc :execute 'ManAI Como usar ' . expand('<cword>') . ' no contexto de ' . &filetype . '?'<CR>
```

## Integração com outros plugins

### Com fzf.vim
```vim
function! ManAIFzfHistory()
    call fzf#run({
        \ 'source': readfile(expand('~/.vim_manai_history')),
        \ 'sink': function('s:ManaiQuery'),
        \ 'options': '--prompt="ManAI> "'
    \ })
endfunction

command! ManAIFzf call ManAIFzfHistory()
```

### Com airline/lightline
```vim
" Mostrar status do ManAI na statusline
let g:airline_section_x = '%{ManAIStatus()}'

function! ManAIStatus()
    if exists('g:manai_last_query_time')
        return 'ManAI: ' . strftime('%H:%M', g:manai_last_query_time)
    endif
    return ''
endfunction
```

### Com which-key.nvim
```lua
local wk = require("which-key")
wk.register({
  m = {
    name = "ManAI",
    a = { ":ManAIWord<CR>", "Query word" },
    l = { ":ManAILine<CR>", "Query line" },
    h = { ":ManAIHelp<CR>", "Help" },
    s = { ":ManAISnippets<CR>", "Snippets" },
    H = { ":ManAIHistory<CR>", "History" },
  },
}, { prefix = "<leader>" })
```

