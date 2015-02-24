TAG=$(shell git rev-parse --short HEAD)

IMAGE=training/docker-fundamentals-image
CONTAINER=showoff
PAPER=US-Letter

default:
	# Available targets:
	# - release (tag slides and run showoff)
	# - dev (don't tag slides; run showoff with a volume)
	# - pdf (generate PDF files; requires showoff container)

release:
	# Is working directory clean? If you get an error here, run "make dev" instead.
	git diff-index --quiet HEAD

	# Add git commit id to training slides before building 
	find . -name *.css -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;
	find . -name *.json -exec sed -i "s/{{DOCKER_TRAINING_VERSION}}/$(TAG)/" {} \;

	# Optionally set paper size
	find . -name *.css -exec sed -i "s/US-Letter/$(PAPER)/" {} \;

	# Build updated docker image
	docker build -t $(IMAGE) .

	# Reset to old
	git reset --hard HEAD

	# Remove the old container (if there is one)
	# and start a new one.
	docker rm -f $(CONTAINER) || true
	docker run -d --name $(CONTAINER) -p 9090:9090 $(IMAGE)

dev:
	# Build updated docker image
	docker build -t $(IMAGE) .
	# Remove the old container (if there is one)
	docker rm -f $(CONTAINER) 2>/dev/null || true
	# Run container with volume to slides to make changes on the fly
	docker run -d --name $(CONTAINER) -v $(shell pwd)/slides:/slides -p 9090:9090 $(IMAGE)

pdf:
	# The showoff container has to be running (through "make release" or "make dev")
	docker inspect --format='{{""}}' showoff
	docker run --rm --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/print -o - > DockerSlides.pdf
	docker run --rm --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/supplemental/exercises/print -o - > DockerExercises.pdf
