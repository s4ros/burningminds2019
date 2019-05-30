# Requirements

Before we start you need to prepare some stuff.

## Your MacOs

### Terminal

- I recommend installing iTerm2
  - https://www.iterm2.com/

### Docker
- login/create account on Docker Hub
  - https://hub.docker.com/
- please install Docker For Mac - https://docs.docker.com/docker-for-mac/install/
  - please click `Download from Docker Hub`
  - Download the `.dmg` image and then follow the installation instructions - https://docs.docker.com/docker-for-mac/install/#install-and-run-docker-desktop-for-mac

## CircleCI - https://circleci.com
- please login using your GitHub account

---------------------------------------------------------------------------

# Workshop Steps
- all of the participants have their own EC2 nano instance to use
- FQDN is `YOUR_NAME.bm.devguru.co`
- ssh port: `22`
- ssh user: `ubuntu`
- ssh private key can be obtainer requesting `GET YOUR_NAME.bm.devguru.co/dej_klucz`

## Create new repository on GitHub with README.md
- https://github.com/new

## Configure `~/.ssh/config` and clone new repo

- Download ssh private key

```shell
curl YOUR_NAME.bm.devguru.co/dej_klucz | tee ~/.ssh/burningminds
chmod 600 ~/.ssh/burningminds
ssh-add ~/.ssh/burningminds
```

- `~/.ssh/config`

```shell
Host burningminds.repo
  Hostname github.com
  User git
  Port 22
  IdentityFile ~/.ssh/burningminds

Host burningminds
  Hostname YOUR_NAME.bm.devguru.co
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/burningminds
```

- Test ssh connectivity

```shell
ssh burningminds.repo
ssh burningminds 'docker kill kluczyk'
```

- connect to your server and download public key

```shell
ssh burningminds 'cat ~/.ssh/id_rsa.pub'
```

- add you public key to the GitHub account

- Clone the repo

```shell
git clone burningminds.repo:YOUR_GH_ID/REPO_NAME
```

## Download WordPress
- Go to Google -> search for: `wordpress download`
- Download wordpress

```shell
wget wordpress_download_link_here.tar.gz
```

- Unpack it:

```shell
tar -zxvf archive.tar.gz
```
- git initial commit

```shell
git add -Av .
git commit -m 'Initial WordPress commit'
git push origin master
```

## Launch Dockerized MySQL server

- search for image on Docker Hub
- run mysql container

```shell
docker run -d --rm --name mysql \
-e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_DATABASE=wordpress \
mysql:5
```

## Wordpress Dockerfile
- create Dockerfile: `touch Dockerfile`

```Dockerfile
FROM ubuntu:16.04

RUN apt update
RUN apt upgrade -y -qq
RUN apt install php php-mysql -y -qq

COPY wordpress /wordpress
WORKDIR /wordpress

CMD ["php", "-S", "0.0.0.0:80"]
```

- build docker image

```shell
docker build -t s4ros/bm-wordpress .
```
## wp-config.php

- copy the sample file and create the `wp-config.php`

```shell
cd wordpress/
cp wp-config-sample.php wp-config.php
```

- change all the `DB_*` config variables to use `getenv()` function

```php
define( 'DB_NAME', getenv('DB_NAME') )
define( 'DB_USER', getenv('DB_USER') );
define( 'DB_PASSWORD', getenv('DB_PASSWORD') );
define( 'DB_HOST', getenv('DB_HOST') );
```

## Run WordPress container

- on Mac OS X we cannot bind any network app to ports like `80` nor `443` nor `8080` because of ESET
- so, we will bind our WordPress application to port `8899` ;)

```shell
docker run --rm --name wordpress \
-p 8899:80 \
-e DB_NAME=wordpress \
-e DB_USER=root \
-e DB_PASSWORD=root \
-e DB_HOST=mysql \
s4ros/bm-wordpress
```

### Connection issues

- create external docker network

```shell
docker network create wordpress
```

- recreate MySQL container and attach it to the external docker network

```shell
docker kill mysql

docker run -d --rm --name mysql \
-e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_DATABASE=wordpress \
--network wordpress \
mysql:5
```

- recreate WordPress container and attach it to the external docker network

```shell
docker kill wordpress

docker run --rm --name wordpress \
--network wordpress \
-p 8899:80 \
-e DB_NAME=wordpress \
-e DB_USER=root \
-e DB_PASSWORD=root \
-e DB_HOST=mysql \
s4ros/bm-wordpress
```

## docker-compose

```shell
touch docker-compose.yml
```

```yaml
version: "3.7"
services:
  wordpress:
    image: s4ros/bm-wordpress
    build: .
    ports:
      - "8899:80"
    environment:
      DB_USER: root
      DB_PASSWORD: root
      DB_NAME: wordpress
      DB_HOST: mysql
    networks:
      - wordpress

  mysql:
    image: mysql:5
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
    networks:
      - wordpress
    volumes:
      - ./persistent_mysql_data:/var/lib/mysql

networks:
  wordpress:
    external: true
```

## persistent volume for mysql

## deployment
- get capistrano configuration files

```shell
wget -O - s4ros.it/deployment.tar.gz | tar -zxvf -
```

- try to execute deployment manually first
  - remember to have you ssh private key added into `ssh-agent` - `ssh-add -l`

```shell
cd deployment/
bundle install
bundle exec cap staging deploy
```

- what if you don't have Ruby installed (or you don't want it)?
  - (you still will have to install `openssh` package within the container)

```shell
docker run --rm --name ruby-deployer -it \
-v $(pwd):/app \
-w /app \
-v ${HOME}/.ssh:/root/.ssh \
ruby:2.4-alpine ash
```

### Ruby 2.4 alpine image with openssh client installed

#### Dockerfile

```Dockerfile
FROM ruby:2.4-alpine
RUN apk update
RUN apk add openssh
CMD ["ash"]
```

#### Image build

```shell
docker build -t ruby-deployer .
```

#### Use container

```shell
docker run --rm --name ruby-deployer \
-v ${HOME}/.ssh:/root/.ssh:ro \
-v $(pwd):/app \
-w /app \
ruby-developer ash
```

and you still will have to execute `bundle install` and `bundle exec cap staging deploy` manually

## circleci
```shell
mkdir .circleci
touch .circleci/config.yml
```

```yml
version: 2.1

executors:
  deploy:
    working_directory: ~/repo
    docker:
      - image: circleci/ruby:2.4.3

jobs:
  checkout_code:
    executor: ruby
    steps:
      - checkout
      - persiste_to_workspace:
          root: ~/repo
          paths:
            - .

  deploy_staging:
    executor: ruby
    working_directory: ~/repo/deployment
    steps:
      - attach_workspace:
          at: ~/repo
      - run:
          name: bundle config
          command: bundle config --local path ~/repo/deployment/vendor/bundle
      - run:
          name: Deploy to staging
          command: bundle install; bundle exec cap staging deploy
```

## SWAP space activation
```shell
sudo fallocate -l 4GB /4GB.swap
sudo mkswap /4GB.swap
sudo chmod 0600 /4GB.swap
sudo swapon /4GB.swap
```

## nginx-proxy with letsencrypt companion?
