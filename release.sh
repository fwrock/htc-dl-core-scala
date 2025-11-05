#!/bin/bash
#
# Script de release para HTC-DL
# Automatiza o processo de publicação no Maven Central
#

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   HTC-DL Release Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Verificar se está na branch main
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
    echo -e "${RED}❌ Error: Must be on main branch${NC}"
    echo -e "   Current branch: $current_branch"
    exit 1
fi
echo -e "${GREEN}✅${NC} On main branch"

# Verificar se há mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Error: Uncommitted changes detected${NC}"
    echo -e "   Please commit or stash your changes"
    git status --short
    exit 1
fi
echo -e "${GREEN}✅${NC} No uncommitted changes"

# Verificar se todos os testes passam
echo -e "\n${BLUE}Running tests...${NC}"
if ! sbt test; then
    echo -e "${RED}❌ Error: Tests failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅${NC} All tests passed"

# Perguntar versão
echo -e "\n${YELLOW}Current version in build.sbt:${NC}"
grep "version :=" build.sbt | head -1

echo -e "\n${YELLOW}Enter new version (e.g., 0.1.0):${NC}"
read NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}❌ Error: Version cannot be empty${NC}"
    exit 1
fi

echo -e "\n${BLUE}Preparing release $NEW_VERSION${NC}"

# Atualizar versão no build.sbt
sed -i "s/ThisBuild \/ version := \".*\"/ThisBuild \/ version := \"$NEW_VERSION\"/" build.sbt
echo -e "${GREEN}✅${NC} Updated version in build.sbt"

# Atualizar CHANGELOG
echo -e "\n${YELLOW}Update CHANGELOG.md with release notes? (y/n)${NC}"
read -r UPDATE_CHANGELOG

if [ "$UPDATE_CHANGELOG" = "y" ]; then
    ${EDITOR:-nano} CHANGELOG.md
    echo -e "${GREEN}✅${NC} CHANGELOG.md updated"
fi

# Commit mudanças
git add build.sbt CHANGELOG.md 2>/dev/null || true
git commit -m "Release version $NEW_VERSION" || true
echo -e "${GREEN}✅${NC} Changes committed"

# Criar tag
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
echo -e "${GREEN}✅${NC} Tag v$NEW_VERSION created"

# Build e package
echo -e "\n${BLUE}Building package...${NC}"
sbt clean compile test package
echo -e "${GREEN}✅${NC} Package built successfully"

# Opções de publicação
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Choose publication method:${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "1) Publish to Maven Central (Sonatype)"
echo -e "2) Publish to GitHub Packages"
echo -e "3) Publish local only"
echo -e "4) Skip publishing (just create tag)"
echo -e "\n${YELLOW}Enter choice (1-4):${NC}"
read PUBLISH_CHOICE

case $PUBLISH_CHOICE in
    1)
        echo -e "\n${BLUE}Publishing to Maven Central...${NC}"
        echo -e "${YELLOW}⚠️  Make sure you have:${NC}"
        echo -e "   - Sonatype account configured"
        echo -e "   - GPG key set up"
        echo -e "   - Credentials in ~/.sbt/1.0/sonatype.sbt"
        echo -e "\n${YELLOW}Continue? (y/n)${NC}"
        read -r CONTINUE
        
        if [ "$CONTINUE" = "y" ]; then
            sbt publishSigned
            echo -e "\n${GREEN}✅${NC} Published to Sonatype staging"
            echo -e "\n${YELLOW}Next steps:${NC}"
            echo -e "1. Login to https://s01.oss.sonatype.org/"
            echo -e "2. Find your staging repository"
            echo -e "3. Click 'Close' to validate"
            echo -e "4. Click 'Release' to publish"
            echo -e "\n${BLUE}Or run: sbt sonatypeRelease${NC}"
        fi
        ;;
    2)
        echo -e "\n${BLUE}Publishing to GitHub Packages...${NC}"
        echo -e "${YELLOW}Make sure GITHUB_TOKEN is set${NC}"
        sbt publish
        echo -e "${GREEN}✅${NC} Published to GitHub Packages"
        ;;
    3)
        echo -e "\n${BLUE}Publishing locally...${NC}"
        sbt publishLocal
        echo -e "${GREEN}✅${NC} Published to local repository"
        echo -e "   Location: ~/.ivy2/local/io.github.fwrock/htc-dl_3/$NEW_VERSION/"
        ;;
    4)
        echo -e "\n${YELLOW}Skipping publication${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Push para GitHub
echo -e "\n${YELLOW}Push changes and tags to GitHub? (y/n)${NC}"
read -r PUSH_GITHUB

if [ "$PUSH_GITHUB" = "y" ]; then
    git push origin main
    git push origin "v$NEW_VERSION"
    echo -e "${GREEN}✅${NC} Pushed to GitHub"
    echo -e "\n${BLUE}GitHub Release URL:${NC}"
    echo -e "   https://github.com/fwrock/htc-dl/releases/tag/v$NEW_VERSION"
fi

# Resumo
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   Release $NEW_VERSION Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${BLUE}What was done:${NC}"
echo -e "  ✅ Tests passed"
echo -e "  ✅ Version updated to $NEW_VERSION"
echo -e "  ✅ Changes committed"
echo -e "  ✅ Tag v$NEW_VERSION created"
echo -e "  ✅ Package built"

if [ "$PUBLISH_CHOICE" != "4" ]; then
    echo -e "  ✅ Published"
fi

if [ "$PUSH_GITHUB" = "y" ]; then
    echo -e "  ✅ Pushed to GitHub"
fi

echo -e "\n${BLUE}Next steps:${NC}"

if [ "$PUBLISH_CHOICE" = "1" ]; then
    echo -e "  1. Complete the release on Sonatype"
    echo -e "  2. Wait 10-30 minutes for Maven Central sync"
    echo -e "  3. Wait 2-24 hours for Scaladex indexing"
    echo -e "\n${BLUE}Check publication:${NC}"
    echo -e "  - Maven Central: https://search.maven.org/artifact/io.github.fwrock/htc-dl_3/$NEW_VERSION/jar"
    echo -e "  - Scaladex: https://index.scala-lang.org/fwrock/htc-dl"
fi

if [ "$PUSH_GITHUB" = "y" ]; then
    echo -e "  - Create release notes on GitHub"
    echo -e "  - Update documentation if needed"
fi

echo -e "\n${GREEN}Release complete! 🚀${NC}\n"