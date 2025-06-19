" ManAI Vim Plugin
" Integração do assistente de comandos Linux ManAI com o Vim
" Versão: 1.0.0
" Autor: EduTech Angola

if exists('g:loaded_manai')
    finish
endif
let g:loaded_manai = 1

" Configurações padrão
if !exists('g:manai_python_path')
    let g:manai_python_path = 'python3'
endif

if !exists('g:manai_client_path')
    let g:manai_client_path = expand('~/.local/bin/manai')
endif

if !exists('g:manai_api_url')
    let g:manai_api_url = 'https://manai-agent-function-app.azurewebsites.net/api/ManaiAgentHttpTrigger'
endif

if !exists('g:manai_function_key')
    let g:manai_function_key = '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA=='
endif

if !exists('g:manai_window_height')
    let g:manai_window_height = 15
endif

if !exists('g:manai_auto_close')
    let g:manai_auto_close = 1
endif

if !exists('g:manai_language')
    let g:manai_language = 'pt'
endif

" Função principal para fazer consulta ao ManAI
function! s:ManaiQuery(query)
    if empty(a:query)
        echo "ManAI: Por favor, forneça uma pergunta"
        return
    endif

    " Criar comando Python para consulta
    let l:python_cmd = printf('%s -c "
import sys
import json
import urllib.request
import urllib.parse

def query_manai(question):
    url = \"%s\"
    headers = {
        \"Content-Type\": \"application/json\",
        \"x-functions-key\": \"%s\"
    }
    
    data = {
        \"message\": question,
        \"language\": \"%s\"
    }
    
    try:
        req = urllib.request.Request(
            url, 
            data=json.dumps(data).encode(\"utf-8\"),
            headers=headers,
            method=\"POST\"
        )
        
        with urllib.request.urlopen(req, timeout=30) as response:
            result = json.loads(response.read().decode(\"utf-8\"))
            return result.get(\"response\", \"Sem resposta\")
    except Exception as e:
        return f\"Erro: {str(e)}\"

if __name__ == \"__main__\":
    question = sys.argv[1] if len(sys.argv) > 1 else \"\"
    if question:
        print(query_manai(question))
    else:
        print(\"Erro: Nenhuma pergunta fornecida\")
"', g:manai_python_path, g:manai_api_url, g:manai_function_key, g:manai_language)

    " Executar consulta
    echo "ManAI: Consultando..."
    let l:result = system(l:python_cmd . ' ' . shellescape(a:query))
    
    if v:shell_error != 0
        echo "ManAI: Erro na consulta - " . l:result
        return
    endif

    " Mostrar resultado em janela flutuante ou split
    call s:ShowResult(l:result, a:query)
endfunction

" Função para mostrar resultado
function! s:ShowResult(result, query)
    " Criar buffer temporário
    let l:bufnr = bufnr('__ManAI_Result__', 1)
    
    " Configurar janela
    if has('nvim') && exists('*nvim_open_win')
        " Neovim com janela flutuante
        call s:ShowFloatingWindow(l:bufnr, a:result, a:query)
    else
        " Vim tradicional com split horizontal
        call s:ShowSplitWindow(l:bufnr, a:result, a:query)
    endif
endfunction

" Janela flutuante para Neovim
function! s:ShowFloatingWindow(bufnr, result, query)
    let l:width = float2nr(&columns * 0.8)
    let l:height = float2nr(&lines * 0.6)
    let l:row = float2nr((&lines - l:height) / 2)
    let l:col = float2nr((&columns - l:width) / 2)

    let l:opts = {
        \ 'relative': 'editor',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'row': l:row,
        \ 'col': l:col,
        \ 'style': 'minimal',
        \ 'border': 'rounded'
    \ }

    let l:win = nvim_open_win(a:bufnr, 1, l:opts)
    call s:PopulateBuffer(a:bufnr, a:result, a:query)
    
    " Configurar buffer
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal wrap
    setlocal linebreak
    
    " Mapeamentos para fechar
    nnoremap <buffer> <silent> q :close<CR>
    nnoremap <buffer> <silent> <Esc> :close<CR>
endfunction

" Split horizontal para Vim tradicional
function! s:ShowSplitWindow(bufnr, result, query)
    execute 'botright ' . g:manai_window_height . 'split'
    execute 'buffer ' . a:bufnr
    call s:PopulateBuffer(a:bufnr, a:result, a:query)
    
    " Configurar buffer
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal wrap
    setlocal linebreak
    setlocal nomodifiable
    
    " Mapeamentos para fechar
    nnoremap <buffer> <silent> q :close<CR>
    nnoremap <buffer> <silent> <Esc> :close<CR>
    
    " Auto-fechar se configurado
    if g:manai_auto_close
        autocmd CursorMoved <buffer> close
    endif
endfunction

" Preencher buffer com resultado
function! s:PopulateBuffer(bufnr, result, query)
    setlocal modifiable
    
    " Limpar buffer
    silent! %delete _
    
    " Cabeçalho
    call append(0, '╭─ ManAI - Assistente de Comandos Linux ─╮')
    call append(1, '│')
    call append(2, '│ Pergunta: ' . a:query)
    call append(3, '│')
    call append(4, '╰─────────────────────────────────────────╯')
    call append(5, '')
    
    " Processar e adicionar resultado
    let l:lines = split(a:result, '\n')
    let l:line_num = 6
    
    for l:line in l:lines
        call append(l:line_num, l:line)
        let l:line_num += 1
    endfor
    
    " Rodapé
    call append(l:line_num, '')
    call append(l:line_num + 1, '─────────────────────────────────────────')
    call append(l:line_num + 2, 'Pressione "q" ou <Esc> para fechar')
    
    " Ir para o início
    normal! gg
    setlocal nomodifiable
endfunction

" Função para consulta rápida da palavra sob o cursor
function! s:ManaiQueryWord()
    let l:word = expand('<cword>')
    if empty(l:word)
        echo "ManAI: Nenhuma palavra sob o cursor"
        return
    endif
    
    let l:query = "Como usar o comando " . l:word . " no Linux?"
    call s:ManaiQuery(l:query)
endfunction

" Função para consulta da linha actual
function! s:ManaiQueryLine()
    let l:line = getline('.')
    if empty(trim(l:line))
        echo "ManAI: Linha vazia"
        return
    endif
    
    let l:query = "Explique este comando Linux: " . l:line
    call s:ManaiQuery(l:query)
endfunction

" Função para consulta de texto seleccionado
function! s:ManaiQuerySelection() range
    let l:lines = getline(a:firstline, a:lastline)
    let l:text = join(l:lines, ' ')
    
    if empty(trim(l:text))
        echo "ManAI: Seleção vazia"
        return
    endif
    
    let l:query = "Explique este comando ou script Linux: " . l:text
    call s:ManaiQuery(l:query)
endfunction

" Função para mostrar ajuda
function! s:ManaiHelp()
    let l:help_text = [
        \ "ManAI - Assistente de Comandos Linux para Vim",
        \ "",
        \ "Comandos disponíveis:",
        \ "  :ManAI <pergunta>     - Fazer pergunta ao ManAI",
        \ "  :ManAIWord           - Consultar palavra sob cursor",
        \ "  :ManAILine           - Consultar linha actual",
        \ "  :ManAISelection      - Consultar texto seleccionado",
        \ "  :ManAIHelp           - Mostrar esta ajuda",
        \ "  :ManAIConfig         - Mostrar configuração",
        \ "",
        \ "Mapeamentos padrão:",
        \ "  <leader>ma           - Consultar palavra sob cursor",
        \ "  <leader>ml           - Consultar linha actual",
        \ "  <leader>ms           - Consultar seleção (modo visual)",
        \ "  <leader>mh           - Mostrar ajuda",
        \ "",
        \ "Configurações (no .vimrc):",
        \ "  let g:manai_python_path = 'python3'",
        \ "  let g:manai_language = 'pt'",
        \ "  let g:manai_window_height = 15",
        \ "  let g:manai_auto_close = 1"
    \ ]
    
    call s:ShowResult(join(l:help_text, "\n"), "Ajuda do ManAI")
endfunction

" Função para mostrar configuração
function! s:ManaiConfig()
    let l:config_text = [
        \ "Configuração actual do ManAI:",
        \ "",
        \ "Python Path: " . g:manai_python_path,
        \ "Client Path: " . g:manai_client_path,
        \ "API URL: " . g:manai_api_url,
        \ "Language: " . g:manai_language,
        \ "Window Height: " . g:manai_window_height,
        \ "Auto Close: " . g:manai_auto_close,
        \ "",
        \ "Para alterar, adicione no seu .vimrc:",
        \ "let g:manai_language = 'en'  \" Para inglês",
        \ "let g:manai_window_height = 20",
        \ "let g:manai_auto_close = 0"
    \ ]
    
    call s:ShowResult(join(l:config_text, "\n"), "Configuração do ManAI")
endfunction

" Comandos do Vim
command! -nargs=1 ManAI call s:ManaiQuery(<q-args>)
command! ManAIWord call s:ManaiQueryWord()
command! ManAILine call s:ManaiQueryLine()
command! -range ManAISelection <line1>,<line2>call s:ManaiQuerySelection()
command! ManAIHelp call s:ManaiHelp()
command! ManAIConfig call s:ManaiConfig()

" Mapeamentos padrão (podem ser desabilitados com let g:manai_no_mappings = 1)
if !exists('g:manai_no_mappings') || !g:manai_no_mappings
    " Mapeamentos no modo normal
    nnoremap <silent> <leader>ma :ManAIWord<CR>
    nnoremap <silent> <leader>ml :ManAILine<CR>
    nnoremap <silent> <leader>mh :ManAIHelp<CR>
    nnoremap <silent> <leader>mc :ManAIConfig<CR>
    
    " Mapeamentos no modo visual
    vnoremap <silent> <leader>ms :ManAISelection<CR>
    
    " Mapeamento para consulta interactiva
    nnoremap <leader>mq :ManAI 
endif

" Auto-comandos
augroup ManAI
    autocmd!
    " Destacar sintaxe nos resultados
    autocmd BufEnter __ManAI_Result__ setlocal filetype=manai_result
augroup END

" Definir sintaxe para resultados
if !exists('g:manai_no_syntax')
    autocmd BufNewFile,BufRead __ManAI_Result__ call s:SetManAISyntax()
endif

function! s:SetManAISyntax()
    syntax clear
    
    " Cabeçalho
    syntax match ManAIHeader /^╭.*╮$/
    syntax match ManAIHeader /^│.*$/
    syntax match ManAIHeader /^╰.*╯$/
    
    " Comandos (texto entre backticks ou após $)
    syntax match ManAICommand /`[^`]*`/
    syntax match ManAICommand /\$.*$/
    
    " Opções de comandos
    syntax match ManAIOption /-[a-zA-Z0-9-]*/
    
    " Caminhos de ficheiros
    syntax match ManAIPath /\/[a-zA-Z0-9_/.-]*/
    
    " Rodapé
    syntax match ManAIFooter /^─.*$/
    syntax match ManAIFooter /^Pressione.*$/
    
    " Cores
    highlight ManAIHeader ctermfg=Blue guifg=#3b82f6
    highlight ManAICommand ctermfg=Green guifg=#10b981 cterm=bold gui=bold
    highlight ManAIOption ctermfg=Yellow guifg=#f59e0b
    highlight ManAIPath ctermfg=Cyan guifg=#06b6d4
    highlight ManAIFooter ctermfg=Gray guifg=#6b7280
endfunction

" Função de inicialização
function! s:ManAIInit()
    echo "ManAI Plugin carregado! Use :ManAIHelp para começar."
endfunction

" Inicializar plugin
call s:ManAIInit()

