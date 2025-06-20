#!/bin/bash

# ManAI Vim Plugin - Instalador a partir do GitHub
# Versão 3.0 - Instalação Direta do Repositório

set -eo pipefail

# Configurações
VERSION="3.0.0"
REPO_OWNER="ruscorreia"
REPO_NAME="manai-vim-plugin"
REPO_URL="https://github.com/$REPO_OWNER/$REPO_NAME.git"
DEFAULT_BRANCH="main"
INSTALL_DIR="/tmp/manai-vim-install-$(date +%s)"
PLUGIN_FILE="manai-vim-plugin.vim"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funções de logging
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERRO] $1${NC}" >&2; exit 1; }
warning() { echo -e "${YELLOW}[AVISO] $1${NC}" >&2; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${GREEN}[SUCESSO] $1${NC}"; }

# Verificar dependências
check_dependencies() {
    local deps=("git" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Dependências faltando: ${missing[*]}. Por favor instale antes de continuar."
    fi
}

# Clonar repositório
clone_repository() {
    log "Clonando repositório do GitHub..."
    mkdir -p "$INSTALL_DIR"
    
    if ! git clone --depth 1 --branch "$DEFAULT_BRANCH" "$REPO_URL" "$INSTALL_DIR"; then
        error "Falha ao clonar repositório $REPO_URL"
    fi
    
    if [ ! -f "$INSTALL_DIR/$PLUGIN_FILE" ]; then
        error "Arquivo do plugin não encontrado no repositório"
    fi
    
    success "Repositório clonado com sucesso"
}

# Detectar editores instalados
detect_editors() {
    local editors=()
    
    if command -v vim &> /dev/null; then
        editors+=("vim")
    fi
    
    if command -v nvim &> /dev/null; then
        editors+=("neovim")
    fi
    
    if [ ${#editors[@]} -eq 0 ]; then
        error "Nenhum editor (Vim/Neovim) encontrado"
    fi
    
    echo "${editors[@]}"
}

# Instalar para Vim
install_vim() {
    local vim_plugin_dir="$HOME/.vim/plugin"
    
    log "Instalando para Vim..."
    mkdir -p "$vim_plugin_dir"
    
    if [ -f "$vim_plugin_dir/manai.vim" ]; then
        warning "Plugin já instalado para Vim. Substituindo..."
    fi
    
    cp "$INSTALL_DIR/$PLUGIN_FILE" "$vim_plugin_dir/manai.vim"
    success "Plugin instalado para Vim em $vim_plugin_dir/manai.vim"
}

# Instalar para Neovim
install_neovim() {
    local nvim_plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugin"
    
    log "Instalando para Neovim..."
    mkdir -p "$nvim_plugin_dir"
    
    if [ -f "$nvim_plugin_dir/manai.vim" ]; then
        warning "Plugin já instalado para Neovim. Substituindo..."
    fi
    
    cp "$INSTALL_DIR/$PLUGIN_FILE" "$nvim_plugin_dir/manai.vim"
    success "Plugin instalado para Neovim em $nvim_plugin_dir/manai.vim"
}

# Configurar vim-plug (opcional)
setup_vim_plug() {
    if confirm "Deseja configurar o vim-plug (gerenciador de plugins recomendado)?"; then
        log "Configurando vim-plug..."
        
        # Instalar vim-plug se necessário
        if [ ! -f ~/.vim/autoload/plug.vim ]; then
            curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        fi
        
        # Adicionar configuração ao .vimrc
        local vimrc="$HOME/.vimrc"
        local config="\" ManAI Vim Plugin
call plug#begin('~/.vim/plugged')
Plug '$REPO_URL'
call plug#end()"
        
        if [ -f "$vimrc" ]; then
            if grep -q "$REPO_URL" "$vimrc"; then
                warning "Configuração já existe no $vimrc"
            else
                echo -e "\n$config" >> "$vimrc"
                success "Configuração adicionada ao $vimrc"
                warning "Execute :PlugInstall no Vim para completar a instalação"
            fi
        else
            echo "$config" > "$vimrc"
            success "Arquivo $vimrc criado com configuração do plugin"
            warning "Execute :PlugInstall no Vim para completar a instalação"
        fi
    fi
}

# Confirmar ação
confirm() {
    echo -n -e "${YELLOW}$1 [y/N]: ${NC}"
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

# Limpar arquivos temporários
cleanup() {
    log "Limpando arquivos temporários..."
    rm -rf "$INSTALL_DIR"
}

# Mostrar mensagem pós-instalação
show_post_install() {
    echo -e "\n${GREEN}=== Instalação Completa ==="
    echo -e "O plugin ManAI foi instalado com sucesso!"
    echo -e "==========================${NC}\n"
    
    info "Comandos disponíveis:"
    echo "  :ManAI <pergunta>     - Fazer consulta ao ManAI"
    echo "  :ManAIHelp           - Mostrar ajuda completa"
    echo ""
    
    info "Configuração recomendada:"
    echo "Adicione ao seu .vimrc ou init.vim:"
    echo "  let g:manai_language = 'pt'      \" Idioma das respostas"
    echo "  let g:manai_api_key = 'sua_chave' \" Chave de API (opcional)"
    echo ""
}

# Função principal
main() {
    echo -e "${GREEN}
    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗ ██╗
    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██║
    ██╔████╔██║███████║██╔██╗ ██║███████║██║
    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║
    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║██║
    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝
    ${NC}"
    echo -e "${BLUE}  Vim Plugin - Instalador GitHub v${VERSION}${NC}\n"
    
    # Verificar dependências
    check_dependencies
    
    # Clonar repositório
    clone_repository
    
    # Detectar editores
    editors=($(detect_editors))
    
    # Instalar para cada editor
    for editor in "${editors[@]}"; do
        case "$editor" in
            "vim") install_vim ;;
            "neovim") install_neovim ;;
        esac
    done
    
    # Configurar vim-plug (opcional)
    setup_vim_plug
    
    # Mostrar mensagem pós-instalação
    show_post_install
    
    # Limpar
    cleanup
}

# Executar instalação
main