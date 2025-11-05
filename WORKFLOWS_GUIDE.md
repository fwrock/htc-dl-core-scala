# 🔄 GitHub Actions Workflows - Guia Completo

## 📁 Workflows Configurados

### 1️⃣ **CI** (`.github/workflows/ci.yml`)
**Status:** ✅ Ativo  
**Trigger:** Push ou Pull Request  
**O que faz:**
- ✓ Compila o projeto
- ✓ Executa todos os testes
- ✓ Gera o arquivo JAR
- ✓ Armazena em cache dependências

**Publicação:** ❌ Não publica nada

---

### 2️⃣ **Release** (`.github/workflows/release.yml`)
**Status:** ✅ Ativo  
**Trigger:** Push de tag `v*` (ex: `v0.1.0`)  
**O que faz:**
- ✓ Executa testes
- ✓ Gera arquivo JAR
- ✓ **Cria GitHub Release**
- ✓ Anexa JAR ao release

**Publicação:** ⚠️  Apenas GitHub Release (não Maven Central)

**Como usar:**
```bash
git tag v0.1.0
git push origin --tags
```

---

### 3️⃣ **Publish to Maven Central** (`.github/workflows/publish-maven.yml.disabled`)
**Status:** 🔴 Desabilitado (intencional)  
**Trigger:** Push de tag `v*` OU execução manual  
**O que faz:**
- ✓ Executa testes
- ✓ **Publica no Maven Central** (via Sonatype)
- ✓ **Publica no Scaladex** (automático após Maven)
- ✓ Cria GitHub Release

**Publicação:** ✅ Maven Central + Scaladex

**Status:** ⚠️  **Requer configuração de secrets primeiro!**

---

## 🔐 Como Habilitar Publicação Automática no Maven Central

### Passo 1: Configurar Secrets no GitHub

1. Vá em: **Settings → Secrets and variables → Actions**
2. Clique em **New repository secret**
3. Adicione os seguintes secrets:

| Secret Name | Valor | Como Obter |
|------------|-------|------------|
| `SONATYPE_USERNAME` | Seu username Sonatype | Após criar conta em https://s01.oss.sonatype.org/ |
| `SONATYPE_PASSWORD` | Sua senha Sonatype | A mesma senha do login |
| `PGP_SECRET` | Chave GPG privada (base64) | `gpg --export-secret-keys KEY_ID \| base64 -w 0` |
| `PGP_PASSPHRASE` | Senha da chave GPG | A senha que você definiu ao criar a chave |

### Passo 2: Habilitar o Workflow

```bash
# Renomear arquivo para ativá-lo
mv .github/workflows/publish-maven.yml.disabled \
   .github/workflows/publish-maven.yml

# Commit e push
git add .github/workflows/publish-maven.yml
git commit -m "Enable Maven Central publishing"
git push
```

### Passo 3: Publicar

```bash
# 1. Atualizar versão em build.sbt
# ThisBuild / version := "0.1.0"

# 2. Commit e criar tag
git add build.sbt
git commit -m "Release 0.1.0"
git tag v0.1.0
git push origin main --tags

# 3. Workflow executará automaticamente!
```

---

## 📊 Comparação dos Workflows

| Recurso | CI | Release | Publish Maven |
|---------|-----|---------|---------------|
| Executa testes | ✅ | ✅ | ✅ |
| Gera JAR | ✅ | ✅ | ✅ |
| GitHub Release | ❌ | ✅ | ✅ |
| Maven Central | ❌ | ❌ | ✅ |
| Scaladex | ❌ | ❌ | ✅ (automático) |
| Requer secrets | ❌ | ❌ | ✅ |

---

## 🎯 Cenários de Uso

### Desenvolvimento Normal
- **Push no branch** → CI executa
- Verifica se código compila e testes passam

### Criar Release Simples
- **Push tag `v*`** → Release executa
- Cria release no GitHub com JAR anexado
- ⚠️  **NÃO publica no Maven Central**

### Publicar Biblioteca (após habilitar)
- **Push tag `v*`** → Publish Maven executa
- Publica no Maven Central (~10-30 min)
- Indexa no Scaladex (~2-24 horas)
- Cria release no GitHub

---

## 🚀 Quick Start

### Para CI/CD básico (já configurado)
```bash
# Já está pronto! Só fazer push:
git add .
git commit -m "My changes"
git push

# CI executa automaticamente
```

### Para criar release (já configurado)
```bash
# Criar tag e push:
git tag v0.1.0
git push origin --tags

# Release workflow executa automaticamente
# Cria GitHub Release com JAR
```

### Para publicar no Maven (requer habilitação)
```bash
# 1. Configurar secrets no GitHub (veja Passo 1 acima)
# 2. Habilitar workflow (veja Passo 2 acima)
# 3. Fazer release (veja Passo 3 acima)
```

---

## 📝 Notas Importantes

### ⚠️  Workflow de Publicação Maven
- **Desabilitado por padrão** (arquivo `.disabled`)
- **Requer setup completo** antes de habilitar:
  - ✓ Conta Sonatype aprovada
  - ✓ Chave GPG criada e publicada
  - ✓ Secrets configurados no GitHub
  - ✓ Testado localmente primeiro

### ✅ Workflows CI e Release
- **Ativos e prontos para uso**
- **Não requerem configuração adicional**
- **Seguros para usar imediatamente**

---

## 🔗 Links Úteis

- **Guia Completo de Publicação:** [SCALADEX_PUBLISHING.md](SCALADEX_PUBLISHING.md)
- **Comandos SBT:** [SBT_COMMANDS.md](SBT_COMMANDS.md)
- **Opções de Publicação:** [PUBLISHING_OPTIONS.md](PUBLISHING_OPTIONS.md)
- **Maven Central Search:** https://search.maven.org/
- **Scaladex:** https://index.scala-lang.org/
- **Sonatype OSS:** https://s01.oss.sonatype.org/

---

## 🆘 Troubleshooting

### CI/Release falham com "sbt: command not found"
- ✅ **Corrigido:** Workflows usam `setup-java@v4` que instala SBT automaticamente

### Quero testar publicação localmente primeiro
```bash
# Publicar localmente
sbt publishLocal

# Publicar em staging (requer Sonatype configurado)
sbt publishSigned
sbt sonatypeBundleRelease
```

### Como verificar se publicação funcionou?
```bash
# Maven Central (após ~10-30 min)
# https://search.maven.org/artifact/io.github.fwrock/htc-dl_3/VERSION/jar

# Scaladex (após ~2-24 horas)
# https://index.scala-lang.org/fwrock/htc-dl
```

---

## 📞 Resumo Executivo

**Situação Atual:**
- ✅ CI configurado e funcionando
- ✅ GitHub Releases configurado e funcionando
- ⏸️  Maven Central publishing pronto mas desabilitado

**Para começar a usar:**
- Faça push → CI testa automaticamente
- Crie tag → GitHub Release criado automaticamente

**Para publicar no Maven Central:**
- Configure secrets → Habilite workflow → Crie tag
- Veja instruções completas em [SCALADEX_PUBLISHING.md](SCALADEX_PUBLISHING.md)

