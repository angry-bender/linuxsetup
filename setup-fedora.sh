#!/bin/bash

# Function to install apps with a clean display (Fedora/DNF version)
function retryinstall {
   echo -e "[\033[33m-\e[0m] Retrying..."
   # dnf makecache refreshes metadata; dnf install -y handles dependencies automatically
   dnf clean expire-cache >/dev/null 2>/dev/null
   dnf install -y $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || { echo -e "[\033[31m-\e[0m] FAILED Exiting now..."; exit 1; }
}

function install {
   echo -n "Installing: $1 "
   dnf install -y $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || retryinstall $1
}

##### Main #####
USERN=drop

# Check Sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo" 
   exit 1
fi

# Check working directory
FILE=.zshrc
if test -f "$FILE"; then
    echo -e "Working Directory Check: [\033[32m*\e[0m]OK"
else
    echo -e "Working Directory Check: [\033[31m-\e[0m] FAILED"
    echo "Please change to the downloaded directory with file and run directly from there"
    exit
fi

# Get the Standard Users username
inuser=$SUDO_USER

# Install oh my zsh dependencies
install curl
install zsh
install git

echo -e "Installing: Oh my ZSH from external provider [-]"
# Run as the actual user so paths and permissions are correct for their home dir
sudo -u "$inuser" sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# Plugins (cloning as the user)
sudo -u "$inuser" git clone https://github.com/zsh-users/zsh-autosuggestions /home/"$inuser"/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo -u "$inuser" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/"$inuser"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Ensure shell changed (Fedora zsh path is /usr/bin/zsh)
usermod -s /usr/bin/zsh "${inuser}"
echo -e "${inuser} shell: changed to zsh [\033[32m*\e[0m]OK"

# Install Applications (Fedora specific package names)
install vim-enhanced
# install vim-airline
# Note: vim-airline is not in F43 yet
install powerline

#install gnome customisation, to either dash to dock, or dash to panel
#Note (post login behavior, disable overview on startup too)
install gnome-extensions-app
install gnome-shell-extension-dash-to-panel
install gnome-shell-extension-dash-to-dock
gsettings set org.gnome.desktop.interface gtk-decoration-layout "appmenu:minimize,maximize,close"



# Copy files
# Ensure rssh is installed if you rely on that config, though it's deprecated in Fedora
[ -f rssh.conf ] && cp rssh.conf /etc/rssh.conf 

cp .vimrc /home/${inuser}/
chown $inuser:$inuser /home/$inuser/.vimrc
cp .zshrc /home/${inuser}/
chown $inuser:$inuser /home/$inuser/.zshrc

echo -e "Copy Config Files: [\033[32m*\e[0m]OK"

# Theme management
if [ -f agnoster.zsh.theme ]; then
    cp agnoster.zsh.theme /home/${inuser}/.oh-my-zsh/themes/agnoster.zsh-theme
    chown $inuser:$inuser /home/${inuser}/.oh-my-zsh/themes/agnoster.zsh-theme
fi

# string replacements
sed -i -e "s/setupuser/"${inuser}"/g" /home/"${inuser}"/.zshrc
sed -i -e "s/root/"${inuser}"/g" /home/"${inuser}"/.zshrc
sed -i -e "s/user/"${inuser}"/g" /home/"${inuser}"/.zshrc


# Cleanup
git restore .zshrc >/dev/null 2>/dev/null

echo -e "[\033[32m*Setup Complete*\e[0m]: Please log out and back in"
gnome-session-quit

