# ManAI Vim Plugin - Guia Completo de Desinstalação e Reinstalação

## 🗑️ **DESINSTALAÇÃO COMPLETA DA VERSÃO ANTERIOR**

### **1. Identificar Método de Instalação Anterior**

Primeiro, precisa identificar como instalou o plugin anteriormente:

```bash
# Verificar se existe em directórios padrão
ls -la ~/.vim/plugin/ | grep -i manai
ls -la ~/.config/nvim/plugin/ | grep -i manai

# Verificar gestores de plugins
grep -i manai ~/.vimrc ~/.config/nvim/init.vim 2>/dev/null || echo "Não encontrado em configs"
```

### **2. Desinstalação por Método**

#### **A) Se instalou manualmente:**

```bash
# Vim
rm -f ~/.vim/plugin/manai*.vim
rm -f ~/.vim/autoload/manai*.vim
rm -f ~/.vim/doc/manai*.txt

# Neovim
rm -f ~/.config/nvim/plugin/manai*.vim
rm -f ~/.config/nvim/autoload/manai*.vim
rm -f ~/.config/nvim/doc/manai*.txt

# Verificar outros locais possíveis
find ~ -name "*manai*" -type f 2>/dev/null | grep -E "\.(vim|txt)$"
```

#### **B) Se usou vim-plug:**

1. **Remover do ficheiro de configuração:**
```vim
" Comentar ou remover esta linha do ~/.vimrc ou ~/.config/nvim/init.vim
" Plug 'ruscorreia/manai-vim-plugin'
```

2. **Executar limpeza no Vim:**
```vim
:PlugClean
```

3. **Confirmar remoção quando perguntado**

#### **C) Se usou Vundle:**

1. **Remover do ficheiro de configuração:**
```vim
" Comentar ou remover esta linha do ~/.vimrc
" Plugin 'ruscorreia/manai-vim-plugin'
```

2. **Executar limpeza no Vim:**
```vim
:PluginClean
```

#### **D) Se usou Pathogen:**

```bash
# Remover directório do plugin
rm -rf ~/.vim/bundle/manai-vim-plugin
rm -rf ~/.vim/bundle/manai*
```

#### **E) Se usou Dein:**

1. **Remover do ficheiro de configuração:**
```vim
" Comentar ou remover esta linha
" call dein#add('ruscorreia/manai-vim-plugin')
```

2. **Executar limpeza no Vim:**
```vim
:call dein#recache_runtimepath()
```

#### **F) Se usou Packer (Neovim):**

1. **Remover do ficheiro de configuração:**
```lua
-- Comentar ou remover esta linha
-- use 'ruscorreia/manai-vim-plugin'
```

2. **Executar limpeza no Neovim:**
```vim
:PackerClean
```

### **3. Limpeza de Dados e Cache**

```bash
# Remover cache e dados do ManAI
rm -rf ~/.cache/manai-vim/
rm -rf ~/.local/share/manai-vim/
rm -rf ~/.config/manai-vim/

# Verificar se existem outros directórios relacionados
find ~ -name "*manai*" -type d 2>/dev/null
```

### **4. Limpeza de Configurações**

```bash
# Fazer backup das configurações actuais
cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d)
cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.backup.$(date +%Y%m%d) 2>/dev/null || true

# Remover configurações do ManAI dos ficheiros
sed -i '/manai/Id' ~/.vimrc 2>/dev/null || true
sed -i '/ManAI/Id' ~/.vimrc 2>/dev/null || true
sed -i '/manai/Id' ~/.config/nvim/init.vim 2>/dev/null || true
sed -i '/ManAI/Id' ~/.config/nvim/init.vim 2>/dev/null || true
```

### **5. Verificação de Limpeza Completa**

```bash
# Script de verificação
echo "=== Verificação de Limpeza ManAI ==="
echo ""

# Verificar ficheiros
echo "🔍 Procurando ficheiros restantes..."
manai_files=$(find ~ -name "*manai*" -type f 2>/dev/null | grep -v backup || true)
if [ -z "$manai_files" ]; then
    echo "✅ Nenhum ficheiro ManAI encontrado"
else
    echo "⚠️  Ficheiros encontrados:"
    echo "$manai_files"
fi

# Verificar directórios
echo ""
echo "🔍 Procurando directórios restantes..."
manai_dirs=$(find ~ -name "*manai*" -type d 2>/dev/null || true)
if [ -z "$manai_dirs" ]; then
    echo "✅ Nenhum directório ManAI encontrado"
else
    echo "⚠️  Directórios encontrados:"
    echo "$manai_dirs"
fi

# Verificar configurações
echo ""
echo "🔍 Verificando configurações..."
config_refs=$(grep -i manai ~/.vimrc ~/.config/nvim/init.vim 2>/dev/null || true)
if [ -z "$config_refs" ]; then
    echo "✅ Nenhuma referência ManAI nas configurações"
else
    echo "⚠️  Referências encontradas:"
    echo "$config_refs"
fi

echo ""
echo "=== Verificação Concluída ==="
```

## 🚀 **INSTALAÇÃO DA VERSÃO CORRIGIDA**

### **Método Recomendado: vim-plug**

1. **Instalar vim-plug se não tiver:**
```bash
# Para Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Para Neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

2. **Adicionar ao ficheiro de configuração:**

**Para Vim (~/.vimrc):**
```vim
call plug#begin('~/.vim/plugged')

" ManAI Vim Plugin
Plug 'ruscorreia/manai-vim-plugin'

call plug#end()

" Configurações opcionais do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
```

**Para Neovim (~/.config/nvim/init.vim):**
```vim
call plug#begin('~/.local/share/nvim/plugged')

" ManAI Vim Plugin
Plug 'ruscorreia/manai-vim-plugin'

call plug#end()

" Configurações opcionais do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
```

3. **Instalar o plugin:**
```vim
:PlugInstall
```

### **Instalação Manual (Temporária)**

Se quiser testar a versão corrigida imediatamente:

```bash
# Criar directório se não existir
mkdir -p ~/.vim/plugin

# Copiar versão corrigida
cp manai-vim-plugin.vim ~/.vim/plugin/manai.vim

# Para Neovim
mkdir -p ~/.config/nvim/plugin
cp manai-vim-plugin.vim ~/.config/nvim/plugin/manai.vim
```

### **Configuração Inicial**

Adicionar ao ~/.vimrc ou ~/.config/nvim/init.vim:

```vim
" === ManAI Vim Plugin Configuração ===

" Configurações básicas
let g:manai_language = 'pt'              " Idioma das respostas
let g:manai_window_height = 15           " Altura da janela de resposta
let g:manai_auto_close = 1               " Fechar janela automaticamente
let g:manai_cache_enabled = 1            " Activar cache
let g:manai_timeout = 30                 " Timeout em segundos

" Configurações avançadas (opcionais)
let g:api_url = 'https://manai-agent-function-app.azurewebsites.net/api/ManaiAgentHttpTrigger'
let g:manai_function_key = '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA=='

" Mapeamentos personalizados (opcionais)
" Desactivar mapeamentos padrão se quiser personalizar
" let g:manai_no_default_mappings = 1

" Mapeamentos personalizados
nnoremap <leader>ma :ManAIWord<CR>
nnoremap <leader>ml :ManAILine<CR>
vnoremap <leader>ms :ManAISelection<CR>
nnoremap <leader>mh :ManAIHelp<CR>
nnoremap <leader>mc :ManAIClearCache<CR>
nnoremap <leader>mH :ManAIHistory<CR>
```

## 🧪 **TESTE DA INSTALAÇÃO**

```bash
# Executar teste de sintaxe
./test-manai-vim.sh

# Ou testar manualmente no Vim
vim -c ":ManAIHelp" -c "q"
```

## 🔧 **SCRIPT AUTOMATIZADO DE DESINSTALAÇÃO**

```bash
#!/bin/bash
# uninstall-manai-vim.sh

echo "======================================"
echo "  ManAI Vim Plugin - Desinstalação   "
echo "======================================"
echo ""

# Fazer backup das configurações
echo "📋 Fazendo backup das configurações..."
[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d)
[ -f ~/.config/nvim/init.vim ] && cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.backup.$(date +%Y%m%d)

# Remover ficheiros do plugin
echo "🗑️  Removendo ficheiros do plugin..."
rm -f ~/.vim/plugin/manai*.vim
rm -f ~/.vim/autoload/manai*.vim
rm -f ~/.vim/doc/manai*.txt
rm -f ~/.config/nvim/plugin/manai*.vim
rm -f ~/.config/nvim/autoload/manai*.vim
rm -f ~/.config/nvim/doc/manai*.txt

# Remover directórios de gestores de plugins
echo "📦 Removendo de gestores de plugins..."
rm -rf ~/.vim/bundle/manai*
rm -rf ~/.vim/plugged/manai*
rm -rf ~/.local/share/nvim/plugged/manai*

# Limpar cache e dados
echo "🧹 Limpando cache e dados..."
rm -rf ~/.cache/manai-vim/
rm -rf ~/.local/share/manai-vim/
rm -rf ~/.config/manai-vim/

# Remover configurações dos ficheiros
echo "⚙️  Removendo configurações..."
if [ -f ~/.vimrc ]; then
    sed -i.bak '/manai/Id; /ManAI/Id' ~/.vimrc
fi
if [ -f ~/.config/nvim/init.vim ]; then
    sed -i.bak '/manai/Id; /ManAI/Id' ~/.config/nvim/init.vim
fi

echo ""
echo "✅ Desinstalação concluída!"
echo ""
echo "📋 Backups criados:"
echo "   ~/.vimrc.backup.$(date +%Y%m%d)"
echo "   ~/.config/nvim/init.vim.backup.$(date +%Y%m%d)"
echo ""
echo "Para reinstalar a versão corrigida:"
echo "   1. Adicione 'Plug \"ruscorreia/manai-vim-plugin\"' ao seu .vimrc"
echo "   2. Execute :PlugInstall no Vim"
echo ""
```

## 📝 **RESUMO DOS PASSOS**

1. **Identificar** método de instalação anterior
2. **Desinstalar** usando método apropriado
3. **Limpar** cache e configurações
4. **Verificar** limpeza completa
5. **Instalar** versão corrigida
6. **Configurar** conforme necessário
7. **Testar** funcionalidade

## ⚠️ **NOTAS IMPORTANTES**

- **Sempre faça backup** das configurações antes de desinstalar
- **Verifique** se a limpeza foi completa antes de reinstalar
- **Use vim-plug** para gestão automática de plugins
- **Teste** a instalação após completar o processo

Com este guia, conseguirá remover completamente a versão anterior e instalar a versão corrigida sem conflitos!

