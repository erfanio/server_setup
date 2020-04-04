NEW_USER=${1:-erfan}

echo "Install ZSH"
sudo apt update && sudo apt install zsh

echo "Create new user $NEW_USER"
sudo adduser --system --group $NEW_USER
echo "Enter a password for the new user"
sudo passwd $NEW_USER
# disable root login
sudo usermod --shell /usr/sbin/nologin root


echo "Clone dotfiles"
git clone https://github.com/erfanio/dotfiles.git /home/$NEW_USER/dotfiles
git clone https://gitlab.com/erfanio/server_setup.git /home/$NEW_USER/server_setup
chown $NEW_USER:$NEW_USER /home/$NEW_USER -R

echo "Copying ssh keys from root to $NEW_USER"
mkdir -p /home/$NEW_USER/.ssh
cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/authorized_keys
