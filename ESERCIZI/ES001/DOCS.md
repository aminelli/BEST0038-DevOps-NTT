# Note

## Approccio imperativo

```sh

# Immagini docker 
# https://hub.docker.com/r/gitlab/gitlab-ce
docker pull gitlab/gitlab-ce:nightly

sudo docker run --detach \
  --hostname gitlab.example.com \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab:Z \
  --volume $GITLAB_HOME/logs:/var/log/gitlab:Z \
  --volume $GITLAB_HOME/data:/var/opt/gitlab:Z \
  --shm-size 256m \
  gitlab/gitlab-ce:nightly

sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

```

## Approccio Dichiarativo

```sh

docker compose -p corso up -d gitlab

```
