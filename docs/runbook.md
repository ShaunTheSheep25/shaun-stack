# Runbook

## Bring the stack up
make up

## Verify it's working (smoke test)
curl http://127.0.0.1:8001/residents/
curl http://127.0.0.1:8002/auth/login -X POST ...
curl http://127.0.0.1:8003/events/

## View logs
make logs

## Tear down
make down

## Common issues
- Port already in use: check nothing else is running on 8001-8003
- Database errors: ensure volumes were created — docker volume ls