# Server setup
- Run `wget https://gitlab.com/erfanio/server_setup/-/raw/master/init.sh -O init.sh`
- Inspect `init.sh` and run it `bash init.sh INSERT_USERNAME` (username is used to create a new user and the script will disable the root user)
- Now you should probably restart (especially if you saw the kernel being upgraded)
- SSH (or mosh) into your newly created account and run `bash ~/dotfiles/init.sh`
- Optional: Logout and back in so you get your new fancy zsh
- Run `bash ~/server_setup/setup.sh`
