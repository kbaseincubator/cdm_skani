# cdm_skani: generic skani ANI calculator (no bundled reference data).
#
# Skani version is pinned to 0.3.1 by copying the binary out of
# ecogenomic/gtdbtk:2.7.2. That image is the one whose internal `skani sketch`
# produced the GTDB R232 reference sketches we ship with cdm_skani_gtdb, so
# pinning the same binary here guarantees sketch-format compatibility across
# the pair. Skani 0.3.2 (the current upstream release) likely also reads 0.3.1
# sketches, but version drift on the sketch format is a real failure mode and
# we have no reason to chase it.
#
# Multi-stage to keep the runtime image slim: only the ~3 MB skani binary
# leaves the gtdbtk image.

FROM ecogenomic/gtdbtk:2.7.2 AS source

FROM ubuntu:jammy

COPY --from=source /usr/bin/skani /usr/local/bin/skani

ENV LC_ALL=C
WORKDIR /data

ENTRYPOINT ["skani"]
