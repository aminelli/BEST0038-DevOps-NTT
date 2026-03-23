# Note

## Approccio imperativo

```sh

# Immagini docker 

## GITLAB
# https://docs.gitlab.com/install/docker/installation/
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

# Credenziali
# root 

# Per recuperare la password di gitlab
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password


### JENKINS
# https://github.com/jenkinsci/docker
# https://hub.docker.com/r/jenkins/jenkins

docker pull jenkins/jenkins:lts

# Credenziali
# admin 

# Per recuperare la password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

```

## Approccio Dichiarativo

```sh

# Tutti i container:
docker compose -p corso up -d

# Solo Gitlab
docker compose -p corso up -d gitlab

# Solo Jenkins
docker compose -p corso up -d gitlab

```
