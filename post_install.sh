#!/bin/sh
#
####### PÓS INSTALAÇÃO FEDORA ######
#

URL_FUSION_FREE="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
URL_FUSION_NONFREE="https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
KEY_FUSION_FREE="/etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora)"
KEY_FUSION_NONFREE="/etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora)"

TO_INSTALL=(
    vlc
    vim
    gnome-tweaks 
    gnome-extensions-app
    gnome-browser-connector
    @development-tools
    kernel-headers 
    kernel-devel 
    dkms 
    elfutils-libelf-devel 
    qt5-qtx11extras
    gimp
    git
    inkscape
    discord
    telegram-desktop
    java-latest-openjdk
    VirtualBox
    dnfdragora-gui
    cabextract
    lzip
    p7zip
    p7zip-plugins
    unrar
    gparted
    transmission
    zsh
    golang
    python3-pip
    podman-compose
    rust
    cargo
)

FLATPACK_TO_INSTALL=(
    flathub com.spotify.Client
    flathub com.discordapp.Discord
)

echo fastestmirror=true >> /etc/dnf/dnf.conf
echo deltarpm=true >> /etc/dnf/dnf.conf
echo max_parallel_downloads=10 >> /etc/dnf/dnf.conf

### Atualização geral ###
dnf -y upgrade
dnf -y update

### Plugins de multimídia ###
dnf -y install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf -y install lame\* --exclude=lame-devel
dnf -y group upgrade --with-optional Multimedia

### Google chrome ###
dnf -y install fedora-workstation-repositories
dnf config-manager --set-enabled google-chrome
dnf -y install google-chrome-stable

### Brave Browser ###
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install brave-keyring brave-browser

### VS Code ###
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf -y check-update
dnf -y install code

### VSCodium ###
rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
sudo dnf install codium

### RPM Fusion ###
dnf -y install $URL_FUSION_FREE
rpm --import $KEY_FUSION_FREE
dnf -y install $URL_FUSION_NONFREE
rpm --import $KEY_FUSION_NONFREE
dnf -y install rpmfusion-free-release-tainted
dnf -y install rpmfusion-nonfree-release-tainted

### Drivers NVidia
dnf -y install akmod-nvidia --enablerepo=rpmfusion*

### Ferramentas de desenvolvimento
dnf -y groupinstall "Development Tools" "Development Libraries"

### Instalação de programas ###
for install in ${TO_INSTALL[@]}; do
	dnf -y install $install
done

### OH my Zsh ###
wget --no-check-certificate http://install.ohmyz.sh -O - | sh

### Configurações do Golang
mkdir -p $HOME/go
echo 'export GOPATH=$HOME/go' >> $HOME/.zshrc

### Podman compose (interface para usar arquivos docker-compose no podman) ###
sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl enable --now podman.socket
systemctl status podman.socket
pip3 install --upgrade pip
pip install podman-compose

### Flatpak ###
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for install in ${FLATPACK_TO_INSTALL[@]}; do
    if ! flatpak list | grep $install ; then
       flatpak install $install
    else
       echo "[JÁ INSTALADO] - $install"
    fi
done
