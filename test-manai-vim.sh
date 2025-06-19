#!/bin/bash

# Script de teste para o plugin Vim ManAI
# Testa a sintaxe e funcionalidades básicas

set -e

echo "======================================"
echo "  ManAI Vim Plugin - Teste de Sintaxe"
echo "======================================"
echo ""

# Verificar se Vim está instalado
if ! command -v vim &> /dev/null; then
    echo "❌ Vim não encontrado"
    exit 1
fi

echo "✅ Vim encontrado: $(vim --version | head -1)"

# Testar sintaxe do plugin
echo ""
echo "🔍 Testando sintaxe do plugin..."

# Criar ficheiro temporário de teste
cat > /tmp/test_manai.vim << 'EOF'
" Carregar plugin
source manai-vim-plugin-fixed.vim

" Testar comandos básicos
echo "Plugin carregado com sucesso"

" Verificar se comandos existem
if !exists(':ManAI')
    echoerr "Comando :ManAI não existe"
    cquit
endif

if !exists(':ManAIHelp')
    echoerr "Comando :ManAIHelp não existe"
    cquit
endif

echo "Todos os comandos existem"

" Testar configurações
if !exists('g:manai_language')
    echoerr "Configuração g:manai_language não existe"
    cquit
endif

echo "Configurações OK"

" Sair com sucesso
quit
EOF

# Executar teste
if vim -u NONE -N -e -s -S /tmp/test_manai.vim < /dev/null; then
    echo "✅ Sintaxe do plugin está correcta"
else
    echo "❌ Erro de sintaxe no plugin"
    exit 1
fi

# Limpar ficheiro temporário
rm -f /tmp/test_manai.vim

echo ""
echo "🎉 Todos os testes passaram!"
echo ""
echo "Para instalar o plugin:"
echo "1. Copie manai-vim-plugin-fixed.vim para ~/.vim/plugin/"
echo "2. Ou use um gestor de plugins como vim-plug"
echo ""
echo "Comandos disponíveis:"
echo "  :ManAI <pergunta>     - Fazer consulta"
echo "  :ManAIWord           - Consultar palavra sob cursor"
echo "  :ManAILine           - Consultar linha actual"
echo "  :ManAIHelp           - Mostrar ajuda"
echo ""

