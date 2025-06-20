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
from typing import Dict, List, Optional, Union
import traceback

class ManaiClient:
    def __init__(self):
        try:
            self.api_url = vim.eval('g:api_url')
            self.function_key = vim.eval('g:manai_function_key')
            self.language = vim.eval('g:manai_language')
            self.timeout = max(5, int(vim.eval('g:manai_timeout')))  # Mínimo de 5 segundos
            self.cache_enabled = bool(int(vim.eval('g:manai_cache_enabled')))
            
            # Configuração do cache com fallback
            cache_home = os.environ.get('XDG_CACHE_HOME', None)
            if cache_home:
                self.cache_dir = Path(cache_home) / 'manai-vim'
            else:
                self.cache_dir = Path.home() / '.cache' / 'manai-vim'
            
            self.history_file = self.cache_dir / 'history.json'
            
            # Criar diretório de cache de forma segura
            try:
                self.cache_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
            except (OSError, PermissionError) as e:
                print(f"Warning: Could not create cache directory: {str(e)}")
                self.cache_enabled = False
            
            # Carregar histórico de forma segura
            self.history = self._load_history()
            
        except (KeyError, ValueError) as e:
            raise RuntimeError(f"Failed to initialize ManaiClient: {str(e)}")

    def _load_history(self) -> List[Dict]:
        """Carregar histórico de consultas de forma segura"""
        history = []
        if not self.history_file.exists():
            return history
            
        try:
            with open(self.history_file, 'r', encoding='utf-8') as f:
                history = json.load(f)
                if not isinstance(history, list):
                    history = []
        except json.JSONDecodeError:
            print("Warning: History file corrupted, starting fresh")
        except (IOError, OSError) as e:
            print(f"Warning: Could not load history: {str(e)}")
        
        return history
    
    def _save_history(self) -> bool:
        """Guardar histórico de consultas de forma segura"""
        if not self.history:
            return False
            
        try:
            # Garantir que não exceda o limite
            history_to_save = self.history[-100:]
            
            # Escrever para arquivo temporário primeiro
            temp_file = self.history_file.with_suffix('.tmp')
            
            with open(temp_file, 'w', encoding='utf-8') as f:
                json.dump(history_to_save, f, ensure_ascii=False, indent=2)
            
            # Substituir o arquivo original
            temp_file.replace(self.history_file)
            return True
            
        except (IOError, OSError, json.JSONEncodeError) as e:
            print(f"Error saving history: {str(e)}")
            return False
    
    def _get_cache_key(self, question: str) -> str:
        """Gerar chave de cache para pergunta de forma consistente"""
        content = f"{question}:{self.language}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    def _get_from_cache(self, question: str) -> Optional[Dict]:
        """Obter resposta do cache de forma segura"""
        if not self.cache_enabled:
            return None
        
        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        try:
            if cache_file.exists():
                # Verificar se cache não expirou (24 horas)
                if time.time() - cache_file.stat().st_mtime < 86400:
                    with open(cache_file, 'r', encoding='utf-8') as f:
                        cached_data = json.load(f)
                        if isinstance(cached_data, dict):
                            return cached_data
        except (json.JSONDecodeError, IOError, OSError) as e:
            print(f"Warning: Cache corrupted for {cache_key}: {str(e)}")
            try:
                cache_file.unlink()  # Remove cache inválido
            except OSError:
                pass
        
        return None
    
    def _save_to_cache(self, question: str, response: Dict) -> bool:
        """Guardar resposta no cache de forma segura"""
        if not self.cache_enabled or not response:
            return False
        
        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        try:
            # Escrever para arquivo temporário primeiro
            temp_file = cache_file.with_suffix('.tmp')
            
            with open(temp_file, 'w', encoding='utf-8') as f:
                json.dump(response, f, ensure_ascii=False, indent=2)
            
            # Substituir o arquivo original
            temp_file.replace(cache_file)
            return True
            
        except (IOError, OSError, json.JSONEncodeError) as e:
            print(f"Error saving to cache: {str(e)}")
            return False
    
    def query(self, question: str) -> Dict:
        """Fazer consulta ao ManAI de forma segura"""
        if not question.strip():
            return {"error": "Pergunta não pode estar vazia"}
        
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
            # Fazer requisição com timeout
            req = urllib.request.Request(
                self.api_url,
                data=json.dumps(data).encode('utf-8'),
                headers=headers,
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=self.timeout) as response:
                if response.status != 200:
                    return {"error": f"Resposta inesperada do servidor: {response.status}"}
                
                result = json.loads(response.read().decode('utf-8'))
                
                if not isinstance(result, dict):
                    return {"error": "Resposta do servidor em formato inválido"}
                
                # Guardar no cache e histórico
                self._save_to_cache(question, result)
                self._add_to_history(question, result)
                
                return result
                
        except urllib.error.HTTPError as e:
            error_msg = f"Erro HTTP {e.code}: {e.reason}"
            if e.code == 400:
                error_msg += "\nVerifique se a pergunta está correta."
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
            traceback.print_exc()
            return {"error": f"Erro inesperado: {str(e)}"}
    
    def _add_to_history(self, question: str, response: Dict) -> None:
        """Adicionar consulta ao histórico de forma segura"""
        if not question or not isinstance(response, dict):
            return
            
        entry = {
            "timestamp": time.time(),
            "question": question,
            "response": response.get("response", ""),
            "language": self.language
        }
        
        self.history.append(entry)
        self._save_history()
    
    def get_history(self, limit: int = 10) -> List[Dict]:
        """Obter histórico de consultas de forma segura"""
        return self.history[-limit:] if self.history else []
    
    def clear_cache(self) -> bool:
        """Limpar cache de forma segura"""
        if not self.cache_dir.exists():
            return True
            
        success = True
        try:
            for cache_file in self.cache_dir.glob("*.json"):
                if cache_file.name != "history.json":
                    try:
                        cache_file.unlink()
                    except OSError:
                        success = False
        except OSError:
            success = False
            
        return success

# Instância do cliente (não mais global)
def get_manai_client() -> ManaiClient:
    """Factory function para obter uma instância do cliente"""
    return ManaiClient()