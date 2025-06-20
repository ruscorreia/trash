import json
import urllib.request
import urllib.parse
import urllib.error
import sys
import os
import hashlib
import time
from pathlib import Path

try:
    import vim
except ImportError:
    vim = None  # Evita erro se executado fora do Vim/Neovim

class ManaiClient:
    def __init__(self):
        if not vim:
            raise RuntimeError("Este script deve ser executado dentro do Vim/Neovim com suporte a Python.")

        self.api_url = vim.eval('g:api_url')
        self.function_key = vim.eval('g:manai_function_key')
        self.language = vim.eval('g:manai_language')
        self.timeout = int(vim.eval('g:manai_timeout'))

        # Converte '1', 'true', 'True' para booleano verdadeiro
        cache_flag = vim.eval('g:manai_cache_enabled').strip().lower()
        self.cache_enabled = cache_flag in ['1', 'true']

        self.cache_dir = Path.home() / '.cache' / 'manai-vim'
        self.history_file = self.cache_dir / 'history.json'

        # Criar diretório de cache
        try:
            self.cache_dir.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            print(f"[Manai] Erro ao criar diretório de cache: {e}")

        # Carregar histórico
        self.history = self._load_history()

    def _load_history(self):
        try:
            if self.history_file.exists():
                with open(self.history_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception as e:
            print(f"[Manai] Erro ao carregar histórico: {e}")
        return []

    def _save_history(self):
        try:
            with open(self.history_file, 'w', encoding='utf-8') as f:
                json.dump(self.history[-100:], f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"[Manai] Erro ao guardar histórico: {e}")

    def _get_cache_key(self, question):
        content = f"{question}:{self.language}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()

    def _get_from_cache(self, question):
        if not self.cache_enabled:
            return None

        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"

        try:
            if cache_file.exists():
                if time.time() - cache_file.stat().st_mtime < 86400:
                    with open(cache_file, 'r', encoding='utf-8') as f:
                        return json.load(f)
        except Exception as e:
            print(f"[Manai] Erro ao ler cache: {e}")

        return None

    def _save_to_cache(self, question, response):
        if not self.cache_enabled:
            return

        cache_key = self._get_cache_key(question)
        cache_file = self.cache_dir / f"{cache_key}.json"

        try:
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(response, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"[Manai] Erro ao guardar cache: {e}")

    def query(self, question):
        cached_response = self._get_from_cache(question)
        if cached_response:
            return cached_response

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
            req = urllib.request.Request(
                self.api_url,
                data=json.dumps(data).encode('utf-8'),
                headers=headers,
                method='POST'
            )

            with urllib.request.urlopen(req, timeout=self.timeout) as response:
                result = json.loads(response.read().decode('utf-8'))

                # Somente adiciona ao histórico se não for erro
                if "error" not in result:
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
            return {"error": f"Erro inesperado ({type(e).__name__}): {e}"}

    def _add_to_history(self, question, response):
        entry = {
            "timestamp": time.time(),
            "question": question,
            "response": response.get("response", ""),
            "language": self.language
        }

        self.history.append(entry)
        self.history = self.history[-100:]
        self._save_history()

    def get_history(self, limit=10):
        return self.history[-limit:]

    def clear_cache(self):
        try:
            for cache_file in self.cache_dir.glob("*.json"):
                if cache_file.name != "history.json":
                    cache_file.unlink()
            return True
        except Exception as e:
            print(f"[Manai] Erro ao limpar cache: {e}")
            return False


# Instância global
manai_client = ManaiClient()
