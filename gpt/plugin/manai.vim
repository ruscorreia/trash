" ManAI Vim Plugin - Consulta educativa com assistente virtual
if exists('g:loaded_manai_plugin')
  finish
endif
let g:loaded_manai_plugin = 1

" Configurações padrão
if !exists('g:manai_language') | let g:manai_language = 'pt' | endif
if !exists('g:api_url') | let g:api_url = 'https://manai-agent-function-app.azurewebsites.net/api/ManaiAgentHttpTrigger' | endif
if !exists('g:manai_function_key') | let g:manai_function_key = '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA==' | endif
if !exists('g:manai_timeout') | let g:manai_timeout = 10 | endif
if !exists('g:manai_cache_enabled') | let g:manai_cache_enabled = 1 | endif
if !exists('g:manai_window_height') | let g:manai_window_height = 15 | endif
if !exists('g:manai_auto_close') | let g:manai_auto_close = 1 | endif

" Comando principal :ManAI
command! -nargs=+ ManAI call ManAI#Query(<q-args>)
command! ManAIWord call ManAI#Query(expand('<cword>'))
command! ManAILine call ManAI#Query(getline('.'))
command! ManAISelection call ManAI#Query(ManAI#GetSelection())
command! ManAIHelp call ManAI#Help()

" Mapeamentos
nmap <leader>ma :ManAIWord<CR>
nmap <leader>ml :ManAILine<CR>
vmap <leader>ms :<C-U>ManAISelection<CR>
nmap <leader>mh :ManAIHelp<CR>

" Funções
function! ManAI#Query(text)
  python3 << EOF
import vim
try:
    from manai_client import manai_client
    question = vim.eval('a:text')
    result = manai_client.query(question)
    response = result.get('response', result.get('error', 'Sem resposta.'))
except Exception as e:
    response = f"Erro ao consultar: {str(e)}"

# Exibir resultado no Vim
bufname = '__ManAI__'
try:
    import vim
    for b in vim.buffers:
        if b.name and bufname in b.name:
            b[:] = response.splitlines()
            break
    else:
        vim.command('new')
        vim.command(f'rename {bufname}')
        vim.current.buffer[:] = response.splitlines()

    vim.command(f'resize {vim.eval("g:manai_window_height")}')
    if int(vim.eval("g:manai_auto_close")):
        vim.command('nnoremap <buffer> q :close<CR>')
except Exception as e:
    print("Erro ao exibir resposta:", e)
EOF
endfunction

function! ManAI#GetSelection()
  let old_reg = getreg('"')
  normal! gvy
  let selected = getreg('"')
  call setreg('"', old_reg)
  return selected
endfunction

function! ManAI#Help()
  echo "ManAI Vim Plugin - Comandos disponíveis:"
  echo ":ManAI <pergunta>      - Fazer consulta personalizada"
  echo ":ManAIWord             - Consultar palavra sob o cursor"
  echo ":ManAILine             - Consultar linha atual"
  echo ":ManAISelection        - Consultar selecção visual"
  echo ":ManAIHelp             - Mostrar esta ajuda"
endfunction
