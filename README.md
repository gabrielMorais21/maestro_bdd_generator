# Maestro BDD Generator

CLI em Dart para transformar cenarios BDD/Gherkin (.feature) em arquivos de teste do Maestro (.yaml), com Smart Merge para preservar comandos ja preenchidos quando voce regenera.

## O que voce consegue fazer

- Ler arquivos .feature (arquivo unico ou pasta).
- Gerar um .yaml por Scenario.
- Manter o contexto da Feature nos arquivos gerados.
- Reaproveitar blocos ja editados manualmente (Smart Merge).
- Definir o appId de saida via argumento.

## Requisitos

- Dart SDK 3.11.5 ou superior.

## Instalar e usar (pub.dev)

Instale o executavel globalmente:

```bash
dart pub global activate maestro_bdd_generator
```

Depois, valide a instalacao:

```bash
maestro_bdd --help
```

Se o comando nao for encontrado, adicione o diretorio de binarios globais ao PATH:

- macOS/Linux: $HOME/.pub-cache/bin
- Windows: %LOCALAPPDATA%\Pub\Cache\bin

## Uso rapido

Comando:

```bash
maestro_bdd [opcoes]
```

Opcoes principais:

- -h, --help: mostra ajuda.
- -i, --input: caminho para arquivo .feature ou pasta (padrao: integration_test/).
- --app-id: define o appId de saida (exemplo: com.suaempresa.app).

## Exemplos prontos

Gerar a partir da pasta padrao (integration_test/):

```bash
maestro_bdd --app-id com.suaempresa.app
```

Gerar a partir de uma pasta personalizada:

```bash
maestro_bdd --input features/ --app-id com.suaempresa.app
```

Gerar para um unico arquivo .feature:

```bash
maestro_bdd --input integration_test/login.feature --app-id com.suaempresa.app
```

## Smart Merge na pratica

Fluxo recomendado:

1. Gere os YAMLs pela primeira vez.
2. Preencha manualmente os comandos do Maestro abaixo dos TODOs.
3. Rode o gerador novamente para o mesmo .feature.

Comportamento esperado:

- Blocos ja preenchidos por passo sao preservados.
- Passos novos recebem TODO automaticamente.
- O YAML continua alinhado ao BDD sem perder trabalho manual.

## Regras do appId

- Se voce passar --app-id, esse valor e usado no YAML.
- Se nao passar --app-id e ja existir YAML com appId, ele e mantido.
- Se nao houver appId existente, o fallback sera:

```yaml
appId: com.example.app # TODO: Substitua pelo ID real do app
```

## Exemplo de entrada (.feature)

```gherkin
Feature: Login
  Como usuario
  Quero entrar no app

Scenario: Login com sucesso
  Given que abri o app
  When informo usuario e senha validos
  Then devo ver a home
```

## Exemplo de saida (.yaml resumido)

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

# Passo: Given que abri o app
# TODO: Cole os comandos do Maestro Studio aqui

# Passo: When informo usuario e senha validos
# TODO: Cole os comandos do Maestro Studio aqui

# Passo: Then devo ver a home
# TODO: Cole os comandos do Maestro Studio aqui
```

## Problemas comuns

Erro: Caminho nao encontrado

- Verifique o valor de --input.
- Confirme se o arquivo/pasta existe.

Erro: O arquivo de entrada deve ter a extensao .feature

- Use um arquivo .feature valido.

Erro: Nenhum arquivo .feature encontrado no diretorio

- Confirme se a pasta contem arquivos .feature.
- A busca em pastas e recursiva.

## Licenca

MIT