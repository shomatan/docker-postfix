IMAGE_NAME = postfix-test

.PHONY: build
build:
	docker build . -t $(IMAGE_NAME)

.PHONY: destroy
destroy:
	@if `docker images | grep -q $(IMAGE_NAME)`; then\
		docker rmi $(IMAGE_NAME); \
	fi