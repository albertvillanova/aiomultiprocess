SRCS:=aiomultiprocess setup.py
build:
	python setup.py build

dev:
	python setup.py develop

setup:
	python -m pip install -Ur requirements-dev.txt

.venv:
	python -m venv .venv
	source .venv/bin/activate && make setup dev
	echo 'run `source .venv/bin/activate` to use virtualenv'

venv: .venv

release: lint test clean
	python setup.py sdist
	python -m twine upload dist/*

format:
	python -m usort format $(SRCS)
	python -m black $(SRCS)

lint:
	python -m mypy $(SRCS)
	python -m pylint --rcfile .pylint $(SRCS)
	python -m usort check $(SRCS)
	python -m black --check $(SRCS)

test:
	python -m coverage run -m aiomultiprocess.tests
	python -m coverage combine
	python -m coverage report

perf:
	export PERF_TESTS=1 && make test

html: .venv README.md docs/* docs/*/* aiomultiprocess/*
	source .venv/bin/activate && sphinx-build -b html docs html

clean:
	rm -rf build dist html README MANIFEST aiomultiprocess.egg-info

distclean: clean
	rm -rf .venv

.PHONY: CHANGELOG.md
CHANGELOG.md:
	attribution > CHANGELOG.md