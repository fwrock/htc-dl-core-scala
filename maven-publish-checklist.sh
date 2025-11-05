#!/bin/bash
# Checklist para Publicação no Maven Central via GitHub Actions

echo "═══════════════════════════════════════════════════════════════════════"
echo "  📋 CHECKLIST: Publicação Maven Central via GitHub Actions"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Status dos itens
declare -A status

echo "🔍 Verificando configuração atual..."
echo ""

# 1. Workflow exists
if [ -f ".github/workflows/publish-maven.yml" ]; then
    status[workflow]="${GREEN}✅ Habilitado${NC}"
elif [ -f ".github/workflows/publish-maven.yml.disabled" ]; then
    status[workflow]="${YELLOW}⏸️  Desabilitado (.disabled)${NC}"
else
    status[workflow]="${RED}❌ Não encontrado${NC}"
fi

# 2. Check if GPG key exists locally
if gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    status[gpg]="${GREEN}✅ Chave GPG encontrada${NC}"
else
    status[gpg]="${YELLOW}⚠️  Nenhuma chave GPG encontrada${NC}"
fi

# 3. Check sonatype.sbt
if [ -f "$HOME/.sbt/1.0/sonatype.sbt" ]; then
    status[sonatype_sbt]="${GREEN}✅ Arquivo configurado${NC}"
else
    status[sonatype_sbt]="${YELLOW}⚠️  Não encontrado${NC}"
fi

# 4. Check credentials.sbt
if [ -f "$HOME/.sbt/1.0/credentials.sbt" ]; then
    status[credentials]="${GREEN}✅ Credenciais configuradas${NC}"
else
    status[credentials]="${YELLOW}⚠️  Não encontrado${NC}"
fi

# 5. Check build.sbt configuration
if grep -q "sonatypeProjectHosting" build.sbt 2>/dev/null; then
    status[build_sbt]="${GREEN}✅ build.sbt configurado${NC}"
else
    status[build_sbt]="${RED}❌ build.sbt precisa configuração${NC}"
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "  📊 STATUS ATUAL"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo -e "1. Workflow Maven Publishing:     ${status[workflow]}"
echo -e "2. Chave GPG local:                ${status[gpg]}"
echo -e "3. ~/.sbt/1.0/sonatype.sbt:        ${status[sonatype_sbt]}"
echo -e "4. ~/.sbt/1.0/credentials.sbt:     ${status[credentials]}"
echo -e "5. build.sbt (Sonatype config):    ${status[build_sbt]}"
echo ""

echo "═══════════════════════════════════════════════════════════════════════"
echo "  ✅ CHECKLIST PRÉ-REQUISITOS"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Antes de habilitar o workflow de publicação automática:"
echo ""
echo "  [ ] 1. Conta Sonatype criada e APROVADA"
echo "          https://s01.oss.sonatype.org/"
echo ""
echo "  [ ] 2. Chave GPG gerada"
echo "          gpg --gen-key"
echo ""
echo "  [ ] 3. Chave GPG publicada"
echo "          gpg --keyserver keyserver.ubuntu.com --send-keys KEY_ID"
echo ""
echo "  [ ] 4. Arquivo ~/.sbt/1.0/sonatype.sbt configurado"
echo "          Veja: SCALADEX_PUBLISHING.md"
echo ""
echo "  [ ] 5. Testado localmente com sucesso"
echo "          sbt publishLocal"
echo "          sbt publishSigned"
echo ""
echo "  [ ] 6. Secrets configurados no GitHub:"
echo "          - SONATYPE_USERNAME"
echo "          - SONATYPE_PASSWORD"
echo "          - PGP_SECRET"
echo "          - PGP_PASSPHRASE"
echo ""

echo "═══════════════════════════════════════════════════════════════════════"
echo "  🚀 PRÓXIMOS PASSOS"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

if [ -f ".github/workflows/publish-maven.yml.disabled" ]; then
    echo "${YELLOW}📝 SITUAÇÃO ATUAL:${NC}"
    echo "   Workflow criado mas DESABILITADO (arquivo .disabled)"
    echo ""
    echo "${GREEN}🎯 OPÇÕES:${NC}"
    echo ""
    echo "   ${YELLOW}Opção A:${NC} Continuar com releases apenas no GitHub (atual)"
    echo "   ➜ Não fazer nada"
    echo "   ➜ Usar: git tag v0.1.0 && git push --tags"
    echo "   ➜ Resultado: GitHub Release com JAR anexado"
    echo ""
    echo "   ${YELLOW}Opção B:${NC} Habilitar publicação automática no Maven Central"
    echo "   ➜ 1. Complete checklist acima"
    echo "   ➜ 2. Configure secrets no GitHub"
    echo "   ➜ 3. Execute:"
    echo ""
    echo "      mv .github/workflows/publish-maven.yml.disabled \\"
    echo "         .github/workflows/publish-maven.yml"
    echo ""
    echo "      git add .github/workflows/publish-maven.yml"
    echo "      git commit -m 'Enable Maven Central publishing'"
    echo "      git push"
    echo ""
    echo "   ➜ 4. Criar tag: git tag v0.1.0 && git push --tags"
    echo "   ➜ Resultado: Maven Central + Scaladex + GitHub Release"
    echo ""
elif [ -f ".github/workflows/publish-maven.yml" ]; then
    echo "${GREEN}✅ Workflow HABILITADO!${NC}"
    echo ""
    echo "Para publicar:"
    echo "  git tag v0.1.0"
    echo "  git push origin --tags"
    echo ""
    echo "Workflow executará automaticamente e publicará em:"
    echo "  ✓ Maven Central (~10-30 min)"
    echo "  ✓ Scaladex (~2-24 horas)"
    echo "  ✓ GitHub Release (imediato)"
    echo ""
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "  📚 DOCUMENTAÇÃO"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "  📖 Guia Workflows:            WORKFLOWS_GUIDE.md"
echo "  📖 Guia Scaladex/Maven:       SCALADEX_PUBLISHING.md"
echo "  📖 Comandos SBT:              SBT_COMMANDS.md"
echo "  📖 Opções de Publicação:      PUBLISHING_OPTIONS.md"
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
