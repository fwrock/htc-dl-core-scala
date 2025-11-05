# Guia de Publicação da Biblioteca HTCDL

Este guia explica como publicar a biblioteca `htc-dl` no Maven Central e Scaladex.

## 📋 Pré-requisitos

### 1. Conta no Sonatype (Maven Central)

1. **Criar conta**: https://s01.oss.sonatype.org/
2. **Criar um ticket JIRA** para registrar seu groupId:
   - Acesse: https://issues.sonatype.org/secure/CreateIssue.jspa
   - Project: `Community Support - Open Source Project Repository Hosting (OSSRH)`
   - Issue Type: `New Project`
   - Group Id: `io.github.fwrock`
   - Project URL: `https://github.com/fwrock/htc-dl`
   - SCM URL: `https://github.com/fwrock/htc-dl.git`
   
3. **Verificar propriedade do GitHub**:
   - Eles pedirão para criar um repo público chamado `OSSRH-xxxxx` (número do ticket)
   - Ou adicionar o ticket number na descrição do repo

### 2. Configurar GPG (Assinatura de Pacotes)

```bash
# Instalar GPG (se não tiver)
sudo apt-get install gnupg  # Ubuntu/Debian
brew install gnupg          # macOS

# Gerar chave GPG
gpg --gen-key
# Siga as instruções (use seu email real)

# Listar chaves
gpg --list-keys

# Publicar chave pública no servidor
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>

# Exportar chave privada (backup)
gpg --export-secret-keys <KEY_ID> > ~/.gnupg/secring.gpg
```

### 3. Configurar Credenciais

Crie/edite o arquivo `~/.sbt/1.0/sonatype.sbt`:

```scala
credentials += Credentials(
  "Sonatype Nexus Repository Manager",
  "s01.oss.sonatype.org",
  "seu-usuario-sonatype",
  "sua-senha-sonatype"
)
```

## 🚀 Processo de Publicação

### Opção 1: Publicação no Maven Central (Recomendado)

#### Passo 1: Preparar Release

```bash
cd /home/dean/PhD/htc-dl

# 1. Garantir que todos os testes passam
sbt clean test

# 2. Atualizar versão no publish.sbt
# Mudar de "0.1.0-SNAPSHOT" para "0.1.0"

# 3. Criar tag de release
git add .
git commit -m "Release version 0.1.0"
git tag -a v0.1.0 -m "Release version 0.1.0"
git push origin main --tags
```

#### Passo 2: Publicar

```bash
# Publicar no Sonatype Staging
sbt publishSigned

# Verificar no Sonatype
# Acesse: https://s01.oss.sonatype.org/
# Login → Staging Repositories → Procure por io.github.fwrock

# Se estiver OK, promover para release
sbt sonatypeRelease

# Ou manualmente no site:
# 1. "Close" o repositório (valida os artefatos)
# 2. "Release" o repositório (publica no Maven Central)
```

#### Passo 3: Aguardar Sincronização

- **Maven Central**: 10-30 minutos
- **Scaladex**: 2-24 horas (indexação automática)

### Opção 2: Publicação Local/GitHub Packages

#### GitHub Packages

1. **Configurar GitHub Token**:
   - GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - Scopes: `write:packages`, `read:packages`

2. **Adicionar configuração** no `publish.sbt`:

```scala
publishTo := Some(
  "GitHub Package Registry" at "https://maven.pkg.github.com/fwrock/htc-dl"
)
credentials += Credentials(
  "GitHub Package Registry",
  "maven.pkg.github.com",
  "fwrock",
  sys.env.getOrElse("GITHUB_TOKEN", "")
)
```

3. **Publicar**:

```bash
export GITHUB_TOKEN="seu-token-aqui"
sbt publish
```

#### Publicação Local (para testes)

```bash
# Publicar no repositório local Maven
sbt publishLocal

# Agora pode usar em outros projetos:
# libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

## 📦 Estrutura de Artefatos

Após publicação, os seguintes artefatos estarão disponíveis:

```
io.github.fwrock:htc-dl_3:0.1.0
├── htc-dl_3-0.1.0.jar           # JAR principal
├── htc-dl_3-0.1.0-sources.jar   # Código fonte
├── htc-dl_3-0.1.0-javadoc.jar   # Documentação
└── htc-dl_3-0.1.0.pom           # Maven POM
```

## 🔍 Verificação no Scaladex

Após publicação no Maven Central, a biblioteca aparecerá automaticamente no Scaladex:

1. **URL esperada**: https://index.scala-lang.org/fwrock/htc-dl
2. **Tempo**: 2-24 horas após release no Maven Central
3. **Metadata**: Importada automaticamente do POM

### Adicionar Badge no README

```markdown
[![Maven Central](https://img.shields.io/maven-central/v/io.github.fwrock/htc-dl_3.svg)](https://maven-badges.herokuapp.com/maven-central/io.github.fwrock/htc-dl_3)
[![Scala Version](https://img.shields.io/badge/scala-3.3.6-red.svg)](https://www.scala-lang.org/)
```

## 📝 Uso da Biblioteca Publicada

Depois de publicada, os usuários podem adicionar ao `build.sbt`:

```scala
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

Ou em `build.gradle` (para projetos Gradle):

```gradle
dependencies {
    implementation 'io.github.fwrock:htc-dl_3:0.1.0'
}
```

## 🔄 Releases Futuras

### Versão Snapshot (desenvolvimento)

```scala
// publish.sbt
ThisBuild / version := "0.2.0-SNAPSHOT"

// Publicar snapshot
sbt publishSigned
// Não precisa de sonatypeRelease para snapshots
```

Usuários podem usar snapshots:

```scala
resolvers += "Sonatype Snapshots" at "https://s01.oss.sonatype.org/content/repositories/snapshots"
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.2.0-SNAPSHOT"
```

### Versionamento Semântico

Siga o [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.2.0): Novas features (backward compatible)
- **PATCH** (0.1.1): Bug fixes

## 🛠️ Automatização com GitHub Actions

Crie `.github/workflows/publish.yml`:

```yaml
name: Publish

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup JDK
        uses: actions/setup-java@v3
        with:
          java-version: '21'
          distribution: 'temurin'
      
      - name: Setup GPG
        run: |
          echo "${{ secrets.PGP_SECRET }}" | base64 --decode | gpg --import --batch
      
      - name: Publish
        run: sbt publishSigned sonatypeRelease
        env:
          SONATYPE_USERNAME: ${{ secrets.SONATYPE_USERNAME }}
          SONATYPE_PASSWORD: ${{ secrets.SONATYPE_PASSWORD }}
          PGP_PASSPHRASE: ${{ secrets.PGP_PASSPHRASE }}
```

## 📊 Checklist de Publicação

- [ ] Todos os testes passando (`sbt test`)
- [ ] Documentação atualizada (README.md)
- [ ] Versão atualizada em `publish.sbt`
- [ ] Changelog atualizado (CHANGELOG.md)
- [ ] Conta Sonatype criada e aprovada
- [ ] GPG key gerada e publicada
- [ ] Credenciais configuradas (`~/.sbt/1.0/sonatype.sbt`)
- [ ] Código commitado e tag criada
- [ ] `sbt publishSigned` executado com sucesso
- [ ] Repository "closed" no Sonatype
- [ ] Repository "released" no Sonatype
- [ ] Artefatos visíveis no Maven Central
- [ ] Biblioteca indexada no Scaladex

## 🔗 Links Úteis

- **Maven Central Search**: https://search.maven.org/
- **Sonatype OSSRH**: https://s01.oss.sonatype.org/
- **Scaladex**: https://index.scala-lang.org/
- **Guia Oficial Sonatype**: https://central.sonatype.org/publish/publish-guide/
- **SBT Sonatype Plugin**: https://github.com/xerial/sbt-sonatype

## 🆘 Troubleshooting

### Erro: "Failed to deploy"
- Verifique se o groupId está aprovado no Sonatype
- Confirme que as credenciais estão corretas

### Erro: "No public key"
- Republique sua chave GPG: `gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>`
- Tente outros servidores: `keys.openpgp.org`, `pgp.mit.edu`

### Erro: "Invalid POM"
- Certifique-se que todos os campos obrigatórios estão preenchidos
- Verifique licenses, developers, scmInfo no `publish.sbt`

### Biblioteca não aparece no Scaladex
- Aguarde 24 horas
- Verifique se está no Maven Central
- Entre em contato: https://github.com/scalacenter/scaladex/issues

## 🎯 Resumo Rápido

```bash
# 1. Setup inicial (uma vez)
# - Criar conta Sonatype
# - Gerar chave GPG
# - Configurar credenciais

# 2. Para cada release
sbt clean test                    # Testar
git tag v0.1.0 && git push --tags # Versionar
sbt publishSigned                 # Publicar
sbt sonatypeRelease               # Promover

# 3. Aguardar
# - Maven Central: 10-30 min
# - Scaladex: 2-24 horas
```

---

**Boa sorte com a publicação! 🚀**
