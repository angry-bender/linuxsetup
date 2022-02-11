#!/bin/bash
#function to install apps with a clean log output
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

scriptdir=$(pwd)

# #format disk
parted /dev/sdc --script mklabel gpt mkpart extpart ext4 0% 100%
sleep 1
mkfs -t ext4 -L rootfs /dev/sdc1
mkdir /mnt/datadrive && sudo mount /dev/sdc1 /mnt/datadrive

#I then need to figre out how to add this uuid to fstab for when the VM is rebooted
uuid="$(blkid /dev/sdc1 | awk '{print $3}' | sed s/\"//g)"
echo "$uuid"
echo "$uuid /mnt/datadrive ext4 defaults,nofail   1 2" >> /etc/fstab


#Installation options

#Check working directory
FILE=.zshrc
if test -f "$FILE"; then
    echo -e "Working Directory Check: [\033[32m*\e[0m]OK"
    else
        echo -e "Working Directory Check: [\033[31m-\e[0m] FAILED"
        echo "Please change to the downloaded direectory with file and run directly from there"
        echo "This script will now exit"
        exit 1
fi

#Set the username to configure
inuser="AzureUser"

#install oh my zsh
install curl
install zsh
echo -e "Installing: Oh my ZSH from external provider [-]"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 0<&-
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

echo -e "Oh my ZSH installation: [\033[33m-\e[0m] Check after logon"

#ensure shell changed
usermod -s /usr/bin/zsh ${inuser}
usermod -s /usr/bin/zsh root
echo -e "${inuser} shell: changed to zsh [\033[32m*\e[0m]OK"

#Update package lists
sudo apt update

#Install Applications
install vim
install git
install powerline
install mlocate

#copy files to correct directories
cp .vimrc /home/${inuser}/
cp .vimrc /root/
chown $inuser:$inuser /home/$inuser/.vimrc
chown root:root /root/.vimrc
cp .zshrc /home/${inuser}/
cp .zshrc /root/
chown $inuser:$inuser /home/$inuser/.zshrc
chown root:root /root/.zshrc
echo -e "Copy Config Files: [\033[32m*\e[0m]OK"
cp -r ./~/.oh-my-zsh /root/
chown -R root:root /root/.oh-my-zsh
cp -r ~/.oh-my-zsh /home/${inuser}/
chown -R $inuser:$inuser /home/$inuser/.oh-my-zsh


#remove .zshrc username with set username
sed -i -e "s/user/"${inuser}"/g" /home/"${inuser}"/.zshrc
sed -i -e "s/\/home\/user/\/root\//g" /root/.zshrc

git restore .zshrc >/dev/null 2>/dev/nul
