
sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    unzip \
    wget \
    gnupg \
    lsb-release

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu

sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 

sudo cat > Dockerfile << EOF
FROM jenkins/jenkins:2.314
USER root
RUN apt-get update && \
apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    software-properties-common && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    unzip awscliv2.zip \
    ./aws/install \
    rm awscliv2.zip \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
apt-get update && \
apt-get -y install docker-ce
RUN usermod -a -G docker jenkins
    EOF

sudo cat > docker-compose.yaml << EOF
version: '3.7'

services:
  jenkins:
    build: ./Dockerfile-Jenkins
    image: finspire_jenkins:2.314
    container_name: jenkins
    privileged: true
    restart: always
    ports:
      - "50000:50000"
      - "8080:8080"
    networks:
      - finspire 
    volumes:
      - jenkins-log:/var/log/jenkins
      - jenkins-data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /data/docker/bind-mounts/jenkins/downloads:/var/jenkins_home/downloads
      - /usr/bin/docker:/usr/bin/docker

    environment:
      - VIRTUAL_HOST=jenkins.finspire.tech
      - VIRTUAL_PORT=8080
      - JAVA_OPTS=-Xmx4g
      - LETSENCRYPT_HOST=jenkins.finspire.tech
      - LETSENCRYPT_EMAIL=admin@finspiretech.com
        #- SSH_AUTH_SOCK=/ssh-agent

  nginx-proxy:
    image: jwilder/nginx-proxy:0.9
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /opt/nginx/conf:/etc/nginx/conf.d
      - /opt/nginx/vhost:/etc/nginx/vhost.d
      - /opt/nginx/htpasswd:/etc/nginx/htpasswd
      - html:/usr/share/nginx/html
      - dhparam:/etc/nginx/dhparam
      - /opt/nginx/certs/:/etc/nginx/certs:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
    restart: always
    networks:
      - finspire 
  
  letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: nginx-proxy-le
    depends_on:
      - nginx-proxy
    volumes:
      - /opt/nginx/conf:/etc/nginx/conf.d
      - /opt/nginx/vhost:/etc/nginx/vhost.d
      - html:/usr/share/nginx/html
      - dhparam:/etc/nginx/dhparam
      - /opt/nginx/certs/:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      NGINX_PROXY_CONTAINER: nginx-proxy
    restart: always
    networks:
      - finspire

volumes:
  jenkins-log:
  jenkins-data:
  dhparam:
  html:

networks:
  finspire:
    name: finspire
    driver: bridge   

EOF

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install 

sudo docker-compose up -d