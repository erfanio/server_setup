# Change the time component in bullet train so the server environment is clearly different
echo "export BULLETTRAIN_TIME_BG=red
export BULLETTRAIN_TIME_FG=white" > $HOME/.zshrc_custom

sudo adduser --system --group rtorrent --shell /usr/sbin/nologin
sudo usermod -G rtorrent $USER

# create download folders
sudo -u rtorrent mkdir -p /home/rtorrent/.session
sudo -g rtorrent mkdir -p $HOME/totally_legal_stuff/shared
sudo -g rtorrent mkdir -p $HOME/totally_legal_stuff/movies
sudo -g rtorrent mkdir -p $HOME/totally_legal_stuff/media
sudo -g rtorrent mkdir -p $HOME/totally_legal_stuff/other

# install docker
sudo apt update && \
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# install docker compose (maybe change version)
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# run filemanager
sudo docker run -d --restart always \
  --name filebrowser \
  -v $HOME/totally_legal_stuff:/srv \
  -p 127.0.0.1:9000:80 \
  filebrowser/filebrowser

# create shared network for rtorrent and flood
sudo docker network create torrent

# run rtorrent
sudo docker container run -d --restart always \
  --name rtorrent \
  --hostname rtorrent \
  --network torrent \
  -p 50000:50000 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  --expose 16891 \
  -v $HOME/totally_legal_stuff:/home/rtorrent/rtorrent/download \
  -v rtorrent-session:/home/rtorrent/rtorrent/.session \
  tuxmealux/alpine-rtorrent

# build and run flood
git clone https://github.com/Flood-UI/flood.git $HOME/flood && cd $HOME/flood
sudo docker build -t  flood-github .

[ ! -f $HOME/.flood-secret ] && echo -n $(openssl rand -hex 32) > $HOME/.flood-secret
sudo docker run -d --restart always \
  --name flood \
  --hostname flood \
  --network torrent \
  -v flood-data:/data \
  -p 127.0.0.1:9010:3000 \
  -e FLOOD_SECRET=$(cat $HOME/.flood-secret) \
  -e RTORRENT_SCGI_HOST=rtorrent \
  -e RTORRENT_SCGI_PORT=16891 \
  flood-github

# download caddy
mkdir /tmp/caddy-dl
wget "https://caddyserver.com/download/linux/amd64?license=personal&telemetry=off" -O - | tar -xz -C /tmp/caddy-dl
sudo cp /tmp/caddy-dl/caddy /usr/local/bin/caddy
sudo setcap cap_net_bind_service=+ep /usr/local/bin/caddy

sudo cp $HOME/server_setup/Caddyfile /etc/caddy/
sudo chown root:root /etc/caddy/Caddyfile
sudo chmod 644 /etc/caddy/Caddyfile

sudo mkdir -p /var/log/caddy
sudo chown www-data:www-data /var/log/caddy
sudo chmod 750 /var/log/caddy

sudo cp $HOME/server_setup/caddy.service /etc/systemd/system/caddy.service
sudo chown root:root /etc/systemd/system/caddy.service
sudo chmod 644 /etc/systemd/system/caddy.service
sudo systemctl daemon-reload

echo "
TODO:
Download plex from https://www.plex.tv/media-server-downloads/ and sudo dpkg -i plex*.deb to install
Then set it up with ssh tunnel, ssh <SERVER_IP> -L 8888:localhost:32400

Add email to /etc/systemd/system/caddy.service, modify Caddyfile then start caddy

Change the filebrowser username and password
Setup flood user profile
"
