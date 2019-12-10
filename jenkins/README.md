ZenHub DevOps Test
-------------------------

# Working on Jenkins
Run:
```
docker rm -f jen_dev || true && docker build -t jenkins . && docker run --env-file dev.env --name jen_dev --privileged -p 8080:8080 jenkins
```

Then go to localhost:8080, user is "admin" and password is "test" (given as env).

# cleanup
```
docker stack rm  app
```
