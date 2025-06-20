" ManAI Vim Plugin - Funcionalidades Avançadas
" Extensões e melhorias para o plugin principal
" Versão: 1.0.0

" ============================================================================
" Auto-completar para comandos Linux
" ============================================================================

let s:linux_commands = [
    \ 'ls', 'cd', 'pwd', 'mkdir', 'rmdir', 'rm', 'cp', 'mv', 'find', 'grep',
    \ 'awk', 'sed', 'sort', 'uniq', 'wc', 'head', 'tail', 'cat', 'less', 'more',
    \ 'chmod', 'chown', 'chgrp', 'ps', 'top', 'htop', 'kill', 'killall', 'jobs',
    \ 'bg', 'fg', 'nohup', 'screen', 'tmux', 'ssh', 'scp', 'rsync', 'wget', 'curl',
    \ 'tar', 'gzip', 'gunzip', 'zip', 'unzip', 'df', 'du', 'free', 'mount', 'umount',
    \ 'fdisk', 'lsblk', 'systemctl', 'service', 'crontab', 'at', 'history', 'alias'
\ ]

function! ManAIComplete(ArgLead, CmdLine, CursorPos)
    let l:suggestions = []
    
    " Se começar com comando conhecido, sugerir consultas comuns
    for l:cmd in s:linux_commands
        if a:ArgLead =~# '^' . l:cmd
            call add(l:suggestions, 'Como usar o comando ' . l:cmd . '?')
            call add(l:suggestions, 'Exemplos do comando ' . l:cmd)
            call add(l:suggestions, 'Opções do comando ' . l:cmd)
            break
        endif
    endfor
    
    " Sugestões gerais
    if empty(l:suggestions)
        let l:common_queries = [
            \ 'Como encontrar ficheiros por nome?',
            \ 'Como ver processos em execução?',
            \ 'Como alterar permissões de ficheiro?',
            \ 'Como comprimir ficheiros?',
            \ 'Como conectar via SSH?',
            \ 'Como ver espaço em disco?',
            \ 'Como matar um processo?',
            \ 'Como ver histórico de comandos?'
        \ ]
        
        for l:query in l:common_queries
            if l:query =~? a:ArgLead
                call add(l:suggestions, l:query)
            endif
        endfor
    endif
    
    return l:suggestions
endfunction

" Actualizar comando com auto-completar
command! -nargs=1 -complete=customlist,ManAIComplete ManAI call s:ManaiQuery(<q-args>)

" ============================================================================
" Histórico de consultas
" ============================================================================

let s:manai_history = []
let s:manai_history_file = expand('~/.vim_manai_history')

" Carregar histórico do ficheiro
function! s:LoadHistory()
    if filereadable(s:manai_history_file)
        let s:manai_history = readfile(s:manai_history_file)
    endif
endfunction

" Guardar histórico no ficheiro
function! s:SaveHistory()
    call writefile(s:manai_history, s:manai_history_file)
endfunction

" Adicionar consulta ao histórico
function! s:AddToHistory(query)
    " Evitar duplicados
    let l:index = index(s:manai_history, a:query)
    if l:index >= 0
        call remove(s:manai_history, l:index)
    endif
    
    " Adicionar no início
    call insert(s:manai_history, a:query)
    
    " Limitar tamanho do histórico
    if len(s:manai_history) > 50
        let s:manai_history = s:manai_history[:49]
    endif
    
    call s:SaveHistory()
endfunction

" Mostrar histórico
function! s:ShowHistory()
    if empty(s:manai_history)
        echo "ManAI: Histórico vazio"
        return
    endif
    
    let l:history_text = ["Histórico de consultas ManAI:", ""]
    let l:counter = 1
    
    for l:query in s:manai_history[:9]  " Mostrar apenas os últimos 10
        call add(l:history_text, printf("%2d. %s", l:counter, l:query))
        let l:counter += 1
    endfor
    
    call add(l:history_text, "")
    call add(l:history_text, "Use :ManAIHistorySelect <número> para repetir consulta")
    
    call s:ShowResult(join(l:history_text, "\n"), "Histórico ManAI")
endfunction

" Seleccionar do histórico
function! s:SelectFromHistory(index)
    if a:index < 1 || a:index > len(s:manai_history)
        echo "ManAI: Índice inválido"
        return
    endif
    
    let l:query = s:manai_history[a:index - 1]
    echo "ManAI: Repetindo consulta: " . l:query
    call s:ManaiQuery(l:query)
endfunction

" Comandos para histórico
command! ManAIHistory call s:ShowHistory()
command! -nargs=1 ManAIHistorySelect call s:SelectFromHistory(<args>)

" ============================================================================
" Integração com diferentes tipos de ficheiro
" ============================================================================

" Detectar contexto baseado no tipo de ficheiro
function! s:GetContextualQuery(base_query)
    let l:filetype = &filetype
    let l:context = ""
    
    if l:filetype ==# 'sh' || l:filetype ==# 'bash'
        let l:context = "No contexto de scripts bash, "
    elseif l:filetype ==# 'python'
        let l:context = "Para um programador Python trabalhando com Linux, "
    elseif l:filetype ==# 'dockerfile'
        let l:context = "No contexto de Docker e containers, "
    elseif l:filetype ==# 'yaml' || l:filetype ==# 'yml'
        let l:context = "No contexto de configuração YAML, "
    elseif l:filetype ==# 'json'
        let l:context = "Para manipulação de JSON no Linux, "
    endif
    
    return l:context . a:base_query
endfunction

" Consulta contextual
function! s:ManaiContextualQuery(query)
    let l:contextual_query = s:GetContextualQuery(a:query)
    call s:ManaiQuery(l:contextual_query)
endfunction

command! -nargs=1 ManAIContext call s:ManaiContextualQuery(<q-args>)

" ============================================================================
" Snippets e templates
" ============================================================================

let s:manai_snippets = {
    \ 'find_files': 'Como encontrar ficheiros por nome no Linux?',
    \ 'permissions': 'Como alterar permissões de ficheiros no Linux?',
    \ 'processes': 'Como ver e gerir processos no Linux?',
    \ 'disk_space': 'Como verificar espaço em disco no Linux?',
    \ 'network': 'Como verificar conexões de rede no Linux?',
    \ 'archives': 'Como criar e extrair arquivos no Linux?',
    \ 'text_processing': 'Como processar texto com grep, awk e sed?',
    \ 'system_info': 'Como obter informações do sistema Linux?'
\ }

function! s:ShowSnippets()
    let l:snippet_text = ["Snippets ManAI disponíveis:", ""]
    
    for [l:key, l:value] in items(s:manai_snippets)
        call add(l:snippet_text, printf(":%s - %s", l:key, l:value))
    endfor
    
    call add(l:snippet_text, "")
    call add(l:snippet_text, "Use :ManAISnippet <nome> para usar um snippet")
    
    call s:ShowResult(join(l:snippet_text, "\n"), "Snippets ManAI")
endfunction

function! s:UseSnippet(name)
    if has_key(s:manai_snippets, a:name)
        call s:ManaiQuery(s:manai_snippets[a:name])
    else
        echo "ManAI: Snippet '" . a:name . "' não encontrado"
    endif
endfunction

function! ManAISnippetComplete(ArgLead, CmdLine, CursorPos)
    return filter(keys(s:manai_snippets), 'v:val =~# "^" . a:ArgLead')
endfunction

command! ManAISnippets call s:ShowSnippets()
command! -nargs=1 -complete=customlist,ManAISnippetComplete ManAISnippet call s:UseSnippet(<args>)

" ============================================================================
" Modo interactivo
" ============================================================================

let s:manai_interactive_mode = 0

function! s:ToggleInteractiveMode()
    let s:manai_interactive_mode = !s:manai_interactive_mode
    
    if s:manai_interactive_mode
        echo "ManAI: Modo interactivo ACTIVADO"
        echo "Seleccione texto e pressione <leader>mi para consulta automática"
        
        " Mapear seleção automática
        vnoremap <buffer> <leader>mi :ManAISelection<CR>
        
        " Auto-consulta ao seleccionar texto
        autocmd CursorMoved,CursorMovedI * call s:AutoQuery()
    else
        echo "ManAI: Modo interactivo DESACTIVADO"
        
        " Remover mapeamentos
        silent! vunmap <buffer> <leader>mi
        autocmd! CursorMoved,CursorMovedI
    endif
endfunction

function! s:AutoQuery()
    " Implementação futura para consultas automáticas
    " Por agora, apenas detecta comandos Linux na linha
    let l:line = getline('.')
    
    for l:cmd in s:linux_commands
        if l:line =~# '\<' . l:cmd . '\>'
            " Mostrar dica discreta
            echo "ManAI: Comando '" . l:cmd . "' detectado. Use <leader>ml para ajuda"
            break
        endif
    endfor
endfunction

command! ManAIInteractive call s:ToggleInteractiveMode()

" ============================================================================
" Integração com terminal
" ============================================================================

function! s:ManaiTerminal(query)
    if has('terminal') || has('nvim')
        " Abrir terminal e executar consulta
        let l:cmd = printf('%s -c "import sys; sys.path.append(\".\"); from manai_client import query_manai; print(query_manai(\"%s\"))"', 
                    \ g:manai_python_path, escape(a:query, '"'))
        
        if has('nvim')
            execute 'split | terminal ' . l:cmd
        else
            execute 'terminal ' . l:cmd
        endif
    else
        echo "ManAI: Terminal não suportado nesta versão do Vim"
    endif
endfunction

command! -nargs=1 ManAITerminal call s:ManaiTerminal(<q-args>)

" ============================================================================
" Configurações avançadas
" ============================================================================

" Cache de respostas
let s:manai_cache = {}
let s:manai_cache_enabled = get(g:, 'manai_cache_enabled', 1)

function! s:GetCachedResponse(query)
    if s:manai_cache_enabled && has_key(s:manai_cache, a:query)
        return s:manai_cache[a:query]
    endif
    return ""
endfunction

function! s:CacheResponse(query, response)
    if s:manai_cache_enabled
        let s:manai_cache[a:query] = a:response
        
        " Limitar tamanho do cache
        if len(s:manai_cache) > 20
            " Remover entrada mais antiga (implementação simples)
            let l:keys = keys(s:manai_cache)
            call remove(s:manai_cache, l:keys[0])
        endif
    endif
endfunction

" Limpar cache
function! s:ClearCache()
    let s:manai_cache = {}
    echo "ManAI: Cache limpo"
endfunction

command! ManAIClearCache call s:ClearCache()

" ============================================================================
" Mapeamentos adicionais
" ============================================================================

if !exists('g:manai_no_advanced_mappings') || !g:manai_no_advanced_mappings
    " Mapeamentos para funcionalidades avançadas
    nnoremap <silent> <leader>mH :ManAIHistory<CR>
    nnoremap <silent> <leader>mS :ManAISnippets<CR>
    nnoremap <silent> <leader>mI :ManAIInteractive<CR>
    nnoremap <silent> <leader>mC :ManAIClearCache<CR>
    
    " Consulta contextual
    nnoremap <leader>mx :ManAIContext 
endif

" ============================================================================
" Inicialização das funcionalidades avançadas
" ============================================================================

" Carregar histórico na inicialização
call s:LoadHistory()

" Auto-comandos para salvar histórico
augroup ManAIAdvanced
    autocmd!
    autocmd VimLeave * call s:SaveHistory()
augroup END

echo "ManAI: Funcionalidades avançadas carregadas!"

