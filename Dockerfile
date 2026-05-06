FROM mambaorg/micromamba:1.5-jammy

USER root
WORKDIR /app

ENV MPLBACKEND=Agg \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --chown=$MAMBA_USER:$MAMBA_USER requirements/env_climada.yml ./environment.yml
RUN micromamba install -y -n base -f environment.yml && \
    micromamba clean -ya

COPY pyproject.toml README.md LICENSE MANIFEST.in ./
COPY climada ./climada
COPY runner.py ./

RUN micromamba run -n base pip install --no-cache-dir --no-deps -e .

ENTRYPOINT ["micromamba", "run", "-n", "base", "python", "runner.py"]
CMD ["-"]
