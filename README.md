# SSI Verifiable Credential Verification policies using Open Policy Agent through walt.id
#### BME VIK Mérnökinformatikus MSC Önálló Laboratórium 1 - 2023 tavasz

## How to
### Install [walt.id](https://walt.id/)

1. Pulling the project directly from DockerHub
```
docker pull waltid/ssikit
```
2. Setting and alias for convenience
```
alias ssikit="docker container run -p 7000-7004:7000-7004 -itv $(pwd)/data:/app/data docker.io/waltid/ssikit"
```

3. Getting an overview of the commands and options available
```
ssikit -h
```