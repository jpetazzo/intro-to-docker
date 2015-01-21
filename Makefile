TAG=$(shell git rev-parse --short HEAD)

IMAGE=training/docker-fundamentals-image
CONTAINER=showoff

showoff:
	# Add git commit id to training slides before building 
	git stash || true
	find . -name *.css -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;
	find . -name *.json -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;
	# Build updated docker image
	docker build -t $(IMAGE) .
	git reset --hard HEAD
	git stash pop || true

	# Remove the old container (if there is one)
	docker inspect $(CONTAINER) >/dev/null 2>&1 && docker rm -f $(CONTAINER) || true
	docker run -d --name $(CONTAINER) -p 9090:9090 $(IMAGE)

showoff-dev:
	# Build updated docker image
	docker build -t $(IMAGE) .
	# Remove the old container (if there is one)
	docker inspect $(CONTAINER) >/dev/null 2>&1 && docker rm -f $(CONTAINER) || true
	# Run container with volume to slides to make changes on the fly
	docker run -d --name $(CONTAINER) -v $(shell pwd)/slides:/slides -p 9090:9090 $(IMAGE)

pdf:
	docker run --rm --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/print -o - > DockerSlides.pdf
	docker run --rm --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/supplemental/exercises/print -o - > DockerExercises.pdf
