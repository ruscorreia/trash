" ManAI Vim Plugin - Versão Corrigida
" Integração do assistente de comandos Linux ManAI com Vim/Neovim
" Autor: EduTech Angola
" Licença: MIT
" Versão: 1.0.0

if exists('g:loaded_manai')
  finish
endif
let g:loaded_manai = 1

" Verificar se Python está disponível
if !has('python3')
  echohl ErrorMsg
  echomsg 'ManAI: Python 3 é obrigatório'
  echohl None
  finish
endif

" Configurações padrão
if !exists('g:manai_language')
  let g:manai_language = 'pt'
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

if !exists('g:manai_cache_enabled')
  let g:manai_cache_enabled = 1
endif

if !exists('g:manai_timeout')
  let g:manai_timeout = 30
endif

" Inicializar Python
python3 << EOF
import vim
import json
import urllib.request
import urllib.parse
import urllib.error
import sys
import os
import hashlib
import time
from pathlib import Path

class ManaiClient:
    def __init__(self):
        self.api_url = vim.eval('g:manai_api_url')
        self.function_key = vim.eval('g:manai_function_key')
        self.language = vim.eval('g:manai_language')
        self.timeout = int(vim.eval('g:manai_timeout'))
        self.cache_enabled = bool(int(vim.eval('g:manai_cache_enabled')))
        self.cache_dir = Path.home() / '.cache' / 'manai-vim'
        self.history_file = self.cache_dir / 'history.json'
        
        # Criar directório de cache
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Carregar histórico
        self.history = self._load_history()
    
    def _load_history(self):
        """Carregar histórico de consultas"""
        try:
            if self.history_file.exists():
                with open(self.history_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception:
            pass
        return []
    
    def _save_history(self):
        """Guardar histórico de consultas"""
        try:
            with open(self.history_file, 'w', encoding='utf-8') as f:
                json.dump(self.history[-100:], f, ensure_ascii=False, indent=2)
        except Exception:
            pass
    
    def _get_cache_key(self, question):
        """Gerar chave de cache para pergunta"""
        content = f"{question}:{self.language}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    def _get_from_cache(self, question):
        """Obter resposta do cache"""
        if not self.cache_enabled:
            return None
        
        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        try:
            if cache_file.exists():
                # Verificar se cache não expirou (24 horas)
                if time.time() - cache_file.stat().st_mtime < 86400:
                    with open(cache_file, 'r', encoding='utf-8') as f:
                        return json.load(f)
        except Exception:
            pass
        
        return None
    
    def _save_to_cache(self, question, response):
        """Guardar resposta no cache"""
        if not self.cache_enabled:
            return
        
        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        try:
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(response, f, ensure_ascii=False, indent=2)
        except Exception:
            pass
    
    def query(self, question):
        """Fazer consulta ao ManAI"""
        # Verificar cache primeiro
        cached_response = self._get_from_cache(question)
        if cached_response:
            return cached_response
        
        # Preparar dados da requisição
        data = {
            "message": question,
            "language": self.language,
            "session_id": "vim-session",
            "user_id": "vim-user"
        }
        
        headers = {
            'Content-Type': 'application/json',
            'x-functions-key': self.function_key,
            'User-Agent': 'ManAI-Vim-Plugin/1.0.0'
        }
        
        try:
            # Fazer requisição
            req = urllib.request.Request(
                self.api_url,
                data=json.dumps(data).encode('utf-8'),
                headers=headers,
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=self.timeout) as response:
                result = json.loads(response.read().decode('utf-8'))
                
                # Guardar no cache e histórico
                self._save_to_cache(question, result)
                self._add_to_history(question, result)
                
                return result
                
        except urllib.error.HTTPError as e:
            error_msg = f"Erro HTTP {e.code}: {e.reason}"
            if e.code == 400:
                error_msg += "\nVerifique se a pergunta está correcta."
            elif e.code == 401:
                error_msg += "\nChave de API inválida."
            elif e.code == 429:
                error_msg += "\nMuitas requisições. Tente novamente mais tarde."
            elif e.code >= 500:
                error_msg += "\nErro no servidor. Tente novamente mais tarde."
            
            return {"error": error_msg}
            
        except urllib.error.URLError as e:
            return {"error": f"Erro de conexão: {e.reason}"}
            
        except Exception as e:
            return {"error": f"Erro inesperado: {str(e)}"}
    
    def _add_to_history(self, question, response):
        """Adicionar consulta ao histórico"""
        entry = {
            "timestamp": time.time(),
            "question": question,
            "response": response.get("response", ""),
            "language": self.language
        }
        
        self.history.append(entry)
        self._save_history()
    
    def get_history(self, limit=10):
        """Obter histórico de consultas"""
        return self.history[-limit:]
    
    def clear_cache(self):
        """Limpar cache"""
        try:
            for cache_file in self.cache_dir.glob("*.json"):
                if cache_file.name != "history.json":
                    cache_file.unlink()
            return True
        except Exception:
            return False

# Instância global do cliente
manai_client = ManaiClient()
EOF

" Função principal para consultas
function! ManaiQuery(question) abort
  if empty(a:question)
    echohl ErrorMsg
    echomsg 'ManAI: Pergunta não pode estar vazia'
    echohl None
    return
  endif

  echo 'ManAI: Consultando...'
  
  python3 << EOF
question = vim.eval('a:question')
result = manai_client.query(question)

# Guardar resultado numa variável Vim
vim.command(f"let g:manai_last_result = {json.dumps(json.dumps(result))}")
EOF

  " Processar resultado
  let l:result = json_decode(g:manai_last_result)
  
  if has_key(l:result, 'error')
    call s:ShowError(l:result.error)
  else
    call s:ShowResponse(l:result)
  endif
endfunction

" Mostrar resposta numa janela
function! s:ShowResponse(result) abort
  " Criar janela de resultado
  let l:response = get(a:result, 'response', 'Sem resposta')
  
  " Dividir resposta em linhas
  let l:lines = split(l:response, '\n')
  
  " Criar nova janela
  if has('nvim')
    " Neovim - usar janela flutuante
    call s:ShowFloatingWindow(l:lines)
  else
    " Vim - usar split horizontal
    call s:ShowSplitWindow(l:lines)
  endif
endfunction

" Janela flutuante para Neovim
function! s:ShowFloatingWindow(lines) abort
  let l:width = min([max(map(copy(a:lines), 'len(v:val)')), &columns - 4])
  let l:height = min([len(a:lines), g:manai_window_height])
  
  let l:opts = {
    \ 'relative': 'editor',
    \ 'width': l:width,
    \ 'height': l:height,
    \ 'col': (&columns - l:width) / 2,
    \ 'row': (&lines - l:height) / 2,
    \ 'style': 'minimal',
    \ 'border': 'rounded'
    \ }
  
  let l:buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(l:buf, 0, -1, v:true, a:lines)
  call nvim_buf_set_option(l:buf, 'filetype', 'manai')
  call nvim_buf_set_option(l:buf, 'modifiable', v:false)
  
  let l:win = nvim_open_win(l:buf, v:true, l:opts)
  
  " Mapeamentos para fechar janela
  nnoremap <buffer><silent> q :close<CR>
  nnoremap <buffer><silent> <Esc> :close<CR>
  
  " Auto-fechar se configurado
  if g:manai_auto_close
    autocmd CursorMoved <buffer> close
  endif
endfunction

" Janela split para Vim
function! s:ShowSplitWindow(lines) abort
  " Criar split horizontal
  execute 'botright ' . g:manai_window_height . 'split __ManAI_Response__'
  
  " Configurar buffer
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nowrap
  setlocal filetype=manai
  setlocal nomodifiable
  
  " Inserir conteúdo
  setlocal modifiable
  call setline(1, a:lines)
  setlocal nomodifiable
  
  " Mapeamentos para fechar janela
  nnoremap <buffer><silent> q :close<CR>
  nnoremap <buffer><silent> <Esc> :close<CR>
  
  " Auto-fechar se configurado
  if g:manai_auto_close
    autocmd CursorMoved <buffer> close
  endif
  
  " Voltar à janela anterior
  wincmd p
endfunction

" Mostrar erro
function! s:ShowError(error) abort
  echohl ErrorMsg
  echomsg 'ManAI: ' . a:error
  echohl None
endfunction

" Obter palavra sob cursor
function! ManaiQueryWord() abort
  let l:word = expand('<cword>')
  if empty(l:word)
    echohl ErrorMsg
    echomsg 'ManAI: Nenhuma palavra sob cursor'
    echohl None
    return
  endif
  
  call ManaiQuery('Como usar o comando ' . l:word . '?')
endfunction

" Obter linha actual
function! ManaiQueryLine() abort
  let l:line = getline('.')
  if empty(trim(l:line))
    echohl ErrorMsg
    echomsg 'ManAI: Linha actual está vazia'
    echohl None
    return
  endif
  
  call ManaiQuery('Explicar este comando: ' . l:line)
endfunction

" Obter selecção visual
function! ManaiQuerySelection() abort
  let l:selection = s:GetVisualSelection()
  if empty(l:selection)
    echohl ErrorMsg
    echomsg 'ManAI: Nenhuma selecção'
    echohl None
    return
  endif
  
  call ManaiQuery('Explicar este código: ' . l:selection)
endfunction

" Obter texto seleccionado
function! s:GetVisualSelection() abort
  let [l:line_start, l:column_start] = getpos("'<")[1:2]
  let [l:line_end, l:column_end] = getpos("'>")[1:2]
  let l:lines = getline(l:line_start, l:line_end)
  
  if len(l:lines) == 0
    return ''
  endif
  
  let l:lines[-1] = l:lines[-1][: l:column_end - (&selection == 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:column_start - 1:]
  
  return join(l:lines, '\n')
endfunction

" Mostrar histórico
function! ManaiHistory() abort
  python3 << EOF
history = manai_client.get_history(20)
if history:
    lines = ["=== ManAI - Histórico de Consultas ===", ""]
    for i, entry in enumerate(reversed(history), 1):
        timestamp = time.strftime("%Y-%m-%d %H:%M", time.localtime(entry['timestamp']))
        lines.append(f"{i:2d}. [{timestamp}] {entry['question']}")
        lines.append(f"    → {entry['response'][:100]}{'...' if len(entry['response']) > 100 else ''}")
        lines.append("")
    
    vim.command(f"let g:manai_history_lines = {json.dumps(lines)}")
else:
    vim.command("let g:manai_history_lines = ['=== ManAI - Histórico Vazio ===']")
EOF

  " Mostrar histórico numa janela
  if has('nvim')
    call s:ShowFloatingWindow(g:manai_history_lines)
  else
    call s:ShowSplitWindow(g:manai_history_lines)
  endif
endfunction

" Limpar cache
function! ManaiClearCache() abort
  python3 << EOF
success = manai_client.clear_cache()
vim.command(f"let g:manai_cache_cleared = {1 if success else 0}")
EOF

  if g:manai_cache_cleared
    echo 'ManAI: Cache limpo com sucesso'
  else
    echohl ErrorMsg
    echomsg 'ManAI: Erro ao limpar cache'
    echohl None
  endif
endfunction

" Mostrar ajuda
function! ManaiHelp() abort
  let l:help_lines = [
    \ '=== ManAI Vim Plugin - Ajuda ===',
    \ '',
    \ 'COMANDOS:',
    \ '  :ManAI <pergunta>     - Fazer consulta ao ManAI',
    \ '  :ManAIWord           - Consultar palavra sob cursor',
    \ '  :ManAILine           - Consultar linha actual',
    \ '  :ManAISelection      - Consultar selecção visual',
    \ '  :ManAIHistory        - Ver histórico de consultas',
    \ '  :ManAIClearCache     - Limpar cache',
    \ '  :ManAIHelp           - Mostrar esta ajuda',
    \ '',
    \ 'MAPEAMENTOS PADRÃO:',
    \ '  <leader>ma           - Consultar palavra sob cursor',
    \ '  <leader>ml           - Consultar linha actual',
    \ '  <leader>ms           - Consultar selecção (modo visual)',
    \ '  <leader>mh           - Mostrar ajuda',
    \ '',
    \ 'CONFIGURAÇÕES:',
    \ '  g:manai_language     - Idioma das respostas (padrão: "pt")',
    \ '  g:manai_window_height - Altura da janela (padrão: 15)',
    \ '  g:manai_auto_close   - Fechar automaticamente (padrão: 1)',
    \ '  g:manai_cache_enabled - Activar cache (padrão: 1)',
    \ '  g:manai_timeout      - Timeout em segundos (padrão: 30)',
    \ '',
    \ 'EXEMPLOS:',
    \ '  :ManAI como listar ficheiros',
    \ '  :ManAI explicar comando grep',
    \ '  :ManAI como usar find com regex',
    \ '',
    \ 'Para mais informação: https://github.com/ruscorreia/manai-vim-plugin'
    \ ]
  
  if has('nvim')
    call s:ShowFloatingWindow(l:help_lines)
  else
    call s:ShowSplitWindow(l:help_lines)
  endif
endfunction

" Comandos
command! -nargs=+ ManAI call ManaiQuery(<q-args>)
command! ManAIWord call ManaiQueryWord()
command! ManAILine call ManaiQueryLine()
command! ManAISelection call ManaiQuerySelection()
command! ManAIHistory call ManaiHistory()
command! ManAIClearCache call ManaiClearCache()
command! ManAIHelp call ManaiHelp()

" Mapeamentos padrão
if !exists('g:manai_no_default_mappings')
  nnoremap <silent> <leader>ma :ManAIWord<CR>
  nnoremap <silent> <leader>ml :ManAILine<CR>
  vnoremap <silent> <leader>ms :ManAISelection<CR>
  nnoremap <silent> <leader>mh :ManAIHelp<CR>
endif

" Auto-comandos
augroup ManAI
  autocmd!
  " Limpar variáveis temporárias ao sair
  autocmd VimLeave * python3 del manai_client
augroup END

" Mensagem de carregamento
if !exists('g:manai_quiet')
  echo 'ManAI Vim Plugin carregado. Use :ManAIHelp para ajuda.'
endif

