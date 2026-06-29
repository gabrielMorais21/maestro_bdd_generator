# Maestro BDD Generator

CLI em Dart para gerar arquivos de teste do Maestro (.yaml) a partir de arquivos BDD/Gherkin (.feature), com suporte a Smart Merge para preservar comandos já preenchidos.

## O que este projeto faz

- Lê arquivos .feature.
- Divide cada Scenario em um arquivo .yaml separado.
- Mantém o contexto da Feature em cada arquivo gerado.
- Preserva comandos já existentes por passo quando você regenera os arquivos (Smart Merge).
- Permite definir o appId via argumento de linha de comando.

## Pré-requisitos

- Dart SDK 3.11.5 ou superior.

## Instalação

### 1. Instalar dependências

No diretório do projeto, execute:

```bash
dart pub get
```

### 2. Executar sem instalar globalmente

```bash
dart run bin/maestro_bdd_generator.dart --help
```

### 3. (Opcional) Ativar como comando global

Este projeto expõe o executável maestro_bdd.

```bash
dart pub global activate --source path .
maestro_bdd --help
```

Se o comando não for encontrado, adicione o diretório de binários globais do Dart ao PATH.

## Uso rápido

Comando padrão:

```bash
maestro_bdd [opcoes]
```

Opções:

- -h, --help: mostra ajuda.
- -i, --input: caminho para arquivo .feature ou pasta.
	- padrão: integration_test/
- --app-id: define o appId de saída (exemplo: com.suaempresa.app).

## Tutoriais

### Tutorial 1: Gerar arquivos a partir da pasta padrão

Quando você roda apenas o comando com app-id, o CLI procura arquivos .feature em integration_test/ (recursivamente).

```bash
maestro_bdd --app-id com.suaempresa.app
```

Resultado esperado:

- Cada Scenario vira um arquivo separado.
- Exemplo: login.feature com 2 cenários gera:
	- login_scenario_1.yaml
	- login_scenario_2.yaml

### Tutorial 2: Usar uma pasta personalizada

```bash
maestro_bdd --input features/ --app-id com.suaempresa.app
```

Use este modo quando seus arquivos .feature não estiverem em integration_test/.

### Tutorial 3: Atualizar um único arquivo .feature

```bash
maestro_bdd --input integration_test/login.feature
```

Recomendado para ciclo rápido de edição de um cenário específico.

### Tutorial 4: Entender o Smart Merge (preservar comandos)

Fluxo sugerido:

1. Gere os YAMLs pela primeira vez.
2. Preencha manualmente os comandos do Maestro abaixo de cada passo marcado com:
	 - # TODO: Cole os comandos do Maestro Studio aqui
3. Rode o gerador novamente para o mesmo .feature.

O que acontece:

- Os blocos já preenchidos para cada passo são reaproveitados.
- Novos passos recebem TODO automaticamente.
- O arquivo continua sincronizado com o BDD, sem perder o trabalho manual.

### Tutorial 5: Controle do appId

Regras:

- Se você passar --app-id, esse valor é usado no YAML.
- Se não passar --app-id e já existir YAML com appId, ele é mantido.
- Se não houver appId existente, o gerador usa fallback:

```yaml
appId: com.example.app # TODO: Substitua pelo ID real do app
```

## Exemplo de arquivo .feature

```gherkin
Feature: Login
	Como usuario
	Quero entrar no app

Scenario: Login com sucesso
	Given que abri o app
	When informo usuario e senha validos
	Then devo ver a home
```

## Exemplo de saída .yaml (resumido)

```yaml
appId: com.suaempresa.app
---

# ==================================================
# Feature: Login
# Como usuario
# Quero entrar no app
# ==================================================

# --------------------------------------------------
# Scenario: Login com sucesso
# --------------------------------------------------

# 📝 Passo: Given que abri o app
# TODO: Cole os comandos do Maestro Studio aqui

# 📝 Passo: When informo usuario e senha validos
# TODO: Cole os comandos do Maestro Studio aqui

# 📝 Passo: Then devo ver a home
# TODO: Cole os comandos do Maestro Studio aqui
```

## Erros comuns e soluções

### Caminho não encontrado

Mensagem:

- Caminho não encontrado

Solução:

- Verifique o valor de --input.
- Confirme se o arquivo/pasta existe.

### Arquivo sem extensão .feature

Mensagem:

- O arquivo de entrada deve ter a extensão .feature

Solução:

- Use um arquivo .feature válido.

### Nenhum arquivo .feature encontrado no diretório

Solução:

- Confirme se a pasta contém arquivos .feature.
- Verifique subpastas (a busca é recursiva).

## Desenvolvimento

### Rodar análise estática

```bash
dart analyze
```

### Rodar testes

```bash
dart test
```

## Estrutura do projeto

```text
bin/
	maestro_bdd_generator.dart      # Entrada do CLI
lib/
	maestro_bdd_generator_cli.dart  # Lógica de geração e Smart Merge
test/
	maestro_bdd_generator_test.dart # Testes
```

## Licença
MIT