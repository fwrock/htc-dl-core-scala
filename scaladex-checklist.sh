#!/bin/bash
#
# Checklist Interativo para Publicação no Scaladex via Maven Central
#

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Checklist: Publicar no Scaladex         ║${NC}"
echo -e "${BLUE}║   Via Maven Central (Automático)          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}\n"

# Função para perguntar sim/não
ask_done() {
    local prompt="$1"
    local help_text="$2"
    
    while true; do
        echo -e "${YELLOW}$prompt${NC}"
        if [ -n "$help_text" ]; then
            echo -e "  ${BLUE}ℹ${NC}  $help_text"
        fi
        read -p "  Concluído? (y/n/help): " yn
        case $yn in
            [Yy]* ) 
                echo -e "${GREEN}  ✅ Concluído!${NC}\n"
                return 0
                ;;
            [Nn]* ) 
                echo -e "${RED}  ⏸  Pausado. Complete este passo antes de continuar.${NC}\n"
                return 1
                ;;
            [Hh]* )
                echo -e "\n${BLUE}════ Ajuda Detalhada ═══════════════════${NC}"
                echo -e "$help_text"
                echo -e "${BLUE}════════════════════════════════════════${NC}\n"
                ;;
            * ) 
                echo "  Por favor responda y (sim) ou n (não)"
                ;;
        esac
    done
}

# ============================================================
# FASE 1: Setup Inicial (Uma vez apenas)
# ============================================================

echo -e "${BLUE}═══ FASE 1: Setup Inicial (uma vez) ═══${NC}\n"

if ! ask_done \
    "1️⃣  Criar conta no Sonatype" \
    "Acesse: https://issues.sonatype.org/secure/Signup!default.jspa
    - Use um email válido
    - Escolha um username (você vai precisar dele)
    - Confirme o email"; then
    exit 1
fi

if ! ask_done \
    "2️⃣  Criar ticket JIRA para registrar groupId" \
    "Acesse: https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134
    
    Preencha:
    - Project: Community Support - Open Source Project Repository Hosting (OSSRH)
    - Issue Type: New Project
    - Summary: Request for io.github.fwrock
    - Group Id: io.github.fwrock
    - Project URL: https://github.com/fwrock/htc-dl
    - SCM URL: https://github.com/fwrock/htc-dl.git
    - Username(s): [seu username do Sonatype]
    
    ANOTE O NÚMERO DO TICKET (ex: OSSRH-12345)"; then
    exit 1
fi

if ! ask_done \
    "3️⃣  Verificar ownership do GitHub" \
    "O bot do Sonatype vai pedir uma das opções:
    
    Opção A: Criar repo público temporário com nome OSSRH-XXXXX
    Opção B: Adicionar texto 'OSSRH-XXXXX' na descrição do repo htc-dl
    
    Depois de fazer, RESPONDA NO TICKET do JIRA dizendo que fez.
    
    Aguarde aprovação (1-2 dias úteis)."; then
    exit 1
fi

echo -e "${GREEN}✅ Setup inicial completo! Aguarde aprovação do Sonatype.${NC}\n"
echo -e "${YELLOW}⏸  Pause aqui. Volte quando receber aprovação (email).${NC}\n"

read -p "Pressione ENTER quando o ticket for APROVADO..."

echo -e "\n${BLUE}═══ FASE 2: Configuração (após aprovação) ═══${NC}\n"

# ============================================================
# FASE 2: Configuração GPG
# ============================================================

if ! ask_done \
    "4️⃣  Verificar/Instalar GPG" \
    "Execute: gpg --version
    
    Se não tiver:
    - Ubuntu/Debian: sudo apt-get install gnupg
    - macOS: brew install gnupg
    - Windows: https://www.gnupg.org/download/"; then
    exit 1
fi

if ! ask_done \
    "5️⃣  Gerar chave GPG" \
    "Execute: gpg --gen-key
    
    Escolha:
    - (1) RSA and RSA (default) - pressione ENTER
    - 4096 bits
    - 0 = key does not expire (ou escolha prazo longo)
    - Seu NOME REAL
    - Seu EMAIL (mesmo do GitHub)
    - Uma SENHA forte (você vai precisar dela!)
    
    Depois: gpg --list-keys
    Anote o KEY_ID (últimos 8 caracteres da linha 'pub')"; then
    exit 1
fi

echo -e "${YELLOW}Digite seu GPG KEY_ID (8 caracteres):${NC}"
read GPG_KEY_ID

if [ -z "$GPG_KEY_ID" ]; then
    echo -e "${RED}KEY_ID não pode ser vazio!${NC}"
    exit 1
fi

echo -e "\n${BLUE}Publicando sua chave GPG em servidores públicos...${NC}"
gpg --keyserver keyserver.ubuntu.com --send-keys "$GPG_KEY_ID" || true
gpg --keyserver keys.openpgp.org --send-keys "$GPG_KEY_ID" || true
gpg --keyserver pgp.mit.edu --send-keys "$GPG_KEY_ID" || true
echo -e "${GREEN}✅ Chave publicada!${NC}\n"

# ============================================================
# FASE 3: Credenciais SBT
# ============================================================

if ! ask_done \
    "6️⃣  Configurar credenciais Sonatype" \
    "Criar arquivo: ~/.sbt/1.0/sonatype.sbt
    
    Conteúdo:
    credentials += Credentials(
      \"Sonatype Nexus Repository Manager\",
      \"s01.oss.sonatype.org\",
      \"seu-usuario-sonatype\",
      \"sua-senha-sonatype\"
    )
    
    Substitua com suas credenciais reais!"; then
    exit 1
fi

echo -e "\n${BLUE}═══ FASE 3: Publicação ═══${NC}\n"

# ============================================================
# FASE 4: Publicar
# ============================================================

if ! ask_done \
    "7️⃣  Executar testes" \
    "Execute: cd /home/dean/PhD/htc-dl && sbt clean test
    
    Todos os testes devem passar!"; then
    exit 1
fi

echo -e "${BLUE}Deseja executar a publicação agora?${NC}"
read -p "(y/n): " RUN_PUBLISH

if [ "$RUN_PUBLISH" = "y" ]; then
    echo -e "\n${BLUE}Executando: sbt publishSigned${NC}\n"
    cd /home/dean/PhD/htc-dl
    sbt publishSigned
    
    echo -e "\n${GREEN}✅ Artefatos enviados para Sonatype staging!${NC}\n"
else
    echo -e "${YELLOW}Execute manualmente: cd /home/dean/PhD/htc-dl && sbt publishSigned${NC}\n"
fi

if ! ask_done \
    "8️⃣  Close repository no Sonatype" \
    "1. Acesse: https://s01.oss.sonatype.org/
    2. Login com suas credenciais
    3. Menu lateral: Build Promotion → Staging Repositories
    4. Procure por 'iogithubfwrock-XXXX'
    5. Selecione e clique em 'Close' (barra superior)
    6. Aguarde ~5 minutos (activity tab mostra progresso)
    7. Se der erro, verifique mensagens e corrija
    
    Ou via comando: sbt sonatypeClose"; then
    exit 1
fi

if ! ask_done \
    "9️⃣  Release repository no Sonatype" \
    "No mesmo Sonatype:
    1. Repository deve estar 'Closed'
    2. Selecione o repository
    3. Clique em 'Release' (barra superior)
    4. Confirme
    
    Ou via comando: sbt sonatypeRelease
    
    Isso publica no Maven Central!"; then
    exit 1
fi

echo -e "\n${BLUE}═══ FASE 4: Verificação ═══${NC}\n"

# ============================================================
# FASE 5: Aguardar e Verificar
# ============================================================

echo -e "${YELLOW}⏱  Aguardando sincronização...${NC}\n"
echo -e "  Maven Central: 10-30 minutos"
echo -e "  Scaladex: 2-24 horas\n"

if ! ask_done \
    "🔟 Verificar no Maven Central" \
    "Após 10-30 minutos, acesse:
    https://search.maven.org/artifact/io.github.fwrock/htc-dl_3/0.1.0/jar
    
    Ou busque por: io.github.fwrock htc-dl
    
    Deve aparecer sua biblioteca!"; then
    exit 1
fi

if ! ask_done \
    "1️⃣1️⃣ Verificar no Scaladex" \
    "Após 2-24 horas do Maven Central, acesse:
    https://index.scala-lang.org/fwrock/htc-dl
    
    Sua biblioteca deve aparecer automaticamente!
    
    Se não aparecer após 48h:
    - Verificar que está no Maven Central
    - Abrir issue: https://github.com/scalacenter/scaladex/issues"; then
    exit 1
fi

# ============================================================
# CONCLUÍDO!
# ============================================================

echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}║   🎉  PARABÉNS! Publicação Completa!  🎉   ║${NC}"
echo -e "${GREEN}║                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Sua biblioteca está agora disponível em:${NC}\n"
echo -e "  📦 Maven Central:"
echo -e "     https://search.maven.org/artifact/io.github.fwrock/htc-dl_3\n"
echo -e "  🔍 Scaladex:"
echo -e "     https://index.scala-lang.org/fwrock/htc-dl\n"

echo -e "${BLUE}Usuários podem adicionar ao build.sbt:${NC}"
echo -e '  libraryDependencies += "io.github.fwrock" %% "htc-dl" % "0.1.0"'
echo -e "\n"

echo -e "${YELLOW}Para próximas versões:${NC}"
echo -e "  1. Atualizar versão em build.sbt"
echo -e "  2. ./release.sh"
echo -e "  3. Close + Release no Sonatype"
echo -e "  4. Aguardar sync (mais rápido que a primeira vez!)"
echo -e "\n"

echo -e "${GREEN}🚀 Sua biblioteca é agora parte do ecossistema Scala! 🚀${NC}\n"
