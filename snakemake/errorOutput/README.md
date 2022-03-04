# How to deal with program error in Snakemake

Trigger condition to avoid pipeline from stopping.  

The bash shell contains `exit 1` status.

Conda shell:

```
program || touch {output}
```

If the program failed with error then trigger condition using `||` for next step. Here create a blank file for output.
