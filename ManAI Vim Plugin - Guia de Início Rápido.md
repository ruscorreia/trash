# ManAI Vim Plugin - Guia de Início Rápido

## 🚀 Instalação em 30 Segundos

### Instalação Automática (Recomendada)

```bash
curl -fsSL https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/install.sh | bash
```

### Instalação Manual Rápida

#### Para Vim-Plug
Adicione ao seu `.vimrc`:
```vim
Plug 'ruscorreia/manai-vim-plugin'
```
Execute `:PlugInstall`

#### Para Vundle
Adicione ao seu `.vimrc`:
```vim
Plugin 'ruscorreia/manai-vim-plugin'
```
Execute `:PluginInstall`

## ⚡ Primeiros Passos

### 1. Verificar Instalação
```vim
:ManAIHelp
```

### 2. Primeira Consulta
```vim
:ManAI Como listar ficheiros?
```

### 3. Consultar Palavra Sob Cursor
Posicione o cursor sobre qualquer comando Linux e pressione:
```
<leader>ma
```

### 4. Consultar Linha Actual
```
<leader>ml
```

## 🎯 Comandos Essenciais

| Comando | Descrição | Exemplo |
|---------|-----------|---------|
| `:ManAI <pergunta>` | Consulta geral | `:ManAI Como usar grep?` |
| `:ManAIWord` | Consulta palavra sob cursor | Cursor em "chmod" + comando |
| `:ManAILine` | Consulta linha actual | Em linha com comando |
| `:ManAISelection` | Consulta texto seleccionado | Modo visual + comando |
| `:ManAIHistory` | Ver histórico | Lista consultas anteriores |
| `:ManAISnippets` | Ver snippets | Consultas pré-definidas |

## ⌨️ Mapeamentos de Teclado

| Tecla | Acção |
|-------|-------|
| `<leader>ma` | Consultar palavra |
| `<leader>ml` | Consultar linha |
| `<leader>ms` | Consultar selecção (visual) |

## 🔧 Configuração Básica

Adicione ao seu `.vimrc`:

```vim
" Idioma (pt, en, es, fr)
let g:manai_language = 'pt'

" Altura da janela de resultados
let g:manai_window_height = 15

" Fechar automaticamente
let g:manai_auto_close = 1

" Activar cache
let g:manai_cache_enabled = 1
```

## 📚 Snippets Úteis

```vim
:ManAISnippet find_files      " Como encontrar ficheiros
:ManAISnippet permissions     " Gestão de permissões
:ManAISnippet processes       " Gestão de processos
:ManAISnippet disk_space      " Verificar espaço em disco
:ManAISnippet network         " Configuração de rede
```

## 🎨 Casos de Uso Rápidos

### Desenvolvimento
```bash
# Cursor em qualquer comando e pressionar <leader>ma
rsync -avz source/ dest/
find . -name "*.py" -exec grep -l "import" {} \;
```

### Administração
```vim
:ManAI Como monitorizar CPU?
:ManAI Como configurar firewall?
:ManAI Como fazer backup de MySQL?
```

### Scripting
```bash
#!/bin/bash
# Seleccionar bloco e pressionar <leader>ms
for file in *.txt; do
    echo "Processing $file"
done
```

## 🔍 Funcionalidades Avançadas

### Histórico Inteligente
```vim
:ManAIHistory                 " Ver histórico
:ManAIHistorySelect 3         " Repetir consulta #3
```

### Modo Interactivo
```vim
:ManAIInteractive             " Activar sugestões automáticas
```

### Consultas Contextuais
```vim
:ManAIContext Como optimizar este script bash?
```

## 🛠️ Troubleshooting Rápido

### Plugin não funciona?
```vim
:echo exists('g:loaded_manai')    " Deve retornar 1
:ManAIConfig                      " Ver configuração
```

### Erro de conexão?
```vim
:ManAI teste                      " Testar API
```

### Respostas em inglês?
```vim
:let g:manai_language = 'pt'      " Forçar português
```

## 📖 Recursos Adicionais

- **Documentação Completa**: `:help manai`
- **Configuração Avançada**: Ver `manai-vim-config-examples.md`
- **GitHub**: https://github.com/ruscorreia/manai-vim-plugin

## 💡 Dicas Pro

1. **Use auto-completar**: `:ManAI <Tab>` para sugestões
2. **Combine com fzf**: Para pesquisa fuzzy no histórico
3. **Crie mapeamentos personalizados**: Para consultas frequentes
4. **Use snippets**: Para cenários comuns
5. **Active cache**: Para melhor performance

---

**🎉 Pronto! Agora tem o poder do ManAI directamente no seu Vim!**

Para ajuda: `:ManAIHelp` | Para configuração: `:ManAIConfig`

