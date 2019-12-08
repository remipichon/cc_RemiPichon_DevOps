ZenHub DevOps Test
-------------------------

# Getting started

```
docker swarm init
# a local Docker Registry to publish the app (required for Swarm mode)
docker service create --name registry --publish published=5000,target=5000 registry:2
# build and push via docker-compose
docker-compose build 
docker-compose push 
# init Swarm and deploy app
docker stack deploy --compose-file docker-compose.yml app
 
```

Working on the app code
```
docker-compose build && docker-compose push && docker service update --force app_api
```

# cleanup
```
docker stack rm  app
```

