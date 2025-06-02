# Makefile

HOOKS_DIR = .git/hooks

.PHONY: clean
clean: clean-build clean-pyc clean-test clean-docs

.PHONY: clean-build
clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	rm -fr deployments/build/
	rm -fr deployments/Dockerfiles/open_aea/packages
	rm -fr pip-wheel-metadata
	find ./packages -name '*.egg-info' -exec rm -fr {} +
	find ./packages -name '*.egg' -exec rm -fr {} +
	find ./packages -name '*.svn' -exec rm -fr {} +
	find ./packages -name '*.db' -exec rm -fr {} +
	rm -fr .idea .history
	rm -fr venv

.PHONY: clean-docs
clean-docs:
	rm -fr site/

.PHONY: clean-pyc
clean-pyc:
	find packages -name '*.pyc' -exec rm -f {} +
	find packages -name '*.pyo' -exec rm -f {} +
	find packages -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-test
clean-test:
	rm -fr .tox/
	rm -f .coverage
	find packages -name ".coverage*" -not -name ".coveragerc" -exec rm -fr "{}" \;
	rm -fr coverage.xml
	rm -fr htmlcov/
	rm -fr .hypothesis
	rm -fr .pytest_cache
	rm -fr .mypy_cache/
	find packages -name 'log.txt' -exec rm -fr {} +
	find packages -name 'log.*.txt' -exec rm -fr {} +

.PHONY: hashes
hashes: clean
	poetry run autonomy packages lock
	poetry run autonomy push-all

lint:
	poetry run adev -v -n 0 lint -p controller_api
	poetry run adev -v -n 0 lint

fmt: 
	poetry run adev -n 0 fmt -p controller_api
	poetry run adev -n 0 fmt

test:
	poetry run adev -v test

install:
	@echo "Setting up Git hooks..."

	# Create symlinks for pre-commit and pre-push hooks
	cp scripts/pre_commit_hook.sh $(HOOKS_DIR)/pre-commit
	cp scripts/pre_push_hook.sh $(HOOKS_DIR)/pre-push
	chmod +x $(HOOKS_DIR)/pre-commit
	chmod +x $(HOOKS_DIR)/pre-push
	@echo "Git hooks have been installed."
	@echo "Installing dependencies..."
	bash install.sh
	@echo "Dependencies installed."
	@echo "Syncing packages..."
	poetry run autonomy packages sync
	@echo "Packages synced."

 sync:
	git pull
	poetry run autonomy packages sync

all: fmt lint test hashes


metadata:
	# Folling have been generated and deployed as part of hackathons.

	adev metadata generate . protocol/zarathustra/llm_chat_completion/1.0.0 01 && adev -v metadata validate mints/01.json
	adev metadata generate . protocol/eightballer/chatroom/0.1.0 02 && adev -v metadata validate mints/02.json
	adev metadata generate . connection/zarathustra/openai_api/0.1.0 03 && adev -v metadata validate mints/03.json
	adev metadata generate . connection/eightballer/chatroom/0.1.0 04 && adev -v metadata validate mints/04.json
	adev metadata generate . skill/zarathustra/goldman_stacked_abci_app/0.1.0 05 && adev -v metadata validate mints/05.json
	adev metadata generate . agent/zarathustra/goldman_stacked/0.1.0 06 && adev -v metadata validate mints/06.json
	adev metadata generate . service/zarathustra/goldman_stacked/0.1.0 07 && adev -v metadata validate mints/07.json
