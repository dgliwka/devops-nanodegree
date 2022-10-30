setup:
	python3 -m venv venv

install:
	source ./venv/bin/activate;
	which pip
	pip install --upgrade pip
	pip install -r requirements.txt

test:
	python -m pytest -vv test*.py

lint:
	pylint --disable=R,C,W1203,W0702 app.py

all: install lint test
