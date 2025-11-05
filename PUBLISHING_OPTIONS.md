# Publicação Rápida - Resumo

## 🚀 Opção 1: Maven Central (Recomendado para bibliotecas públicas)

### Vantagens:
✅ Descoberta automática pelo Scaladex
✅ Repositório padrão da comunidade Scala
✅ Não requer configuração nos projetos usuários
✅ Maior visibilidade

### Passos:
```bash
# 1. Criar conta no Sonatype
https://issues.sonatype.org/secure/Signup!default.jspa

# 2. Criar ticket JIRA para groupId
# Project: OSSRH
# Issue Type: New Project
# Group Id: io.github.fwrock
# Project URL: https://github.com/fwrock/htc-dl

# 3. Configurar GPG
gpg --gen-key
gpg --keyserver keyserver.ubuntu.com --send-keys <KEY_ID>

# 4. Configurar credenciais (~/.sbt/1.0/sonatype.sbt)
credentials += Credentials(
  "Sonatype Nexus Repository Manager",
  "s01.oss.sonatype.org",
  "seu-usuario",
  "sua-senha"
)

# 5. Publicar
./release.sh
# Escolher opção 1 (Maven Central)

# 6. Finalizar no Sonatype
# https://s01.oss.sonatype.org/
# Close → Release
```

### Tempo até disponibilidade:
- Maven Central: 10-30 minutos
- Scaladex: 2-24 horas

---

## 📦 Opção 2: GitHub Packages (Rápido, mas requer configuração)

### Vantagens:
✅ Integrado com GitHub
✅ Configuração simples
✅ Versionamento automático
✅ Privado ou público

### Desvantagens:
❌ Requer autenticação para usar
❌ Não aparece automaticamente no Scaladex
❌ Usuários precisam adicionar resolver customizado

### Passos:
```bash
# 1. Criar GitHub Personal Access Token
# GitHub → Settings → Developer settings → Personal access tokens
# Scopes: write:packages, read:packages

# 2. Configurar token
export GITHUB_TOKEN="seu_token"

# 3. Publicar
./release.sh
# Escolher opção 2 (GitHub Packages)
```

### Uso pelos usuários:
```scala
// build.sbt
resolvers += "GitHub Package Registry" at "https://maven.pkg.github.com/fwrock/htc-dl"
credentials += Credentials(
  "GitHub Package Registry",
  "maven.pkg.github.com",
  "username",
  sys.env("GITHUB_TOKEN")
)
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

---

## 💻 Opção 3: Publicação Local (Apenas para testes)

### Uso:
```bash
# Publicar
./release.sh
# Escolher opção 3 (Local)

# Ou diretamente:
sbt publishLocal
```

### Uso em outros projetos (mesma máquina):
```scala
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

---

## 📊 Comparação

| Critério | Maven Central | GitHub Packages | Local |
|----------|--------------|-----------------|-------|
| Setup inicial | ⭐⭐ Complexo | ⭐⭐⭐ Simples | ⭐⭐⭐⭐ Trivial |
| Visibilidade | ⭐⭐⭐⭐ Alta | ⭐⭐ Média | ⭐ Nenhuma |
| Scaladex | ✅ Automático | ❌ Manual | ❌ Não |
| Facilidade uso | ⭐⭐⭐⭐ Plug & Play | ⭐⭐ Requer config | ⭐⭐⭐⭐ Automático |
| Privacidade | Público | Público/Privado | Privado |
| Recomendado para | Libs públicas | Projetos internos | Desenvolvimento |

---

## 🎯 Recomendação

### Para o projeto HTC-DL:

**Maven Central** é a melhor opção porque:
1. É uma biblioteca pública
2. Quer máxima visibilidade e adoção
3. Aparecerá automaticamente no Scaladex
4. Usuários não precisam de configuração extra
5. É o padrão da comunidade Scala

### Timeline de Publicação no Maven Central:

```
Dia 0: Setup inicial
├─ Criar conta Sonatype (5 min)
├─ Criar ticket JIRA (5 min)
└─ Aguardar aprovação (1-2 dias úteis)

Dia 2: Configuração
├─ Gerar chave GPG (5 min)
├─ Publicar chave (1 min)
└─ Configurar credenciais (2 min)

Dia 2: Primeira publicação
├─ ./release.sh (5 min)
├─ Close no Sonatype (1 min)
├─ Release no Sonatype (1 min)
└─ Aguardar sync (10-30 min)

Dia 3: Indexação
└─ Aparece no Scaladex (2-24h)

TOTAL: 2-3 dias (setup uma única vez)
Próximas releases: 15 minutos!
```

---

## ⚡ Quick Start (Primeira Vez)

```bash
# 1. Se já tem conta Sonatype aprovada e GPG configurado:
./release.sh

# 2. Seguir o prompt interativo
# 3. Escolher Maven Central
# 4. Aguardar sync
# 5. Pronto!
```

---

## 🔗 Links Úteis

- **Guia Completo**: [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md)
- **Sonatype OSSRH**: https://s01.oss.sonatype.org/
- **Criar Ticket**: https://issues.sonatype.org/
- **Scaladex**: https://index.scala-lang.org/
- **Maven Central Search**: https://search.maven.org/
