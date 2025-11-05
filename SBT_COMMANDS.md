# Comandos SBT - Referência Rápida

## 🧪 Testes

```bash
# Rodar todos os testes
sbt test

# Rodar teste específico
sbt "testOnly com.htc.dtl.HtcDtlSpec"

# Rodar testes com pattern
sbt "testOnly *ValidationSpec"

# Rodar testes continuamente (re-run on file change)
sbt ~test

# Rodar teste específico com verbose
sbt "testOnly com.htc.dtl.HtcDtlSpec -- -oD"
```

## 🔨 Build

```bash
# Compilar
sbt compile

# Compilar testes
sbt Test/compile

# Limpar e compilar
sbt clean compile

# Criar JAR
sbt package

# Limpar, testar e empacotar
sbt "clean; test; package"
```

## 📦 Publicação

```bash
# Publicar localmente
sbt publishLocal

# Publicar no Sonatype (staging)
sbt publishSigned

# Release no Sonatype (Maven Central)
sbt sonatypeRelease

# Tudo junto (close + release)
sbt "publishSigned; sonatypeBundleRelease"
```

## 🔍 Informações

```bash
# Mostrar dependências
sbt dependencyTree

# Mostrar versão
sbt version

# Mostrar comandos disponíveis
sbt tasks

# Console interativo
sbt console

# Console do SBT
sbt
```

## 🐛 Debug

```bash
# Modo verbose
sbt -v test

# Modo debug
sbt -debug test

# Mostrar erros de compilação detalhados
sbt "set ThisBuild / scalacOptions += \"-explain\"" compile
```

## 🚀 Integração Contínua

### GitHub Actions

O projeto está configurado com:

- **`.github/workflows/ci.yml`** - Roda em cada push/PR
  - Compila o projeto
  - Roda todos os testes
  - Cria o pacote JAR

- **`.github/workflows/release.yml`** - Roda quando cria tag
  - Roda testes
  - Cria release no GitHub
  - Anexa JARs ao release

### Comandos Git + SBT

```bash
# Testar antes de commit
sbt test && git commit -m "message"

# Release completo
sbt clean test package
git tag -a v0.1.0 -m "Release 0.1.0"
git push origin main --tags
```

## ⚠️ Erros Comuns

### ❌ "tests: command not found"

**Erro:**
```bash
sbt tests
[error] Not a valid command: tests
```

**Solução:**
```bash
sbt test  # Sem 's' no final
```

### ❌ "sbt: command not found" (GitHub Actions)

**Problema:** SBT não está instalado no runner

**Solução:** Já corrigido em `.github/workflows/ci.yml`:
```yaml
- name: Setup JDK 21
  uses: actions/setup-java@v4
  with:
    java-version: '21'
    distribution: 'temurin'
    cache: 'sbt'  # Isso instala e cacheia o SBT
```

### ❌ "Out of memory"

**Solução:**
```bash
# Aumentar heap
export SBT_OPTS="-Xmx2G -Xss2M"
sbt test
```

### ❌ Testes lentos

**Solução:**
```bash
# Desabilitar execução paralela
sbt "set Test / parallelExecution := false" test
```

## 📊 Scripts Úteis

### Criar alias no `.bashrc` ou `.zshrc`:

```bash
# Adicionar ao ~/.bashrc
alias sbtt="sbt test"
alias sbtc="sbt clean compile"
alias sbtct="sbt 'clean; test'"
alias sbtcp="sbt 'clean; test; package'"
alias sbtpl="sbt publishLocal"
```

Depois: `source ~/.bashrc`

Uso:
```bash
sbtt   # Roda testes
sbtcp  # Clean, test e package
```

## 🎯 Workflow Típico

### Desenvolvimento diário:
```bash
# 1. Puxar mudanças
git pull

# 2. Compilar e testar
sbt test

# 3. Fazer mudanças...

# 4. Testar continuamente
sbt ~test

# 5. Commit
sbt test && git commit -m "Add feature"
git push
```

### Criar release:
```bash
# 1. Atualizar versão em build.sbt
# ThisBuild / version := "0.2.0"

# 2. Testar tudo
sbt clean test

# 3. Criar tag e push
git add .
git commit -m "Release 0.2.0"
git tag v0.2.0
git push origin main --tags

# GitHub Actions faz o resto!
```

## 📚 Referências

- [SBT Documentation](https://www.scala-sbt.org/1.x/docs/)
- [SBT Testing](https://www.scala-sbt.org/1.x/docs/Testing.html)
- [Publishing](https://www.scala-sbt.org/1.x/docs/Publishing.html)

---

💡 **Dica:** Use `sbt` (sem argumentos) para entrar no console interativo. Lá você pode executar comandos sem precisar recarregar o projeto toda vez:

```
$ sbt
sbt:htc-dl> test
sbt:htc-dl> package
sbt:htc-dl> publishLocal
```
