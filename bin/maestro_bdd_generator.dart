import 'dart:io';

// IMPORTANTE: Importe a biblioteca que criamos na pasta lib/
import 'package:maestro_bdd_generator/maestro_bdd_generator.dart';

void main(List<String> arguments) async {
  // =========================================================================
  // 1. VERIFICAÇÃO DO COMANDO DE AJUDA (--help)
  // =========================================================================
  if (arguments.contains('--help') || arguments.contains('-h') || arguments.isEmpty && !await Directory('integration_test/').exists()) {
    _exibirMenuDeAjuda();
    return; // Encerra o script aqui
  }

  // =========================================================================
  // 2. LEITURA DOS ARGUMENTOS DO TERMINAL
  // =========================================================================
  String inputPath = 'integration_test/'; // Caminho padrão
  String? appIdPassado;

  for (int i = 0; i < arguments.length; i++) {
    if ((arguments[i] == '--input' || arguments[i] == '-i') && i + 1 < arguments.length) {
      inputPath = arguments[i + 1];
    } else if (arguments[i] == '--app-id' && i + 1 < arguments.length) {
      appIdPassado = arguments[i + 1];
    }
  }


  // =========================================================================
  // 3. EXECUÇÃO DA LÓGICA
  // =========================================================================
  if (await FileSystemEntity.isDirectory(inputPath)) {
    await gerarLoteDeArquivos(inputPath, appIdPassado);
    
  } else if (await FileSystemEntity.isFile(inputPath)) {
    if (!inputPath.endsWith('.feature')) {
      print('❌ O arquivo de entrada deve ter a extensão .feature');
      return;
    }
    
    // Removida a linha que criava o outputPath. Agora passamos apenas o inputFile!
    await processarTemplate(File(inputPath), appIdPassado);
    
  } else {
    print('❌ Caminho não encontrado: $inputPath');
    print('💡 Dica: Digite "maestro_gherkin --help" para ver como usar.');
  }
}

// =========================================================================
// FUNÇÃO DO MENU DE AJUDA
// =========================================================================
void _exibirMenuDeAjuda() {
  print('''
=========================================================
🤖 Maestro BDD CLI - Documentação
=========================================================
Gera templates de teste do Maestro (.yaml) a partir de 
arquivos BDD (.feature) com Smart Merge.

Uso padrão:
  maestro_bdd [opções]

Opções disponíveis:
  -h, --help       Mostra esta tela de ajuda.
  
  -i, --input      Caminho do arquivo .feature ou pasta. 
                   (Padrão: "integration_test/")
                   
      --app-id     Define o ID do aplicativo (ex: com.app.id).
                   Opcional caso o arquivo .yaml já exista.

Exemplos práticos:
  1. Gerar todos os arquivos da pasta padrão:
     maestro_bdd --app-id com.suaempresa.app

  2. Gerar a partir de uma pasta específica:
     maestro_bdd --input features/ --app-id com.suaempresa.app

  3. Atualizar um único arquivo (Smart Merge):
     maestro_bdd --input integration_test/login.feature
=========================================================
''');
}