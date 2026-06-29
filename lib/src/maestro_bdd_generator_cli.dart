import 'dart:io';

// =========================================================================
// METODO 1: GERAR ARQUIVOS EM LOTE (LEITURA DINAMICA DE DIRETORIO)
// =========================================================================
Future<void> gerarLoteDeArquivos(String dirPath, String? appId) async {
  final dir = Directory(dirPath);
  print('📂 Lendo diretório: ${dir.path} em busca de arquivos .feature...\n');

  final List<FileSystemEntity> entities = await dir.list(recursive: true).toList();
  int arquivosProcessados = 0;

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.feature')) {
      await processarTemplate(entity, appId);
      arquivosProcessados++;
    }
  }

  if (arquivosProcessados == 0) {
    print('⚠️ Nenhum arquivo .feature encontrado no diretório: $dirPath');
  } else {
    print('\n🎉 Concluído! $arquivosProcessados arquivo(s) .feature processado(s).');
  }
}

// =========================================================================
// ESTRUTURA DE DADOS PARA ARMAZENAR O CENARIO
// =========================================================================
class ScenarioBlock {
  String name;
  List<String> steps = [];
  ScenarioBlock(this.name);
}

// =========================================================================
// METODO 2: PROCESSAR E DIVIDIR UM ARQUIVO ESPECIFICO
// =========================================================================
Future<void> processarTemplate(File inputFile, String? idPassadoPorComando) async {
  print('\n📄 Lendo Feature: ${inputFile.path}');

  final lines = await inputFile.readAsLines();
  final baseName = inputFile.uri.pathSegments.last.replaceAll('.feature', '');
  final outDir = inputFile.parent.path;

  List<String> featureHeaderLines = [];
  List<ScenarioBlock> scenarios = [];
  ScenarioBlock? currentScenario;

  // ---------------------------------------------------------
  // FASE A: PARSER DO GHERKIN (Separa os cenarios em blocos)
  // ---------------------------------------------------------
  for (var line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    if (trimmed.startsWith('Feature:') ||
        (currentScenario == null && !trimmed.startsWith('Scenario:'))) {
      // Guarda o cabecalho e a descricao da Feature
      featureHeaderLines.add(trimmed);
    } else if (trimmed.startsWith('Scenario:')) {
      // Inicia um novo bloco de cenario
      currentScenario = ScenarioBlock(trimmed);
      scenarios.add(currentScenario);
    } else if (currentScenario != null) {
      // Adiciona os passos ao cenario atual
      currentScenario.steps.add(trimmed);
    }
  }

  // ---------------------------------------------------------
  // FASE B: GERAR OS ARQUIVOS .YAML SEPARADOS
  // ---------------------------------------------------------
  for (int i = 0; i < scenarios.length; i++) {
    var scenario = scenarios[i];
    int scenarioIndex = i + 1;

    // Nomeia como: login_scenario_1.yaml, login_scenario_2.yaml...
    File outputFile = File('$outDir/${baseName}_scenario_$scenarioIndex.yaml');

    // -- ETAPA DE SMART MERGE PARA ESTE ARQUIVO --
    String appIdLine = '';
    Map<String, List<List<String>>> savedCommands = {};

    if (await outputFile.exists()) {
      final existingLines = await outputFile.readAsLines();
      String currentStep = "";

      for (var line in existingLines) {
        if (line.startsWith('appId:')) {
          appIdLine = line;
        } else if (line.startsWith('# 📝 Passo:')) {
          currentStep = line.trim();
          savedCommands[currentStep] ??= [];
          savedCommands[currentStep]!.add([]);
        } else if (currentStep.isNotEmpty &&
            !line.startsWith('# =') &&
            !line.startsWith('# -') &&
            !line.startsWith('---')) {
          // Salva os comandos reais preenchidos pelo dev
          savedCommands[currentStep]!.last.add(line);
        }
      }
    }

    // RESOLUCAO DO APP ID
    if (idPassadoPorComando != null) {
      appIdLine = 'appId: $idPassadoPorComando';
    } else if (appIdLine.isEmpty) {
      appIdLine = 'appId: com.example.app # TODO: Substitua pelo ID real do app';
    }

    // -- MONTAGEM DO ARQUIVO FINAL --
    var yamlBuffer = StringBuffer();
    yamlBuffer.writeln(appIdLine);
    yamlBuffer.writeln('---');

    // Cabecalho da Feature (Mantem o contexto em todos os arquivos)
    yamlBuffer.writeln('\n# ${'=' * 50}');
    for (var fLine in featureHeaderLines) {
      yamlBuffer.writeln('# $fLine');
    }
    yamlBuffer.writeln('# ${'=' * 50}');

    // Titulo do Cenario
    yamlBuffer.writeln('\n# ${'-' * 50}');
    yamlBuffer.writeln('# ${scenario.name}');
    yamlBuffer.writeln('# ${'-' * 50}');

    // Passos do Cenario
    for (var step in scenario.steps) {
      if (step.startsWith('Given ') ||
          step.startsWith('When ') ||
          step.startsWith('Then ') ||
          step.startsWith('And ') ||
          step.startsWith('But ')) {
        String stepKey = '# 📝 Passo: $step';
        yamlBuffer.writeln('\n$stepKey');

        if (savedCommands.containsKey(stepKey) &&
            savedCommands[stepKey]!.isNotEmpty) {
          List<String> commands = savedCommands[stepKey]!.removeAt(0);

          while (commands.isNotEmpty && commands.last.trim().isEmpty) {
            commands.removeLast();
          }
          while (commands.isNotEmpty && commands.first.trim().isEmpty) {
            commands.removeAt(0);
          }

          if (commands.isNotEmpty) {
            for (var cmd in commands) {
              yamlBuffer.writeln(cmd);
            }
          } else {
            yamlBuffer.writeln('# TODO: Cole os comandos do Maestro Studio aqui');
          }
        } else {
          yamlBuffer.writeln('# TODO: Cole os comandos do Maestro Studio aqui');
        }
      } else {
        // Linhas de comentarios soltos dentro do cenario
        yamlBuffer.writeln('# $step');
      }
    }

    await outputFile.writeAsString(yamlBuffer.toString());
    print('   ✅ Arquivo criado: ${outputFile.path}');
  }
}