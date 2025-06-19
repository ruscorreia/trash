#!/usr/bin/env python3
"""
ManAI Vim Integration - Cliente Python Standalone
Versão: 1.0.0
Autor: EduTech Angola

Este script pode ser usado independentemente ou integrado com o plugin Vim.
"""

import sys
import json
import urllib.request
import urllib.parse
import argparse
import os
import configparser
from pathlib import Path

class ManAIVimClient:
    def __init__(self, config_file=None):
        self.config_file = config_file or os.path.expanduser('~/.manai_config')
        self.config = self.load_config()
        
    def load_config(self):
        """Carregar configuração do ficheiro"""
        config = configparser.ConfigParser()
        
        # Configurações padrão
        defaults = {
            'api_url': 'https://manai-agent-function-app.azurewebsites.net/api/ManaiAgentHttpTrigger',
            'function_key': '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA==',
            'language': 'pt',
            'timeout': '30',
            'cache_enabled': 'true',
            'max_cache_size': '50'
        }
        
        config['DEFAULT'] = defaults
        
        # Carregar configuração do utilizador se existir
        if os.path.exists(self.config_file):
            config.read(self.config_file)
        else:
            # Criar ficheiro de configuração padrão
            self.save_config(config)
            
        return config
    
    def save_config(self, config=None):
        """Guardar configuração no ficheiro"""
        if config is None:
            config = self.config
            
        os.makedirs(os.path.dirname(self.config_file), exist_ok=True)
        with open(self.config_file, 'w') as f:
            config.write(f)
    
    def query_manai(self, question, language=None):
        """Fazer consulta ao ManAI"""
        api_url = self.config.get('DEFAULT', 'api_url')
        function_key = self.config.get('DEFAULT', 'function_key')
        lang = language or self.config.get('DEFAULT', 'language')
        timeout = int(self.config.get('DEFAULT', 'timeout'))
        
        headers = {
            'Content-Type': 'application/json',
            'x-functions-key': function_key,
            'User-Agent': 'ManAI-Vim-Client/1.0.0'
        }
        
        data = {
            'message': question,
            'language': lang,
            'source': 'vim-plugin'
        }
        
        try:
            req = urllib.request.Request(
                api_url,
                data=json.dumps(data).encode('utf-8'),
                headers=headers,
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=timeout) as response:
                result = json.loads(response.read().decode('utf-8'))
                return {
                    'success': True,
                    'response': result.get('response', 'Sem resposta'),
                    'metadata': result.get('metadata', {})
                }
        
        except urllib.error.HTTPError as e:
            error_msg = f'Erro HTTP {e.code}: {e.reason}'
            if e.code == 401:
                error_msg += ' (Chave de função inválida)'
            elif e.code == 429:
                error_msg += ' (Muitas consultas - tente novamente mais tarde)'
            return {'success': False, 'error': error_msg}
        
        except urllib.error.URLError as e:
            return {'success': False, 'error': f'Erro de conexão: {e.reason}'}
        
        except Exception as e:
            return {'success': False, 'error': f'Erro inesperado: {str(e)}'}
    
    def format_response(self, response_data, format_type='plain'):
        """Formatar resposta para diferentes contextos"""
        if not response_data['success']:
            return f"❌ {response_data['error']}"
        
        response = response_data['response']
        
        if format_type == 'vim':
            # Formato para exibição no Vim
            lines = []
            lines.append('╭─ ManAI Response ─╮')
            lines.append('│')
            
            # Quebrar texto em linhas
            for line in response.split('\n'):
                if len(line) > 70:
                    # Quebrar linhas longas
                    words = line.split(' ')
                    current_line = ''
                    for word in words:
                        if len(current_line + word) > 70:
                            lines.append(f'│ {current_line.strip()}')
                            current_line = word + ' '
                        else:
                            current_line += word + ' '
                    if current_line.strip():
                        lines.append(f'│ {current_line.strip()}')
                else:
                    lines.append(f'│ {line}')
            
            lines.append('│')
            lines.append('╰─────────────────╯')
            return '\n'.join(lines)
        
        elif format_type == 'markdown':
            # Formato Markdown
            return f"## ManAI Response\n\n{response}\n"
        
        else:
            # Formato simples
            return response
    
    def interactive_mode(self):
        """Modo interactivo para testes"""
        print("🤖 ManAI Vim Client - Modo Interactivo")
        print("Digite 'quit' para sair, 'config' para configuração")
        print("-" * 50)
        
        while True:
            try:
                question = input("\n💬 Pergunta: ").strip()
                
                if question.lower() in ['quit', 'exit', 'q']:
                    print("👋 Até logo!")
                    break
                
                if question.lower() == 'config':
                    self.show_config()
                    continue
                
                if not question:
                    continue
                
                print("🔍 Consultando ManAI...")
                result = self.query_manai(question)
                
                if result['success']:
                    print(f"\n✅ Resposta:\n{result['response']}")
                else:
                    print(f"\n❌ Erro: {result['error']}")
                    
            except KeyboardInterrupt:
                print("\n👋 Até logo!")
                break
            except EOFError:
                break
    
    def show_config(self):
        """Mostrar configuração actual"""
        print("\n⚙️  Configuração actual:")
        print("-" * 30)
        for key, value in self.config['DEFAULT'].items():
            if 'key' in key.lower():
                # Mascarar chaves sensíveis
                masked_value = value[:8] + '...' + value[-8:] if len(value) > 16 else '***'
                print(f"{key}: {masked_value}")
            else:
                print(f"{key}: {value}")
        print(f"\nFicheiro de configuração: {self.config_file}")
    
    def test_connection(self):
        """Testar conexão com a API"""
        print("🔗 Testando conexão com ManAI...")
        
        result = self.query_manai("teste de conexão")
        
        if result['success']:
            print("✅ Conexão bem-sucedida!")
            print(f"📝 Resposta: {result['response'][:100]}...")
            return True
        else:
            print(f"❌ Falha na conexão: {result['error']}")
            return False

def main():
    parser = argparse.ArgumentParser(
        description='ManAI Vim Client - Assistente de comandos Linux para Vim',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos de uso:
  %(prog)s "como listar ficheiros"
  %(prog)s --interactive
  %(prog)s --test
  %(prog)s --format vim "explicar comando ls"
        """
    )
    
    parser.add_argument(
        'question', 
        nargs='?', 
        help='Pergunta para o ManAI'
    )
    
    parser.add_argument(
        '--language', '-l',
        default=None,
        choices=['pt', 'en', 'es', 'fr', 'de', 'it', 'ru', 'zh', 'ja', 'ko'],
        help='Idioma da resposta'
    )
    
    parser.add_argument(
        '--format', '-f',
        default='plain',
        choices=['plain', 'vim', 'markdown'],
        help='Formato da resposta'
    )
    
    parser.add_argument(
        '--interactive', '-i',
        action='store_true',
        help='Modo interactivo'
    )
    
    parser.add_argument(
        '--test', '-t',
        action='store_true',
        help='Testar conexão'
    )
    
    parser.add_argument(
        '--config', '-c',
        help='Ficheiro de configuração personalizado'
    )
    
    parser.add_argument(
        '--show-config',
        action='store_true',
        help='Mostrar configuração actual'
    )
    
    args = parser.parse_args()
    
    # Criar cliente
    client = ManAIVimClient(config_file=args.config)
    
    # Processar argumentos
    if args.show_config:
        client.show_config()
        return
    
    if args.test:
        success = client.test_connection()
        sys.exit(0 if success else 1)
    
    if args.interactive:
        client.interactive_mode()
        return
    
    if not args.question:
        parser.print_help()
        return
    
    # Fazer consulta
    result = client.query_manai(args.question, args.language)
    formatted_response = client.format_response(result, args.format)
    
    print(formatted_response)
    
    # Exit code baseado no sucesso
    sys.exit(0 if result['success'] else 1)

if __name__ == '__main__':
    main()

