#!/bin/bash


#function to install apps with a clean display
function retryinstall
{
   echo -e "[\033[33m-\e[0m] Retrying..."
   DEBIAN_FRONTEND=noninteractive apt-get --fix-broken install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null 2>/dev/nul
   DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null 2>/dev/nul
   DEBIAN_FRONTEND=noninteractive apt-get install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || echo -e "[\033[31m-\e[0m] FAILED Exiting now... Check apt isn't running & try again"; exit 1
}

function install
{
   echo -n "Installing: $1 "
   DEBIAN_FRONTEND=noninteractive apt-get install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || retryinstall $1
}



##### Main #####
USERN=drop

#Check Sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo" 
   exit 1
fi

#Check working directory
FILE=.zshrc
if test -f "$FILE"; then
    echo -e "Working Directory Check: [\033[32m*\e[0m]OK"
    else
        echo -e "Working Directory Check: [\033[31m-\e[0m] FAILED"
        echo "Please change to the downloaded direectory with file and run directly from there"
        echo "This script will now exit"
        exit
fi

#Get the Standard Users username
inuser=$SUDO_USER

#install oh my zsh
install curl
install zsh
echo -e "Installing: Oh my ZSH from external provider [-]"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 0<&-
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo -e "Oh my ZSH installation: [\033[33m-\e[0m] Check after logon"

#ensure shell changed
usermod -s /usr/bin/zsh ${inuser}
echo -e "${inuser} shell: changed to zsh [\033[32m*\e[0m]OK"

#Install Applications
install vim
install git
install powerline
install cowsay
install fortune
install terminator
install snap
install wireshark
install gnome-tweak-tool
install nmap
install plank
install chrome-gnome-shell
install locate 

snap install code --classic

#GDM Background Changer
echo "Getting GDM Background Changer"
git clone https://github.com/thiggy01/gdm-background
cd ./gdm-background/debs
dpkg -i ubuntu*$(cat /etc/*-release | grep VERSION_ID | grep -Eo '[0-9][0-9].[0-9][0-9]')* >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m] GDM Background OK" || echo -e "[\033[31m-\e[0m] FAILED try installing deb manually, is you're ubuntu supported? check $(pwd) for debs"

#copy files to correct directories
cp rssh.conf /etc/rssh.conf
cp .vimrc /home/${inuser}/
chown $inuser:$inuser /home/$inuser/.vimrc
cp .zshrc /home/${inuser}/
chown $inuser:$inuser /home/$inuser/.zshrc
echo -e "Copy Config Files: [\033[32m*\e[0m]OK"
cp -r ~/.oh-my-zsh /home/${inuser}/
chown -R $inuser:$inuser /home/$inuser/.oh-my-zsh
cp agnoster.zsh.theme /home/$inuser/.oh-my-zsh/themes/agnoster.zsh-theme

#remove my username with set username
sed -i -e "s/setupuser/"${inuser}"/g" /home/"${inuser}"/zshrc
sed -i -e "s/root/"${inuser}"/g" /home/"${inuser}"/.zshrc
sed -i -e "s/user/"${inuser}"/g" /home/"${inuser}"/.zshrc
echo "fortune | cowsay" >> /home/"${inuser}"/.zshrc 


echo -e "[\033[32m*Setup Complete*\e[0m]: Please log out and back in"

git restore .zshrc >/dev/null 2>/dev/nul
