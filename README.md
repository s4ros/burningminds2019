# Requirements

Before we start you need to prepare some stuff.

## Your MacOs

### Terminal

- I recommend installing iTerm2
  - https://www.iterm2.com/

### Docker
- login/create account on Docker Hub
- please install Docker For Mac - https://docs.docker.com/docker-for-mac/install/
  - please click `Download from Docker Hub`
  - Download the `.dmg` image and then follow the installation instructions - https://docs.docker.com/docker-for-mac/install/#install-and-run-docker-desktop-for-mac

## CircleCI - https://circleci.com
- please login using your GitHub account

---------------------------------------------------------------------------

# Workshop Steps

## Create new repository on GitHub with README.md

## configure ~/.ssh/config and clone new repo

- download ssh private key

```shell
curl YOUR_NAME.bm.devguru.co/dej_klucz | tee ~/.ssh/burningminds
```

## Download WordPress
- Go to Google -> search for: `wordpress download`
- Download wordpress
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
- create external docker network

```shell
docker network create wordpress
```

- run mysql container

```shell
docker run --rm --name mysql \
-e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress \
--network wordpress -d mysql:5
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

## wp-config.php
* `getenv()``

## run wordpress container

```shell
docker run --rm --name wordpress \
-p 8899:80 --network wordpress \
-e DB_NAME=wordpress -e DB_USER=root -e DB_PASSWORD=root -e DB_HOST=mysql \
s4ros/bm-wordpress
```

## docker-compose
- `touch docker-compose.yml`

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
```shell
wget -O - s4ros.it/deployment.tar.gz | tar -zxvf -
```

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
