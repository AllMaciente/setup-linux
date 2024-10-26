# Lista de aplicativos para instalar. Adicione ou remova conforme necessário.
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

DEBIAN_APPS=(
    fd-find
)

FEDORA_APPS=(
    fd-find
    eza
)

ARCH_APPS=(
    fd
    lazygit
    eza
)

OPENSUSE_APPS=(
    fd
)

# Função para detectar a distribuição
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
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
        sudo apt install -y nodejs
    sudo apt install -y fish
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    sudo apt update
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
}

# Função para instalar pacotes no Fedora e derivados
install_fedora() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo dnf update -y
    sudo dnf install -y "${COMMON_APPS[@]}" "${FEDORA_APPS[@]}"
	sudo dnf install -y fish
     sudo dnf install -y python3 python3-pip
    curl -fsSL https://rpm.nodesource.com/setup_current.x | sudo bash -
        sudo dnf install -y nodejs
    sudo dnf copr enable atim/lazygit -y
    sudo dnf install lazygit
}

# Função para instalar pacotes no Arch Linux e derivados (ex: Manjaro)
install_arch() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm "${COMMON_APPS[@]}" "${ARCH_APPS[@]}"
	sudo pacman -S --noconfirm fish
    sudo pacman -Syu --noconfirm python python-pip
      sudo pacman -S --noconfirm nodejs npm
}

# Função para instalar pacotes no openSUSE e derivados
install_opensuse() {
    echo "Instalando pacotes para $PRETTY_NAME..."
    sudo zypper refresh
    sudo zypper install -y "${COMMON_APPS[@]}" "${OPENSUSE_APPS[@]}"
	sudo zypper install -y fish
    sudo zypper install -y python3 python3-pip
     sudo zypper install -y nodejs npm
    sudo zypper ar https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Factory/devel:languages:go.repo
    sudo zypper ref && sudo zypper in lazygit
    zypper ar https://download.opensuse.org/tumbleweed/repo/oss/ factory-oss
    zypper in eza
}

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
configure_fish() {
    echo "Configurando o Fish shell..."
	curl -sS https://starship.rs/install.sh | sh

	URL="https://raw.githubusercontent.com/AllMaciente/setup-linux/refs/heads/main/config.fish"
   
    mkdir -p "~/.config/fish"

	wget -P "~/.config/fish" "$URL"
  	
    echo "Configuração do Fish shell concluída!"
}
set_fish_as_default() {
    echo "Definindo o Fish shell como padrão..."
    chsh -s $(which fish)
}
install_fish_plugins(){
	fisher install PatrickF1/fzf.fish
	fisher install jorgebucaran/autopair.fish
	
}
install_cli(){
	pip install pipx
	pipx install classifier
	npm install -g tldr
}
# Função principal
main() {
    detect_distro
	install_bydistro
	configure_fish
	set_fish_as_default
	install_fish_plugins
	install_cli
}

# Executa a função principal
main
