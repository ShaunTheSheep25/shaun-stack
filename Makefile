.PHONY: up down logs test lint

up:
	docker-compose up --build

down:
	docker-compose down

logs:
	docker-compose logs -f

test:
	cd ../fari-checkins && pytest tests/
	cd ../senpai-lessons && pytest tests/
	cd ../sentinel-events && pytest tests/

lint:
	cd ../fari-checkins && ruff check .
	cd ../senpai-lessons && ruff check .
	cd ../sentinel-events && ruff check .