#!/bin/bash

# ManAI Vim Plugin - Script de Instalação
# Versão: 1.0.0
# Autor: EduTech Angola

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
PLUGIN_NAME="manai-vim"
PLUGIN_DIR="$HOME/.vim/pack/manai/start/manai-vim"
NVIM_PLUGIN_DIR="$HOME/.config/nvim/pack/manai/start/manai-vim"
VIMRC="$HOME/.vimrc"
NVIM_CONFIG="$HOME/.config/nvim/init.vim"

# URLs dos ficheiros
BASE_URL="https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main"
PLUGIN_FILE="manai-vim-plugin.vim"
ADVANCED_FILE="manai-vim-advanced.vim"

# Função para logging
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Função para detectar o editor
detect_editor() {
    if command -v nvim &> /dev/null; then
        echo "neovim"
    elif command -v vim &> /dev/null; then
        echo "vim"
    else
        error "Nem Vim nem Neovim encontrados no sistema"
    fi
}

# Função para detectar gestor de plugins
detect_plugin_manager() {
    local config_file="$1"
    
    if [ -f "$config_file" ]; then
        if grep -q "Plug " "$config_file"; then
            echo "vim-plug"
        elif grep -q "Plugin " "$config_file"; then
            echo "vundle"
        elif grep -q "call dein#" "$config_file"; then
            echo "dein"
        elif grep -q "use " "$config_file" && grep -q "packer" "$config_file"; then
            echo "packer"
        else
            echo "manual"
        fi
    else
        echo "manual"
    fi
}

# Função para verificar dependências
check_dependencies() {
    log "Verificando dependências..."
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        error "Python 3 não encontrado. Por favor, instale Python 3"
    fi
    
    # Verificar curl ou wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        error "curl ou wget necessário para download. Por favor, instale um deles"
    fi
    
    # Verificar editor
    local editor=$(detect_editor)
    info "Editor detectado: $editor"
    
    # Verificar se o Vim tem suporte a Python
    if [ "$editor" = "vim" ]; then
        if ! vim --version | grep -q "+python3"; then
            warning "Vim sem suporte Python3. Algumas funcionalidades podem não funcionar"
        fi
    fi
    
    info "Dependências verificadas"
}

# Função para download de ficheiros
download_file() {
    local url="$1"
    local output="$2"
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$output"
    else
        error "Não foi possível fazer download do ficheiro"
    fi
}

# Função para instalação manual
install_manual() {
    local editor="$1"
    local plugin_dir
    
    if [ "$editor" = "neovim" ]; then
        plugin_dir="$NVIM_PLUGIN_DIR"
    else
        plugin_dir="$PLUGIN_DIR"
    fi
    
    log "Instalando plugin manualmente em $plugin_dir"
    
    # Criar directório
    mkdir -p "$plugin_dir"
    
    # Copiar ficheiros do plugin
    if [ -f "manai-vim-plugin.vim" ]; then
        cp "manai-vim-plugin.vim" "$plugin_dir/plugin/"
        cp "manai-vim-advanced.vim" "$plugin_dir/plugin/"
    else
        # Download dos ficheiros
        mkdir -p "$plugin_dir/plugin"
        download_file "$BASE_URL/$PLUGIN_FILE" "$plugin_dir/plugin/$PLUGIN_FILE"
        download_file "$BASE_URL/$ADVANCED_FILE" "$plugin_dir/plugin/$ADVANCED_FILE"
    fi
    
    info "Plugin instalado em $plugin_dir"
}

# Função para instalação com vim-plug
install_vim_plug() {
    local config_file="$1"
    
    log "Configurando para vim-plug"
    
    # Verificar se já está configurado
    if grep -q "manai-vim" "$config_file"; then
        warning "Plugin ManAI já configurado no $config_file"
        return
    fi
    
    # Adicionar configuração
    cat >> "$config_file" << 'EOF'

" ManAI Plugin Configuration
Plug 'edutech-angola/manai-vim-plugin'

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1

EOF
    
    info "Configuração adicionada ao $config_file"
    info "Execute :PlugInstall no Vim para instalar"
}

# Função para instalação com Vundle
install_vundle() {
    local config_file="$1"
    
    log "Configurando para Vundle"
    
    if grep -q "manai-vim" "$config_file"; then
        warning "Plugin ManAI já configurado no $config_file"
        return
    fi
    
    cat >> "$config_file" << 'EOF'

" ManAI Plugin Configuration
Plugin 'edutech-angola/manai-vim-plugin'

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1

EOF
    
    info "Configuração adicionada ao $config_file"
    info "Execute :PluginInstall no Vim para instalar"
}

# Função para criar configuração básica
create_basic_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        log "Criando configuração básica em $config_file"
        
        cat > "$config_file" << 'EOF'
" Configuração básica do Vim/Neovim

" Configurações gerais
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase

" Configurações do ManAI Plugin
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
let g:manai_cache_enabled = 1


EOF
    else
        # Adicionar apenas configurações do ManAI
        if ! grep -q "manai" "$config_file"; then
            cat >> "$config_file" << 'EOF'

" Configurações do ManAI Plugin
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
let g:manai_cache_enabled = 1


EOF
        fi
    fi
    
    info "Configuração criada/actualizada"
}

# Função para instalar cliente Python
install_python_client() {
    log "Configurando cliente Python ManAI..."
    
    # Criar directório para o cliente
    local client_dir="$HOME/.local/bin"
    mkdir -p "$client_dir"
    
    # Criar script cliente Python
    cat > "$client_dir/manai-client.py" << 'EOF'
#!/usr/bin/env python3
"""
ManAI Client - Cliente Python para integração com Vim
"""

import sys
import json
import urllib.request
import urllib.parse
import argparse

class ManAIClient:
    def __init__(self, api_url=None, function_key=None, language='pt'):
        self.api_url = api_url or 'https://manai-agent-function-app.azurewebsites.net/api/ManaiAgentHttpTrigger'
        self.function_key = function_key or '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA=='
        self.language = language
    
    def query(self, question):
        """Fazer consulta ao ManAI"""
        headers = {
            'Content-Type': 'application/json',
            'x-functions-key': self.function_key
        }
        
        data = {
            'message': question,
            'language': self.language
        }
        
        try:
            req = urllib.request.Request(
                self.api_url,
                data=json.dumps(data).encode('utf-8'),
                headers=headers,
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode('utf-8'))
                return result.get('response', 'Sem resposta')
        
        except Exception as e:
            return f'Erro: {str(e)}'

def main():
    parser = argparse.ArgumentParser(description='ManAI Client para Vim')
    parser.add_argument('question', help='Pergunta para o ManAI')
    parser.add_argument('--language', '-l', default='pt', help='Idioma (pt, en, es, fr)')
    parser.add_argument('--url', help='URL da API personalizada')
    parser.add_argument('--key', help='Chave da função personalizada')
    
    args = parser.parse_args()
    
    client = ManAIClient(
        api_url=args.url,
        function_key=args.key,
        language=args.language
    )
    
    response = client.query(args.question)
    print(response)

if __name__ == '__main__':
    main()
EOF
    
    chmod +x "$client_dir/manai-client.py"
    
    # Criar link simbólico
    if [ -w "/usr/local/bin" ]; then
        ln -sf "$client_dir/manai-client.py" "/usr/local/bin/manai-client"
    else
        # Adicionar ao PATH do utilizador
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        info "Adicionado $client_dir ao PATH. Reinicie o terminal ou execute: source ~/.bashrc"
    fi
    
    info "Cliente Python instalado em $client_dir/manai-client.py"
}

# Função para testar instalação
test_installation() {
    log "Testando instalação..."
    
    local editor=$(detect_editor)
    
    # Testar se o plugin carrega
    if [ "$editor" = "neovim" ]; then
        nvim -c "echo 'Testando ManAI Plugin...'" -c "ManAIHelp" -c "q" 2>/dev/null || warning "Teste do plugin falhou"
    else
        vim -c "echo 'Testando ManAI Plugin...'" -c "ManAIHelp" -c "q" 2>/dev/null || warning "Teste do plugin falhou"
    fi
    
    info "Teste concluído"
}

# Função para mostrar instruções pós-instalação
show_post_install() {
    echo ""
    log "🎉 Instalação do ManAI Vim Plugin concluída!"
    echo ""
    echo "📋 Comandos disponíveis:"
    echo "  :ManAI <pergunta>     - Fazer pergunta ao ManAI"
    echo "  :ManAIWord           - Consultar palavra sob cursor"
    echo "  :ManAILine           - Consultar linha actual"
    echo "  :ManAIHelp           - Mostrar ajuda"
    echo ""
    echo "⌨️  Mapeamentos padrão:"
    echo "  <leader>ma           - Consultar palavra sob cursor"
    echo "  <leader>ml           - Consultar linha actual"
    echo "  <leader>mh           - Mostrar ajuda"
    echo ""
    echo "🔧 Para personalizar, edite o seu .vimrc/.config/nvim/init.vim"
    echo ""
    info "Reinicie o Vim/Neovim para começar a usar o ManAI!"
}

# Função principal
main() {
    echo "======================================"
    echo "  ManAI Vim Plugin - Instalador      "
    echo "======================================"
    echo ""
    
    # Verificar dependências
    check_dependencies
    
    # Detectar editor e configuração
    local editor=$(detect_editor)
    local config_file
    local plugin_manager
    
    if [ "$editor" = "neovim" ]; then
        config_file="$NVIM_CONFIG"
        # Verificar também init.lua
        if [ -f "$HOME/.config/nvim/init.lua" ]; then
            config_file="$HOME/.config/nvim/init.lua"
        fi
    else
        config_file="$VIMRC"
    fi
    
    plugin_manager=$(detect_plugin_manager "$config_file")
    info "Gestor de plugins detectado: $plugin_manager"
    
    # Instalar baseado no gestor de plugins
    case "$plugin_manager" in
        "vim-plug")
            install_vim_plug "$config_file"
            ;;
        "vundle")
            install_vundle "$config_file"
            ;;
        "manual"|*)
            install_manual "$editor"
            create_basic_config "$config_file"
            ;;
    esac
    
    # Instalar cliente Python
    install_python_client
    
    # Testar instalação
    test_installation
    
    # Mostrar instruções
    show_post_install
}

# Executar instalador
main "$@"

