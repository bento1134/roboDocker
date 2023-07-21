# roboDocker
Jerry's Docker image working with guis

## Docker-Compose
Docker Compose is used at a large scale to syncronize many apps together, but for our uses, it is simply so I don't have to write the full command every time.
To install, simply run
```bash
sudo dnf install docker-compose
```
## Configuring
To ensure this works, in docker-compose.yml, you need to change the "image" variable to whatever you named the image you built. You will also need to run 
```bash
xhost +
```
to ensure everything runs properly.

## Running
Finnaly, you will run
```bash
cd /path/to/docker-compose.yml/
docker-compose up --d
docker-compose exec ros2 bash
```

