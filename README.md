# cdm_skani

CTS (CDM Task Service) job wrapper for [skani](https://github.com/bluenote-1577/skani), a fast average nucleotide identity (ANI) calculator for genomes, contigs, and MAGs.

This is the **generic, no-refdata** variant. For querying user genomes against the GTDB R232 reference sketch set, use [`cdm_skani_gtdb`](https://github.com/kbaseincubator/cdm_skani_gtdb) instead.

## Container

- Published to `ghcr.io/kbaseincubator/cdm_skani`
- Skani version: **0.3.1** (pinned, see below)
- Entrypoint: `skani` (no subcommand) - append `dist`, `triangle`, `search`, or `sketch` as the first argument

### Version pin

The skani binary is copied out of `ecogenomic/gtdbtk:2.7.2`, which ships skani 0.3.1. We pin to that exact binary so that `cdm_skani_gtdb` (which shares this same binary) is guaranteed to read the skani sketches that gtdbtk 2.7.2 built inside the GTDB R232 reference bundle. Sketch-format compatibility across skani versions is documented as "use the same version that built the database"; sticking to 0.3.1 across the pair removes that failure mode by construction.

## Usage modes

skani has four subcommands. CTS args follow `args=["<subcommand>", ...flags..., tscli.insert_files()]`.

### `dist` - direct pairwise ANI (no sketching)

```python
job = tscli.submit_job(
    "ghcr.io/kbaseincubator/cdm_skani:0.1.0",
    [query_genome, reference_genome],
    "cts/io/<user>/output/skani_dist/run1",
    cluster="kbase",
    declobber=True,
    output_mount_point="/out",
    args=[
        "dist",
        "-o", "/out/ani.tsv",
        "-q", "/path/to/query.fna",   # see CTS docs for input mount layout
        "-r", "/path/to/reference.fna",
        "-t", "4",
    ],
    num_containers=1,
    cpus=4, memory="8GB", runtime="PT30M",
)
```

### `triangle` - all-vs-all ANI across a folder of genomes (MAG dereplication, clustering)

```python
args=[
    "triangle",
    "-o", "/out/ani_matrix.tsv",
    "-E",                              # edge-list output (otherwise: similarity matrix)
    "-t", "4",
    tscli.insert_files(),              # all user genomes via placeholder
]
```

### `search` - query genomes against a user-supplied pre-sketched database

For querying against the GTDB R232 reference set, use `cdm_skani_gtdb` instead - it has the refdata bundled at registration time.

```python
args=[
    "search",
    "-d", "/path/to/sketch_db/",       # built earlier with `skani sketch`
    "-o", "/out/hits.tsv",
    "-t", "4",
    tscli.insert_files(),              # query genomes
]
```

### `sketch` - build a reusable sketch database from a set of reference genomes

```python
args=[
    "sketch",
    "-o", "/out/sketch_db",
    "-t", "4",
    tscli.insert_files(),              # reference genomes to sketch
]
```

## Output

skani writes a TSV with the following columns (per `skani dist`, `triangle -E`, and `search`):
`Ref_file`, `Query_file`, `ANI`, `Align_fraction_ref`, `Align_fraction_query`, `Ref_name`, `Query_name`.

For `triangle` without `-E`, output is a phylip-format similarity matrix instead.

## Reference

Shaw & Yu, *Nature Methods* (2023), DOI 10.1038/s41592-023-02018-3.
