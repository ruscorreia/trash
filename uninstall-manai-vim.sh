#!/bin/bash

# ManAI Vim Plugin - Script de Desinstalação Automática
# Remove completamente a versão anterior do plugin

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
error() { echo -e "${RED}[ERROR] $1${NC}"; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${PURPLE}[SUCCESS] $1${NC}"; }

# Função de ajuda
show_help() {
    cat << EOF
ManAI Vim Plugin - Script de Desinstalação

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Mostrar esta ajuda
    -f, --force            Forçar remoção sem confirmação
    -b, --backup           Fazer backup antes de remover
    -v, --verbose          Output detalhado
    -d, --dry-run          Mostrar o que seria removido sem remover

EXAMPLES:
    $0                      # Desinstalação interactiva
    $0 --force             # Remoção forçada
    $0 --dry-run           # Simular remoção

EOF
}

# Processar argumentos
FORCE=false
BACKUP=true
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            error "Opção desconhecida: $1"
            show_help
            exit 1
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

# Fazer backup das configurações
backup_configs() {
    if [ "$BACKUP" = false ]; then
        return 0
    fi
    
    log "Fazendo backup das configurações..."
    
    local backup_date
    backup_date=$(date +%Y%m%d_%H%M%S)
    
    if [ "$DRY_RUN" = false ]; then
        # Backup do .vimrc
        if [ -f ~/.vimrc ]; then
            cp ~/.vimrc ~/.vimrc.backup.$backup_date
            info "Backup criado: ~/.vimrc.backup.$backup_date"
        fi
        
        # Backup do init.vim do Neovim
        if [ -f ~/.config/nvim/init.vim ]; then
            mkdir -p ~/.config/nvim/backups
            cp ~/.config/nvim/init.vim ~/.config/nvim/backups/init.vim.backup.$backup_date
            info "Backup criado: ~/.config/nvim/backups/init.vim.backup.$backup_date"
        fi
        
        # Backup do init.lua do Neovim
        if [ -f ~/.config/nvim/init.lua ]; then
            mkdir -p ~/.config/nvim/backups
            cp ~/.config/nvim/init.lua ~/.config/nvim/backups/init.lua.backup.$backup_date
            info "Backup criado: ~/.config/nvim/backups/init.lua.backup.$backup_date"
        fi
    else
        info "DRY RUN: Faria backup das configurações"
    fi
    
    success "Backup das configurações concluído"
}

# Detectar método de instalação
detect_installation_method() {
    log "Detectando método de instalação..."
    
    local methods=()
    
    # Verificar instalação manual
    if [ -f ~/.vim/plugin/manai.vim ] || [ -f ~/.config/nvim/plugin/manai.vim ]; then
        methods+=("manual")
    fi
    
    # Verificar vim-plug
    if grep -q "Plug.*manai" ~/.vimrc ~/.config/nvim/init.vim ~/.config/nvim/init.lua 2>/dev/null; then
        methods+=("vim-plug")
    fi
    
    # Verificar Vundle
    if grep -q "Plugin.*manai" ~/.vimrc 2>/dev/null; then
        methods+=("vundle")
    fi
    
    # Verificar Pathogen
    if [ -d ~/.vim/bundle/manai-vim-plugin ] || [ -d ~/.vim/bundle/manai ]; then
        methods+=("pathogen")
    fi
    
    # Verificar Dein
    if grep -q "dein#add.*manai" ~/.vimrc ~/.config/nvim/init.vim 2>/dev/null; then
        methods+=("dein")
    fi
    
    # Verificar Packer
    if grep -q "use.*manai" ~/.config/nvim/init.lua ~/.config/nvim/lua/plugins.lua 2>/dev/null; then
        methods+=("packer")
    fi
    
    if [ ${#methods[@]} -eq 0 ]; then
        warning "Nenhuma instalação do ManAI detectada"
        return 1
    fi
    
    info "Métodos detectados: ${methods[*]}"
    echo "${methods[@]}"
}

# Remover ficheiros manuais
remove_manual_files() {
    log "Removendo ficheiros de instalação manual..."
    
    local files_to_remove=(
        ~/.vim/plugin/manai.vim
        ~/.vim/plugin/manai-vim-plugin.vim
        ~/.vim/autoload/manai.vim
        ~/.vim/doc/manai.txt
        ~/.config/nvim/plugin/manai.vim
        ~/.config/nvim/plugin/manai-vim-plugin.vim
        ~/.config/nvim/autoload/manai.vim
        ~/.config/nvim/doc/manai.txt
    )
    
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            if [ "$DRY_RUN" = false ]; then
                rm -f "$file"
                info "Removido: $file"
            else
                info "DRY RUN: Removeria $file"
            fi
        fi
    done
    
    success "Ficheiros manuais removidos"
}

# Remover de vim-plug
remove_vim_plug() {
    log "Removendo de vim-plug..."
    
    if [ "$DRY_RUN" = false ]; then
        # Remover directórios do vim-plug
        rm -rf ~/.vim/plugged/manai*
        rm -rf ~/.local/share/nvim/plugged/manai*
        rm -rf ~/.local/share/nvim/site/pack/packer/start/manai*
        
        info "Directórios do vim-plug removidos"
        warning "Remova manualmente a linha 'Plug' do seu .vimrc e execute :PlugClean"
    else
        info "DRY RUN: Removeria directórios do vim-plug"
    fi
    
    success "vim-plug processado"
}

# Remover de Vundle
remove_vundle() {
    log "Removendo de Vundle..."
    
    if [ "$DRY_RUN" = false ]; then
        rm -rf ~/.vim/bundle/manai*
        info "Directórios do Vundle removidos"
        warning "Remova manualmente a linha 'Plugin' do seu .vimrc e execute :PluginClean"
    else
        info "DRY RUN: Removeria directórios do Vundle"
    fi
    
    success "Vundle processado"
}

# Remover de Pathogen
remove_pathogen() {
    log "Removendo de Pathogen..."
    
    if [ "$DRY_RUN" = false ]; then
        rm -rf ~/.vim/bundle/manai*
        info "Directórios do Pathogen removidos"
    else
        info "DRY RUN: Removeria directórios do Pathogen"
    fi
    
    success "Pathogen processado"
}

# Remover de Dein
remove_dein() {
    log "Removendo de Dein..."
    
    if [ "$DRY_RUN" = false ]; then
        rm -rf ~/.cache/dein/repos/github.com/ruscorreia/manai*
        rm -rf ~/.local/share/dein/repos/github.com/ruscorreia/manai*
        info "Directórios do Dein removidos"
        warning "Remova manualmente a linha 'dein#add' e execute :call dein#recache_runtimepath()"
    else
        info "DRY RUN: Removeria directórios do Dein"
    fi
    
    success "Dein processado"
}

# Remover de Packer
remove_packer() {
    log "Removendo de Packer..."
    
    if [ "$DRY_RUN" = false ]; then
        rm -rf ~/.local/share/nvim/site/pack/packer/start/manai*
        rm -rf ~/.local/share/nvim/site/pack/packer/opt/manai*
        info "Directórios do Packer removidos"
        warning "Remova manualmente a linha 'use' e execute :PackerClean"
    else
        info "DRY RUN: Removeria directórios do Packer"
    fi
    
    success "Packer processado"
}

# Limpar cache e dados
clean_cache_and_data() {
    log "Limpando cache e dados..."
    
    local dirs_to_remove=(
        ~/.cache/manai-vim
        ~/.cache/manai
        ~/.local/share/manai-vim
        ~/.local/share/manai
        ~/.config/manai-vim
        ~/.config/manai
    )
    
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "$dir" ]; then
            if [ "$DRY_RUN" = false ]; then
                rm -rf "$dir"
                info "Removido: $dir"
            else
                info "DRY RUN: Removeria $dir"
            fi
        fi
    done
    
    success "Cache e dados limpos"
}

# Limpar configurações dos ficheiros
clean_config_files() {
    log "Limpando configurações dos ficheiros..."
    
    local config_files=(
        ~/.vimrc
        ~/.config/nvim/init.vim
        ~/.config/nvim/init.lua
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            if [ "$DRY_RUN" = false ]; then
                # Remover linhas que contenham 'manai' ou 'ManAI'
                sed -i.tmp '/[Mm]an[Aa][Ii]/d' "$config_file"
                rm -f "$config_file.tmp"
                info "Configurações removidas de: $config_file"
            else
                info "DRY RUN: Removeria configurações de $config_file"
            fi
        fi
    done
    
    success "Configurações limpas"
}

# Verificar limpeza
verify_cleanup() {
    log "Verificando limpeza..."
    
    local remaining_files
    local remaining_dirs
    local remaining_configs
    
    # Procurar ficheiros restantes
    remaining_files=$(find ~ -name "*manai*" -type f 2>/dev/null | grep -v backup | head -10 || true)
    
    # Procurar directórios restantes
    remaining_dirs=$(find ~ -name "*manai*" -type d 2>/dev/null | head -10 || true)
    
    # Procurar configurações restantes
    remaining_configs=$(grep -i manai ~/.vimrc ~/.config/nvim/init.vim ~/.config/nvim/init.lua 2>/dev/null | head -5 || true)
    
    if [ -z "$remaining_files" ] && [ -z "$remaining_dirs" ] && [ -z "$remaining_configs" ]; then
        success "✅ Limpeza completa! Nenhum vestígio do ManAI encontrado."
    else
        warning "⚠️  Alguns itens podem ter ficado:"
        [ -n "$remaining_files" ] && echo "Ficheiros: $remaining_files"
        [ -n "$remaining_dirs" ] && echo "Directórios: $remaining_dirs"
        [ -n "$remaining_configs" ] && echo "Configurações: $remaining_configs"
    fi
}

# Função principal
main() {
    echo "======================================"
    echo "  ManAI Vim Plugin - Desinstalação   "
    echo "======================================"
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        warning "MODO DRY RUN - Nenhuma alteração será feita"
        echo ""
    fi
    
    # Detectar instalação
    local methods
    if ! methods=$(detect_installation_method); then
        info "Nenhuma instalação detectada. Executando limpeza geral..."
    fi
    
    # Confirmar desinstalação
    if ! confirm "Deseja continuar com a desinstalação?"; then
        info "Desinstalação cancelada"
        exit 0
    fi
    
    # Fazer backup
    backup_configs
    
    # Remover por método detectado
    if [[ " ${methods[*]} " =~ " manual " ]]; then
        remove_manual_files
    fi
    
    if [[ " ${methods[*]} " =~ " vim-plug " ]]; then
        remove_vim_plug
    fi
    
    if [[ " ${methods[*]} " =~ " vundle " ]]; then
        remove_vundle
    fi
    
    if [[ " ${methods[*]} " =~ " pathogen " ]]; then
        remove_pathogen
    fi
    
    if [[ " ${methods[*]} " =~ " dein " ]]; then
        remove_dein
    fi
    
    if [[ " ${methods[*]} " =~ " packer " ]]; then
        remove_packer
    fi
    
    # Limpeza geral
    clean_cache_and_data
    clean_config_files
    
    # Verificar resultado
    verify_cleanup
    
    echo ""
    success "🎉 Desinstalação concluída!"
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        info "Próximos passos para instalar a versão corrigida:"
        echo "1. Adicione 'Plug \"ruscorreia/manai-vim-plugin\"' ao seu .vimrc"
        echo "2. Execute :PlugInstall no Vim"
        echo "3. Configure conforme necessário"
        echo ""
        info "Ou use a instalação manual:"
        echo "cp manai-vim-plugin-fixed.vim ~/.vim/plugin/manai.vim"
    else
        info "Execute sem --dry-run para fazer a desinstalação real"
    fi
    
    echo ""
}

# Executar script
main "$@"

