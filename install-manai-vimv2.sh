#!/bin/bash

# ManAI Vim Plugin - Script de Instalação da Versão Corrigida
# Instala a versão corrigida do plugin após desinstalação

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Funções de logging
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${PURPLE}[SUCCESS] $1${NC}"; }

# Verificar se ficheiro corrigido existe
if [ ! -f "manai-vim-plugin-fixed.vim" ]; then
    error "Ficheiro manai-vim-plugin-fixed.vim não encontrado no directório actual"
fi

# Função de ajuda
show_help() {
    cat << EOF
ManAI Vim Plugin - Script de Instalação (Versão Corrigida)

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Mostrar esta ajuda
    -m, --method METHOD     Método de instalação (manual, vim-plug, vundle)
    -f, --force            Sobrescrever instalação existente
    -c, --config           Adicionar configuração básica
    -t, --test             Testar instalação após completar

METHODS:
    manual                  Instalação manual (cópia directa)
    vim-plug               Configurar para vim-plug
    vundle                 Configurar para Vundle
    pathogen               Configurar para Pathogen

EXAMPLES:
    $0                      # Instalação interactiva
    $0 -m manual           # Instalação manual
    $0 -m vim-plug -c      # vim-plug com configuração
    $0 --test              # Instalar e testar

EOF
}

# Processar argumentos
METHOD=""
FORCE=false
ADD_CONFIG=false
TEST_INSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--method)
            METHOD="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -c|--config)
            ADD_CONFIG=true
            shift
            ;;
        -t|--test)
            TEST_INSTALL=true
            shift
            ;;
        *)
            error "Opção desconhecida: $1"
            ;;
    esac
done

# Função para confirmar acção
confirm() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    echo -n "$1 (y/N): "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Detectar editor disponível
detect_editor() {
    local editors=()
    
    if command -v vim &> /dev/null; then
        editors+=("vim")
    fi
    
    if command -v nvim &> /dev/null; then
        editors+=("neovim")
    fi
    
    if [ ${#editors[@]} -eq 0 ]; then
        error "Nem Vim nem Neovim encontrados"
    fi
    
    info "Editores detectados: ${editors[*]}"
    echo "${editors[@]}"
}

# Escolher método de instalação
choose_method() {
    if [ -n "$METHOD" ]; then
        echo "$METHOD"
        return
    fi
    
    echo ""
    echo "Escolha o método de instalação:"
    echo "1) Manual (cópia directa)"
    echo "2) vim-plug (recomendado)"
    echo "3) Vundle"
    echo "4) Pathogen"
    echo ""
    echo -n "Escolha (1-4): "
    read -r choice
    
    case "$choice" in
        1) echo "manual" ;;
        2) echo "vim-plug" ;;
        3) echo "vundle" ;;
        4) echo "pathogen" ;;
        *) 
            warning "Escolha inválida, usando instalação manual"
            echo "manual"
            ;;
    esac
}

# Instalação manual
install_manual() {
    log "Instalação manual..."
    
    local editors
    editors=($(detect_editor))
    
    for editor in "${editors[@]}"; do
        case "$editor" in
            "vim")
                local vim_plugin_dir="$HOME/.vim/plugin"
                mkdir -p "$vim_plugin_dir"
                
                if [ -f "$vim_plugin_dir/manai.vim" ] && [ "$FORCE" = false ]; then
                    if ! confirm "Ficheiro $vim_plugin_dir/manai.vim já existe. Sobrescrever?"; then
                        continue
                    fi
                fi
                
                cp manai-vim-plugin-fixed.vim "$vim_plugin_dir/manai.vim"
                success "Plugin instalado para Vim: $vim_plugin_dir/manai.vim"
                ;;
                
            "neovim")
                local nvim_plugin_dir="$HOME/.config/nvim/plugin"
                mkdir -p "$nvim_plugin_dir"
                
                if [ -f "$nvim_plugin_dir/manai.vim" ] && [ "$FORCE" = false ]; then
                    if ! confirm "Ficheiro $nvim_plugin_dir/manai.vim já existe. Sobrescrever?"; then
                        continue
                    fi
                fi
                
                cp manai-vim-plugin-fixed.vim "$nvim_plugin_dir/manai.vim"
                success "Plugin instalado para Neovim: $nvim_plugin_dir/manai.vim"
                ;;
        esac
    done
}

# Configurar vim-plug
install_vim_plug() {
    log "Configurando vim-plug..."
    
    # Verificar se vim-plug está instalado
    local vim_plug_installed=false
    local nvim_plug_installed=false
    
    if [ -f ~/.vim/autoload/plug.vim ]; then
        vim_plug_installed=true
        info "vim-plug detectado para Vim"
    fi
    
    if [ -f ~/.local/share/nvim/site/autoload/plug.vim ] || [ -f ~/.config/nvim/autoload/plug.vim ]; then
        nvim_plug_installed=true
        info "vim-plug detectado para Neovim"
    fi
    
    # Instalar vim-plug se necessário
    if [ "$vim_plug_installed" = false ] && command -v vim &> /dev/null; then
        if confirm "vim-plug não encontrado para Vim. Instalar?"; then
            curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            vim_plug_installed=true
            success "vim-plug instalado para Vim"
        fi
    fi
    
    if [ "$nvim_plug_installed" = false ] && command -v nvim &> /dev/null; then
        if confirm "vim-plug não encontrado para Neovim. Instalar?"; then
            sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
                   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            nvim_plug_installed=true
            success "vim-plug instalado para Neovim"
        fi
    fi
    
    # Adicionar configuração
    if [ "$ADD_CONFIG" = true ]; then
        add_vim_plug_config
    else
        info "Para completar a instalação, adicione ao seu .vimrc ou init.vim:"
        echo ""
        echo "call plug#begin('~/.vim/plugged')"
        echo "Plug 'edutech-angola/manai-vim-plugin'"
        echo "call plug#end()"
        echo ""
        echo "Depois execute :PlugInstall no Vim"
    fi
}

# Adicionar configuração vim-plug
add_vim_plug_config() {
    log "Adicionando configuração vim-plug..."
    
    local config_added=false
    
    # Configurar para Vim
    if [ -f ~/.vimrc ]; then
        if ! grep -q "manai-vim-plugin" ~/.vimrc; then
            if confirm "Adicionar configuração ao ~/.vimrc?"; then
                cat >> ~/.vimrc << 'EOF'

" === ManAI Vim Plugin ===
call plug#begin('~/.vim/plugged')
Plug 'edutech-angola/manai-vim-plugin'
call plug#end()

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
EOF
                config_added=true
                success "Configuração adicionada ao ~/.vimrc"
            fi
        else
            info "Configuração já existe no ~/.vimrc"
        fi
    fi
    
    # Configurar para Neovim
    if [ -f ~/.config/nvim/init.vim ]; then
        if ! grep -q "manai-vim-plugin" ~/.config/nvim/init.vim; then
            if confirm "Adicionar configuração ao ~/.config/nvim/init.vim?"; then
                cat >> ~/.config/nvim/init.vim << 'EOF'

" === ManAI Vim Plugin ===
call plug#begin('~/.local/share/nvim/plugged')
Plug 'edutech-angola/manai-vim-plugin'
call plug#end()

" Configurações do ManAI
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
EOF
                config_added=true
                success "Configuração adicionada ao ~/.config/nvim/init.vim"
            fi
        else
            info "Configuração já existe no ~/.config/nvim/init.vim"
        fi
    fi
    
    if [ "$config_added" = true ]; then
        warning "Execute :PlugInstall no Vim/Neovim para instalar o plugin"
    fi
}

# Configurar Vundle
install_vundle() {
    log "Configurando Vundle..."
    
    # Verificar se Vundle está instalado
    if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
        if confirm "Vundle não encontrado. Instalar?"; then
            git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
            success "Vundle instalado"
        else
            error "Vundle é necessário para este método"
        fi
    fi
    
    if [ "$ADD_CONFIG" = true ]; then
        add_vundle_config
    else
        info "Para completar a instalação, adicione ao seu .vimrc:"
        echo ""
        echo "Plugin 'edutech-angola/manai-vim-plugin'"
        echo ""
        echo "Depois execute :PluginInstall no Vim"
    fi
}

# Adicionar configuração Vundle
add_vundle_config() {
    log "Adicionando configuração Vundle..."
    
    if [ -f ~/.vimrc ]; then
        if ! grep -q "manai-vim-plugin" ~/.vimrc; then
            if confirm "Adicionar configuração ao ~/.vimrc?"; then
                # Procurar secção Vundle e adicionar plugin
                if grep -q "call vundle#begin" ~/.vimrc; then
                    sed -i '/call vundle#begin/a Plugin '\''edutech-angola/manai-vim-plugin'\''' ~/.vimrc
                else
                    cat >> ~/.vimrc << 'EOF'

" === Vundle Configuration ===
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'edutech-angola/manai-vim-plugin'
call vundle#end()
filetype plugin indent on

" === ManAI Configuration ===
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
EOF
                fi
                success "Configuração adicionada ao ~/.vimrc"
                warning "Execute :PluginInstall no Vim para instalar o plugin"
            fi
        else
            info "Configuração já existe no ~/.vimrc"
        fi
    fi
}

# Configurar Pathogen
install_pathogen() {
    log "Configurando Pathogen..."
    
    # Verificar se Pathogen está instalado
    if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
        if confirm "Pathogen não encontrado. Instalar?"; then
            mkdir -p ~/.vim/autoload ~/.vim/bundle
            curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
            success "Pathogen instalado"
        else
            error "Pathogen é necessário para este método"
        fi
    fi
    
    # Clonar repositório
    local bundle_dir="$HOME/.vim/bundle/manai-vim-plugin"
    
    if [ -d "$bundle_dir" ] && [ "$FORCE" = false ]; then
        if ! confirm "Directório $bundle_dir já existe. Sobrescrever?"; then
            return
        fi
        rm -rf "$bundle_dir"
    fi
    
    # Por agora, copiar ficheiro manualmente (até repositório estar disponível)
    mkdir -p "$bundle_dir/plugin"
    cp manai-vim-plugin-fixed.vim "$bundle_dir/plugin/manai.vim"
    success "Plugin instalado via Pathogen"
    
    if [ "$ADD_CONFIG" = true ]; then
        add_pathogen_config
    fi
}

# Adicionar configuração Pathogen
add_pathogen_config() {
    log "Adicionando configuração Pathogen..."
    
    if [ -f ~/.vimrc ]; then
        if ! grep -q "pathogen#infect" ~/.vimrc; then
            if confirm "Adicionar configuração Pathogen ao ~/.vimrc?"; then
                cat >> ~/.vimrc << 'EOF'

" === Pathogen Configuration ===
execute pathogen#infect()
syntax on
filetype plugin indent on

" === ManAI Configuration ===
let g:manai_language = 'pt'
let g:manai_window_height = 15
let g:manai_auto_close = 1
EOF
                success "Configuração adicionada ao ~/.vimrc"
            fi
        else
            info "Pathogen já configurado no ~/.vimrc"
        fi
    fi
}

# Testar instalação
test_installation() {
    log "Testando instalação..."
    
    if [ -f "./test-manai-vim.sh" ]; then
        ./test-manai-vim.sh
    else
        # Teste básico
        if command -v vim &> /dev/null; then
            if vim -c ":ManAIHelp" -c "q" &> /dev/null; then
                success "✅ Teste básico passou - Plugin carregado correctamente"
            else
                warning "⚠️  Teste básico falhou - Verifique a instalação"
            fi
        else
            info "Vim não disponível para teste"
        fi
    fi
}

# Mostrar instruções finais
show_final_instructions() {
    echo ""
    success "🎉 Instalação concluída!"
    echo ""
    
    info "Comandos disponíveis:"
    echo "  :ManAI <pergunta>     - Fazer consulta ao ManAI"
    echo "  :ManAIWord           - Consultar palavra sob cursor"
    echo "  :ManAILine           - Consultar linha actual"
    echo "  :ManAISelection      - Consultar selecção visual"
    echo "  :ManAIHelp           - Mostrar ajuda completa"
    echo ""
    
    info "Mapeamentos padrão:"
    echo "  <leader>ma           - Consultar palavra sob cursor"
    echo "  <leader>ml           - Consultar linha actual"
    echo "  <leader>ms           - Consultar selecção (modo visual)"
    echo "  <leader>mh           - Mostrar ajuda"
    echo ""
    
    info "Configurações principais:"
    echo "  let g:manai_language = 'pt'      \" Idioma das respostas"
    echo "  let g:manai_window_height = 15   \" Altura da janela"
    echo "  let g:manai_auto_close = 1       \" Fechar automaticamente"
    echo ""
    
    case "$METHOD" in
        "vim-plug")
            warning "Não se esqueça de executar :PlugInstall no Vim!"
            ;;
        "vundle")
            warning "Não se esqueça de executar :PluginInstall no Vim!"
            ;;
    esac
    
    echo ""
    info "Para mais informação: :ManAIHelp"
    echo ""
}

# Função principal
main() {
    echo "======================================"
    echo "  ManAI Vim Plugin - Instalação      "
    echo "======================================"
    echo ""
    
    # Detectar editores
    detect_editor > /dev/null
    
    # Escolher método
    METHOD=$(choose_method)
    info "Método escolhido: $METHOD"
    
    # Confirmar instalação
    if ! confirm "Continuar com a instalação usando $METHOD?"; then
        info "Instalação cancelada"
        exit 0
    fi
    
    # Executar instalação
    case "$METHOD" in
        "manual")
            install_manual
            ;;
        "vim-plug")
            install_vim_plug
            ;;
        "vundle")
            install_vundle
            ;;
        "pathogen")
            install_pathogen
            ;;
        *)
            error "Método desconhecido: $METHOD"
            ;;
    esac
    
    # Testar se solicitado
    if [ "$TEST_INSTALL" = true ]; then
        test_installation
    fi
    
    # Mostrar instruções finais
    show_final_instructions
}

# Executar script
main "$@"

