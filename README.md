# Preparing for on-premise installation
The requirements-check.sh script is an auxiliary tool to check for 
hardware and software minimal requirements before installing Labforward
platform.

It can be run directly on physical machines, docker images or docker containers.


# Using this script
Target system must have bash and curl in order for the script to work.


# Download and execute
	curl -sL -o requirements-check.sh  https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh
	sudo bash ./requirements-check.sh

# Curl it and run it
This option is great for one liners fans, but be aware that is not advisable to run scripts from unknown sources this way.

## Directly on host machines (bare metal)

	bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )

## On docker images
	docker run <<IMAGE_NAME:IMAGE_TAG>> bash -c "bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )"

Example. Running on an oraclelinux image:
	docker run oraclelinux:9 bash -c "bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )"

## On running docker containers
	docker exec <<CONTAINER_ID>> bash -c "bash <(curl -sL https://raw.githubusercontent.com/labforward/installation/main/requirements-check.sh )"

 [![asciicast](https://asciinema.org/a/6WGUwvCfkr1IkkDXORw6U2qH1.svg)](https://asciinema.org/a/6WGUwvCfkr1IkkDXORw6U2qH1)

