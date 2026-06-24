# shaun-stack

This mini-project combines the three InGen Beta Dynamics internship services as a single docker-compose stack. Each service is independently deployable but this repo brings them up together for local development and integration testing.

| Service | Port | Repo | Published Image |
|---|---|---|---|
| fari-checkins | 8001 | [link](https://github.com/ShaunTheSheep25/fari-checkins) | ghcr.io/shaunthesheep25/fari-checkins |
| senpai-lessons | 8002 | [link](https://github.com/ShaunTheSheep25/senpai-lessons) | ghcr.io/shaunthesheep25/senpai-lessons |
| sentinel-events | 8003 | [link](https://github.com/ShaunTheSheep25/sentinel-events) | ghcr.io/shaunthesheep25/sentinel-events |

(Do note that you must have the packages required to run Docker and docker-compose on your system.)

## How to run

```bash
git clone https://github.com/ShaunTheSheep25/shaun-stack.git
cd shaun-stack
make up
```

All three services will build and start automatically. Once running, visit the interactive docs for each service (this is the "smoke test" referenced in the project docs):

- http://127.0.0.1:8001/docs — fari-checkins (Fari: eldercare check-ins)
- http://127.0.0.1:8002/docs — senpai-lessons (Senpai: lesson management)
- http://127.0.0.1:8003/docs — sentinel-events (Sentinel: live event feed)

The different `make` commands available for the users to check out are as follows-

```bash
make up      # build and start all services
make down    # stop and remove containers
make logs    # tail logs from all services
make test    # run pytest across all three repos
make lint    # run ruff across all three repos
```

Do note that `make test` runs the full pytest suite for each service, and requires the service repos to be cloned as siblings in the given format -

inGen Work/
├── shaun-stack/
├── fari-checkins/
├── senpai-lessons/
└── sentinel-events/

Furthermore, on stopping using `make down`, the database volumes (`fari-data`, `senpai-data`) are preserved so that the database state survives restarts. To wipe them completely, do `docker volume rm shaun-stack_fari-data shaun-stack_senpai-data`.

## Limitations

There are multiple limitations with the way I've containerised these services, some of which are given as follows -

- Containers run as root, but this is not suitable for production (detailed in SECURITY.md)
- SQLite is used for persistence, but is usually not considered for multi-instance production deployments
- No resource limits set on containers
- sentinel-events event store is in-memory and lost on restart
