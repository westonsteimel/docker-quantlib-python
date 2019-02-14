.PHONY: build
build: ## Builds all the dockerfiles in the repository.
	@$(CURDIR)/build.sh

REGISTRY := westonsteimel
.PHONY: image
image: ## Build a Dockerfile (ex. DIR=telnet).
	@:$(call check_defined, DIR, directory of the Dockefile)
	docker build --rm --force-rm -t $(REGISTRY)/$(subst /,:,$(DIR)) ./$(DIR)

.PHONY: test
test: shellcheck ## Runs the tests on the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir "/usr/src" \
		"westonsteimel/shellcheck:alpine" ./shellcheck.sh

.PHONY: generate
generate:
	@$(CURDIR)/generate.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
