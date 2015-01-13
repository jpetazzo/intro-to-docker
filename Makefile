# Check if we have x-www-browser (on Debian/Ubuntu), open (on Mac), or just
# display instructions otherwise.
URLOPENER=$(shell which x-www-browser || which open || echo "\#Please open this URL:")
URL=$(shell echo $(shell boot2docker ip 2>/dev/null) || echo "localhost")

IMAGE=training/docker-fundamentals-image
CONTAINER=showoff

showoff:
	docker build -t $(IMAGE) .
	# Remove the old image (if there is one)
	docker inspect $(CONTAINER) >/dev/null 2>&1 && docker rm -f $(CONTAINER) || true
	docker run -d --name $(CONTAINER) -v $(shell pwd)/slides:/slides -p 9090:9090 $(IMAGE)
	# wait for showoff to come up
	sleep 1
	$(URLOPENER) http://$(URL):9090/

pdf:
	git stash
	find . -name *.css -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;
	find . -name *.json -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;
	docker run --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/print -o - > DockerSlides.pdf
	docker run --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/supplemental/exercises/print -o - > DockerExercises.pdf
	git reset --hard HEAD
	git stash pop

