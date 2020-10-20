cd /etc/docker
cat <<EOF >>daemon.json
{
    "debug" : true,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "http://$1:3100/loki/api/v1/push"
    }
}
EOF

cd ~

sudo apt update
sleep 2
sudo apt install curl
sleep 2
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sleep 2
sudo chmod +x /usr/local/bin/docker-compose
sleep 2
chmod -R 777 ~/prometheus/ 
sleep 2
chmod -R 777 ~/loki/
sleep 2
cd ~/prometheus
sudo docker-compose up -d
sleep 2
cd ~/loki
sudo docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
sleep 2
sudo docker plugin ls
sudo docker-compose up -d
sleep 2
sudo docker ps -a
chmod -R 777 ~/prometheus/ 
chmod -R 777 ~/loki/
sleep 2
sudo docker ps -a

cd ~
sudo docker stop keep-client
sleep 2
sudo docker rm keep-client
sleep 2

sudo docker run -dit --restart always --log-driver loki --log-opt loki-url="http://$1:3100/loki/api/v1/push" --volume $HOME/keep-client:/mnt --env KEEP_ETHEREUM_PASSWORD=$KEEP_CLIENT_ETHEREUM_PASSWORD --env LOG_LEVEL=info --name keep-client -p 3919:3919 keepnetwork/keep-client:v1.3.0-rc.4 --config /mnt/config/config.toml start
sleep 2
sudo docker ps -a
docker logs --tail 10 keep-client -f

