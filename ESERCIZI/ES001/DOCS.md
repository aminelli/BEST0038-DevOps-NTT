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
# 6hdpDb9jSgX+SxZ/jpCf9WgwVkNhmC+S7OT/20masos=

# Per recuperare la password di gitlab
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password


### JENKINS
# https://www.jenkins.io/doc/book/installing/docker/
# https://github.com/jenkinsci/docker
# https://hub.docker.com/r/jenkins/jenkins


docker pull jenkins/jenkins:lts

# Credenziali
# admin 
# 5cc51c5cd8b54377bb312c309e550189

# Per recuperare la password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword


## Sonar Qube

# https://hub.docker.com/_/sonarqube

docker pull sonarqube

## Prerequisiti: 
# LINUX: lanciare i seguenti comandi
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
# WINDOWS: Docker Desktop
wsl -d docker-desktop
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Volumi da creare
# /opt/sonarqube/data: data files, such as the embedded H2 database and Elasticsearch indexes
# /opt/sonarqube/logs: contains SonarQube logs about access, web process, CE process, Elasticsearch logs
# /opt/sonarqube/extensions: for 3rd party plugins

# Creazione container
docker run --name sonarqube-custom -p 9000:9000 sonarqube:community


```

## Approccio Dichiarativo

```sh

# Tutti i container:
docker compose -p corso up -d

# Solo Gitlab
docker compose -p corso up -d gitlab

# Solo Jenkins
docker compose -p corso up -d jenkins

# Solo Jenkins
docker compose -p corso up -d jenkins

# Solo Jenkins agent
docker compose -p corso up -d jenkins-ssh-agent

# Solo Jenkins agent
docker compose -p corso up -d sonar
```



## Plugins Jenkins da installare:

- https://plugins.jenkins.io/blueocean/
- https://plugins.jenkins.io/docker-plugin/
- https://plugins.jenkins.io/json-path-api/
- https://plugins.jenkins.io/docker-workflow/
- https://plugins.jenkins.io/docker-commons/
