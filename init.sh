echo "Install ZSH"
sudo apt update && sudo apt install zsh

echo "Create erfan user"
sudo adduser --system --group erfan

echo "Clone dotfiles"
git clone https://github.com/erfanio/dotfiles.git /home/erfan/dotfiles
git clone https://gitlab.com/erfanio/server_setup.git /home/erfan/server_setup
chown erfan:erfan /home/erfan -R

echo "Copying ssh keys from root to erfan"
mkdir -p /home/erfan/.ssh
cp /root/.ssh/authorized_keys /home/erfan/.ssh/authorized_keys
