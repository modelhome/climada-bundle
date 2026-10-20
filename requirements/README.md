# Conda lock

`climada-linux-64.lock` is the exact package list the image installs. The
Dockerfile installs from it with no solve, which keeps the build well under 4Gi
(solving upstream's `env_climada.yml` was OOMKilled at 4Gi).

It was generated from `requirements/env_climada.yml` at the upstream commit
Model Home builds from, CLIMADA v6.1.0:

    CLIMADA-project/climada_python@bb9595944fcf673152ea53e61efbafeb0b1e4406

That commit is the `commit_sha` in Model Home's seed (`backend/app/seeds.py`,
Hurricane Loss Model). If the seed moves to a new upstream commit, regenerate
the lock from that commit's env file, or the build will install packages that
were never solved against that CLIMADA version.

## Regenerate

Lock for linux-64 (production nodes are amd64), not for your host:

```sh
curl -fsSL -o env_climada.yml \
  https://raw.githubusercontent.com/CLIMADA-project/climada_python/<commit>/requirements/env_climada.yml
docker run --rm --platform linux/amd64 -v "$PWD:/w" mambaorg/micromamba:1.5-jammy bash -c '
  micromamba install -y -n base -c conda-forge python=3.12 -f /w/env_climada.yml &&
  micromamba env export -n base --explicit --md5 > /w/climada-linux-64.lock'
```

Then copy `climada-linux-64.lock` here and update the commit above.
