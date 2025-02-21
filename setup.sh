#!/bin/sh

# URL do repositório no GitHub
GITHUB_REPO="https://raw.githubusercontent.com/AllMaciente/setup-linux/main"
PACKAGES_FILE="packages.txt"
PLUGINS_FILE="plugins.txt"

# Detecta o gerenciador de pacotes disponível
detect_package_manager() {
    echo "🔍 Detectando gerenciador de pacotes..."
    if command -v dnf >/dev/null 2>&1; then
        echo "✅ DNF detectado (Fedora/RHEL)"
        PACKAGE_MANAGER="dnf"
    elif command -v apt >/dev/null 2>&1; then
        echo "✅ APT detectado (Debian/Ubuntu)"
        PACKAGE_MANAGER="apt"
    elif command -v pacman >/dev/null 2>&1; then
        echo "✅ Pacman detectado (Arch/Manjaro)"
        PACKAGE_MANAGER="pacman"
    else
        echo "❌ Gerenciador de pacotes não suportado!"
        exit 1
    fi
}

# Atualiza o sistema
update_system() {
    echo "🔄 Atualizando o sistema..."
    case "$PACKAGE_MANAGER" in
        dnf) sudo dnf upgrade -y ;;
        apt) sudo apt update && sudo apt upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
    esac
}

# Baixa o arquivo de pacotes do GitHub
download_packages_file() {
    echo "🌐 Baixando lista de pacotes do GitHub..."
    curl -s -o "$PACKAGES_FILE" "$GITHUB_REPO/$PACKAGES_FILE"
    
    if [ -s "$PACKAGES_FILE" ]; then
        echo "✅ Arquivo $PACKAGES_FILE baixado com sucesso!"
    else
        echo "❌ Erro ao baixar $PACKAGES_FILE. Nenhum pacote será instalado."
        rm -f "$PACKAGES_FILE"
    fi
}

# Instala os pacotes necessários
install_packages() {
    if [ -f "$PACKAGES_FILE" ]; then
        echo "📦 Instalando pacotes listados em $PACKAGES_FILE..."
        PACKAGES=$(grep -v '^#' "$PACKAGES_FILE" | tr '\n' ' ')
        case "$PACKAGE_MANAGER" in
            dnf) sudo dnf install -y $PACKAGES ;;
            apt) sudo apt install -y $PACKAGES ;;
            pacman) sudo pacman -S --noconfirm $PACKAGES ;;
        esac
    else
        echo "⚠️ Nenhuma lista de pacotes encontrada. Pulando a instalação."
    fi
}

# Define o Fish como shell padrão
set_fish_default() {
    if command -v fish >/dev/null 2>&1; then
        echo "🔄 Configurando Fish como shell padrão..."
        chsh -s "$(command -v fish)"
        echo "✅ Fish foi definido como padrão. Reinicie a sessão para aplicar as mudanças."
    else
        echo "⚠️ Fish não foi instalado corretamente."
        exit 1
    fi
}

# Instala o Fisher (gerenciador de plugins do Fish)
install_fisher() {
    if command -v fish >/dev/null 2>&1; then
        echo "🐟 Instalando Fisher..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
    else
        echo "⚠️ Fish não encontrado. Pulando a instalação do Fisher."
    fi
}

# Baixa o arquivo de plugins do GitHub
download_plugins_file() {
    echo "🌐 Baixando lista de plugins do GitHub..."
    curl -s -o "$PLUGINS_FILE" "$GITHUB_REPO/$PLUGINS_FILE"
    
    if [ -s "$PLUGINS_FILE" ]; then
        echo "✅ Arquivo $PLUGINS_FILE baixado com sucesso!"
    else
        echo "❌ Erro ao baixar $PLUGINS_FILE. Nenhum plugin será instalado."
        rm -f "$PLUGINS_FILE"
    fi
}

# Instala plugins do Fish a partir do arquivo baixado
install_fish_plugins() {
    if command -v fish >/dev/null 2>&1 && [ -f "$PLUGINS_FILE" ]; then
        echo "📜 Instalando plugins do Fish a partir de $PLUGINS_FILE..."
        while IFS= read -r plugin; do
            [ -n "$plugin" ] && fish -c "fisher install $plugin"
        done < "$PLUGINS_FILE"
    else
        echo "⚠️ Fish não encontrado ou $PLUGINS_FILE ausente. Pulando a instalação dos plugins."
    fi
}

# Executa as funções em ordem
main() {
    detect_package_manager
    update_system
    download_packages_file
    install_packages
    set_fish_default
    install_fisher
    download_plugins_file
    install_fish_plugins
    echo "🎉 Setup concluído!"
}

main
