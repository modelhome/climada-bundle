FROM mambaorg/micromamba:1.5-jammy

USER root
WORKDIR /app

ENV MPLBACKEND=Agg \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Put the env on PATH directly rather than through micromamba's activation:
# on the production build nodes neither `micromamba run` nor the image's
# activating SHELL worked (one could not start pip, the other left it off
# PATH). PROJ_DATA and GDAL_DATA are what conda activation would have set.
ENV PATH=/opt/conda/bin:$PATH \
    PROJ_DATA=/opt/conda/share/proj \
    GDAL_DATA=/opt/conda/share/gdal

# Install from an explicit lock, not from upstream's env_climada.yml: solving
# its ~45 loose conda-forge constraints peaked above 4Gi and was OOMKilled.
# The lock is for linux-64 and was generated from env_climada.yml at the
# upstream commit the seed pins; see requirements/README.md to regenerate it.
COPY requirements/climada-linux-64.lock ./climada-linux-64.lock
RUN micromamba install -y -n base -f climada-linux-64.lock && \
    micromamba clean -ya

COPY pyproject.toml README.md LICENSE MANIFEST.in ./
COPY climada ./climada
COPY runner.py ./

RUN python -m pip install --no-cache-dir --no-deps -e .
ENTRYPOINT ["python", "runner.py"]

CMD ["-"]
