# 2.Устанавливаем docker
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash
# 3.Создаем алиас
echo "alias ironfish='docker exec ironfish ./bin/run'" >> ~/.profile
source ~/.profile
# 4. Запускаем контейнеры
sudo tee <<EOF >/dev/null $HOME/docker-compose.yaml
    version: "3.3"
    services:
     ironfish:
      container_name: ironfish
      image: ghcr.io/iron-fish/ironfish:latest
      restart: always
      network_mode: "host"
      entrypoint: sh -c "apt update > /dev/null && apt install curl -y > /dev/null; ./bin/run start"
      healthcheck:
       test: "curl -s -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://127.0.0.1:9033 || killall5 -9"
       interval: 180s
       timeout: 180s
       retries: 3
      volumes:
       - $HOME/.ironfish:/root/.ironfish
     ironfish-miner:
      depends_on:
       - ironfish
      container_name: ironfish-miner
      image: ghcr.io/iron-fish/ironfish:latest
      command: miners:start --threads=-1
      network_mode: "host"
      restart: always
      volumes:
       - $HOME/.ironfish:/root/.ironfish
    EOF
#############################################3
docker-compose up -d
# Смотрим логи:
docker-compose logs -f --tail=100
# 5.Создаем кошелек и выбираем его по умолчанию, запрашиваем монеты
ironfish accounts:create myname
# Указываем имя ноды/кошелька вместо myname, вывод копируем
ironfish accounts:use myname
# Вместо myname подставляете свое название кошелька
docker-compose restart 
# Присваиваем имя ноды:
ironfish config:set nodeName myname
ironfish config:set blockGraffiti myname
# Вместо myname подставляете свое название кошелька
