# Como Publicar no Scaladex

## ✨ Método Recomendado: Maven Central (Indexação Automática)

O Scaladex monitora o Maven Central e indexa automaticamente novas bibliotecas Scala.

### 📋 Pré-requisitos

1. **Conta no Sonatype OSS**
   - Acesse: https://issues.sonatype.org/secure/Signup!default.jspa
   - Crie uma conta gratuita

2. **Ticket JIRA para registrar seu groupId**
   - Acesse: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
   - Preencha:
     ```
     Project: Community Support - Open Source Project Repository Hosting (OSSRH)
     Issue Type: New Project
     Summary: Request for io.github.fwrock
     Group Id: io.github.fwrock
     Project URL: https://github.com/fwrock/htc-dl
     SCM URL: https://github.com/fwrock/htc-dl.git
     Username(s): [seu username Sonatype]
     ```

3. **Verificação do GitHub**
   - Eles pedirão para verificar que você é dono do repo
   - Opção A: Criar repo público temporário `OSSRH-XXXXX` (número do ticket)
   - Opção B: Adicionar o número do ticket na descrição do repo htc-dl

### 🔐 Configurar GPG (Assinatura Digital)

```bash
# 1. Instalar GPG (se necessário)
sudo apt-get install gnupg  # Ubuntu/Debian
# ou
brew install gnupg          # macOS

# 2. Gerar chave GPG
gpg --gen-key
# Escolha:
# - RSA and RSA (default)
# - 4096 bits
# - Não expira (ou prazo longo)
# - Seu nome e email real

# 3. Listar suas chaves
gpg --list-keys
# Anote o KEY_ID (linha pub, últimos 8 caracteres)

# 4. Publicar chave pública (IMPORTANTE!)
gpg --keyserver keyserver.ubuntu.com --send-keys SEU_KEY_ID

# Tente também outros servidores:
gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID
gpg --keyserver pgp.mit.edu --send-keys SEU_KEY_ID

# 5. Backup da chave privada (segurança)
gpg --export-secret-keys SEU_KEY_ID > ~/.gnupg/private-key-backup.asc
```

### 🔑 Configurar Credenciais SBT

Crie o arquivo `~/.sbt/1.0/sonatype.sbt`:

```scala
credentials += Credentials(
  "Sonatype Nexus Repository Manager",
  "s01.oss.sonatype.org",
  "seu-usuario-sonatype",
  "sua-senha-sonatype"
)
```

Para GPG, crie `~/.sbt/1.0/gpg.sbt` (se pedir senha):

```scala
// Se sua chave GPG tem senha
useGpgAgent := true
// ou
pgpPassphrase := Some("sua-senha-gpg".toArray)
```

### 🚀 Publicar no Maven Central

```bash
cd /home/dean/PhD/htc-dl

# 1. Verificar que tudo está OK
sbt clean test

# 2. Usar o script de release
./release.sh

# Ou manualmente:
# Publicar no staging
sbt publishSigned

# 3. Ir para o Sonatype
# https://s01.oss.sonatype.org/
# Login com suas credenciais

# 4. No menu lateral: Build Promotion → Staging Repositories
# Procure por "iogithubfwrock-XXXX"

# 5. Selecione seu repository e clique em "Close"
#    (isso valida os artefatos - leva ~5 minutos)

# 6. Depois de fechado, clique em "Release"
#    (isso publica no Maven Central)

# Ou via comando:
sbt sonatypeRelease
```

### ⏱️ Aguardar Indexação

| Etapa | Tempo |
|-------|-------|
| Maven Central sync | 10-30 minutos |
| Scaladex indexing | 2-24 horas |

### ✅ Verificar Publicação

**Maven Central:**
```
https://search.maven.org/artifact/io.github.fwrock/htc-dl_3/0.1.0/jar
```

**Scaladex (após indexação):**
```
https://index.scala-lang.org/fwrock/htc-dl
```

---

## 🔄 Método Alternativo: Submissão Manual ao Scaladex

Se você publicou em outro lugar (GitHub Packages, etc.), pode submeter manualmente:

### 1. Via GitHub

O Scaladex pode indexar diretamente do GitHub se:
- Seu projeto tem tags/releases
- Tem arquivo `build.sbt` no root
- Está público

**Não requer ação manual** - o Scaladex descobre automaticamente!

### 2. Via Formulário Web (Último Recurso)

Se não funcionar automaticamente:

```bash
# 1. Criar conta no GitHub
# 2. Acessar: https://index.scala-lang.org/
# 3. Login com GitHub
# 4. Ir em: https://index.scala-lang.org/publish
# 5. Conectar seu repositório GitHub
```

---

## 🎯 Resumo: Passo a Passo Completo

```bash
# === DIA 1: Setup Inicial ===

# 1. Criar conta Sonatype
# Link: https://issues.sonatype.org/secure/Signup!default.jspa

# 2. Criar ticket JIRA
# Link: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
# Group Id: io.github.fwrock
# Project URL: https://github.com/fwrock/htc-dl

# 3. Aguardar resposta (1-2 dias úteis)
# Eles pedem verificação do GitHub

# === DIA 2-3: Após Aprovação ===

# 4. Configurar GPG
gpg --gen-key
gpg --list-keys
gpg --keyserver keyserver.ubuntu.com --send-keys SEU_KEY_ID

# 5. Configurar credenciais
cat > ~/.sbt/1.0/sonatype.sbt << 'EOF'
credentials += Credentials(
  "Sonatype Nexus Repository Manager",
  "s01.oss.sonatype.org",
  "seu-usuario",
  "sua-senha"
)
EOF

# 6. Publicar!
cd /home/dean/PhD/htc-dl
./release.sh
# Escolher opção 1 (Maven Central)

# 7. Finalizar no Sonatype
# https://s01.oss.sonatype.org/
# Staging Repositories → Close → Release

# 8. Aguardar
# Maven Central: 10-30 min
# Scaladex: 2-24 horas

# 9. Verificar
# https://index.scala-lang.org/fwrock/htc-dl
```

---

## 📊 Comparação dos Métodos

| Aspecto | Maven Central | GitHub Direto |
|---------|--------------|---------------|
| Setup inicial | ⏰ 2-3 dias | ⚡ Imediato |
| Indexação Scaladex | ✅ Automática | ⚠️ Pode falhar |
| Uso pelos usuários | ✅ Zero config | ❌ Requer resolver |
| Visibilidade | ⭐⭐⭐⭐ Máxima | ⭐⭐ Limitada |
| Manutenção | ✅ Simples | ⚠️ Manual |
| Recomendado? | ✅ **SIM** | Apenas teste |

---

## 🆘 Troubleshooting

### "Aguardando aprovação do ticket JIRA há dias"

Verifique:
- Se preencheu todos os campos obrigatórios
- Se verificou ownership do GitHub (conforme pedido)
- Responda prontamente aos comentários no ticket

### "GPG signature failed"

```bash
# Verificar se chave foi publicada
gpg --keyserver keyserver.ubuntu.com --recv-keys SEU_KEY_ID

# Re-publicar em múltiplos servidores
gpg --keyserver keyserver.ubuntu.com --send-keys SEU_KEY_ID
gpg --keyserver keys.openpgp.org --send-keys SEU_KEY_ID
gpg --keyserver pgp.mit.edu --send-keys SEU_KEY_ID
```

### "Artifact already exists"

```bash
# Incrementar versão no build.sbt
# Maven Central não permite sobrescrever versões
# 0.1.0 → 0.1.1 ou 0.2.0
```

### "Library não aparece no Scaladex após 24h"

1. Verificar se está no Maven Central: https://search.maven.org/
2. Se sim, aguardar mais (às vezes leva 48h)
3. Se não aparecer, abrir issue: https://github.com/scalacenter/scaladex/issues

---

## 🎉 Resultado Final

Após seguir os passos, sua biblioteca estará em:

✅ **Maven Central**
```
https://search.maven.org/artifact/io.github.fwrock/htc-dl_3
```

✅ **Scaladex**
```
https://index.scala-lang.org/fwrock/htc-dl
```

✅ **Uso simples**
```scala
libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"
```

---

## 🔗 Links Importantes

- **Sonatype Signup**: https://issues.sonatype.org/secure/Signup!default.jspa
- **Criar Ticket**: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
- **Sonatype Repository**: https://s01.oss.sonatype.org/
- **Maven Central**: https://search.maven.org/
- **Scaladex**: https://index.scala-lang.org/
- **Guia Oficial Sonatype**: https://central.sonatype.org/publish/publish-guide/

---

## ⚡ TL;DR - Resumo Executivo

```bash
# 1. Criar conta + ticket no Sonatype (2 dias para aprovação)
# 2. Configurar GPG (10 minutos)
# 3. ./release.sh (5 minutos)
# 4. Close + Release no Sonatype (2 minutos)
# 5. Aguardar indexação (2-24 horas)
# 6. ✅ Sua lib aparece automaticamente no Scaladex!
```

**Não há formulário ou submissão manual no Scaladex se você publicar no Maven Central!**
