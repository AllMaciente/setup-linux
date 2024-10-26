#!/bin/bash

# Lista de aplicativos comuns a todas as distribuições
COMMON_APPS=(
    git
    curl
    vim
    wget
    bashtop
    gh
    bat
    fzf
    ripgrep
    duf
)

# Lista de aplicativos específicos para Debian e derivados
DEBIAN_APPS=(
    fd-find
)

# Lista de aplicativos específicos para Fedora e derivados
FEDORA_APPS=(
    fd-find
    eza
)

# Lista de aplicativos específicos para Arch Linux e derivados
ARCH_APPS=(
    fd
    lazygit
    eza
)

# Lista de aplicativos específicos para openSUSE e derivados
OPENSUSE_APPS=(
    fd
)

# Função para detectar a distribuição Linux
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Distribuição Linux não detectada."
        exit 1
    fi
}

# Função para instalar pacotes no Debian, Ubuntu e derivados
install_debian() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo apt update
    sudo apt install -y "${COMMON_APPS[@]}" "${DEBIAN_APPS[@]}"
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt install -y python3 python3-pip

    # Instalação do Node.js
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    sudo apt install -y nodejs

    # Instalação do Zsh
    sudo apt install -y zsh

    # Instalação do Spaceship Prompt
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zsh-users/spaceship-prompt/master/install.sh)"

    # Download do .zshrc
    curl -o ~/.zshrc https://raw.githubusercontent.com/AllMaciente/setup-linux/main/.zshrc

    # Instalação do LazyGit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin

    # Instalação do Eza
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza

    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
}

# Função para instalar pacotes no Fedora e derivados
install_fedora() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo dnf update -y
    sudo dnf install -y "${COMMON_APPS[@]}" "${FEDORA_APPS[@]}"
    sudo dnf install -y zsh
    sudo dnf install -y python3 python3-pip

    # Instalação do Node.js
    curl -fsSL https://rpm.nodesource.com/setup_current.x | sudo bash -
    sudo dnf install -y nodejs

    # Instalação do Spaceship Prompt
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zsh-users/spaceship-prompt/master/install.sh)"

    # Download do .zshrc
    curl -o ~/.zshrc https://raw.githubusercontent.com/AllMaciente/setup-linux/main/.zshrc

    # Instalação do LazyGit
    sudo dnf copr enable atim/lazygit -y
    sudo dnf install lazygit

    # Instalação do Eza
    sudo dnf install -y eza
}

# Função para instalar pacotes no Arch Linux e derivados (ex: Manjaro)
install_arch() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm "${COMMON_APPS[@]}" "${ARCH_APPS[@]}"
    sudo pacman -S --noconfirm zsh

    # Instalação do Node.js
    sudo pacman -S --noconfirm python python-pip
    sudo pacman -S --noconfirm nodejs npm

    # Instalação do Spaceship Prompt
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zsh-users/spaceship-prompt/master/install.sh)"

    # Download do .zshrc
    curl -o ~/.zshrc https://raw.githubusercontent.com/AllMaciente/setup-linux/main/.zshrc
}

# Função para instalar pacotes no openSUSE e derivados
install_opensuse() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo zypper refresh
    sudo zypper install -y "${COMMON_APPS[@]}" "${OPENSUSE_APPS[@]}"
    sudo zypper install -y zsh
    sudo zypper install -y python3 python3-pip

    # Instalação do Node.js
    sudo zypper install -y nodejs npm
    sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Factory/devel:languages:go.repo
    sudo zypper ref && sudo zypper in lazygit
    sudo zypper ar https://download.opensuse.org/tumbleweed/repo/oss/ factory-oss
    sudo zypper in eza

    # Instalação do Spaceship Prompt
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zsh-users/spaceship-prompt/master/install.sh)"

    # Download do .zshrc
    curl -o ~/.zshrc https://raw.githubusercontent.com/AllMaciente/setup-linux/main/.zshrc
}

# Função para instalar pacotes de acordo com a distribuição detectada
install_bydistro() {
    case $DISTRO in
        ubuntu | debian | pop)
            install_debian
            ;;
        fedora | rhel | centos)
            install_fedora
            ;;
        arch | manjaro)
            install_arch
            ;;
        opensuse*)
            install_opensuse
            ;;
        *)
            echo "Distribuição não suportada: $DISTRO"
            exit 1
            ;;
    esac

    echo "Instalação concluída!"
}

# Função para definir o Zsh como padrão
set_zsh_as_default() {
    echo "Definindo o Zsh como padrão..."
    chsh -s "$(which zsh)"
}

# Função para instalar pacotes CLI adicionais
install_cli() {
    pip install pipx
    pipx install classifier
    npm install -g tldr
}

# Função principal
main() {
    detect_distro
    install_bydistro
    set_zsh_as_default
    install_cli
}

# Executa a função principal
main
