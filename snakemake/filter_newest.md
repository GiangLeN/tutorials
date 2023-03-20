# Filter latest files

This short tutorial is in spired from this [post](https://stackoverflow.com/questions/75782120/filter-files-in-directory-by-filename-pattern-for-a-snakemake-pipeline/75785123#75785123).

Generating files for testing
```
mkdir input
cd input/
touch bar.2021-12-31.json baz.2022-05-15.json foo.2022-01-01.json foo.2023-03-19.json
```

```
.
├── Snakefile
└── input
    ├── bar.2021-12-31.json
    ├── baz.2022-05-15.json
    ├── foo.2022-01-01.json
    └── foo.2023-03-19.json
```

The aim is to create a python dictionary, which contains *ID* : *latest_date*


```
import os
import re

dir_path = "input/"
out_dir = "output/"

(ID, DATE,) = glob_wildcards(dir_path + "{id}.{date}.json")

most_recent_files = {}
for id in set(ID):
  dates, = glob_wildcards(dir_path + id + ".{date}.json")
  maxdate = max(dates)
  most_recent_files[id] = maxdate

def latest_date(id):
    return most_recent_files[id]

rule all:
    input:
        expand(out_dir + "{id}.txt", id = most_recent_files.keys())

rule parse_jsons:
    input:
        lambda wildcards: expand(dir_path + "{id}.{date}.json", id = {wildcards.id}, date = latest_date(wildcards.id))            
    output:
        out_dir + "{id}.txt"
    shell:
        """
        echo {input} > {output}
        """

```

Since the date is already in lexicographical order it is possible to use `max()` as shown above.
Otherwise, use/modify the code below [inspired from this question](https://stackoverflow.com/questions/59612212/find-latest-date-value-in-a-dictionary).

```
from datetime import datetime

maxdate = max((x for x in dates), key=lambda x: datetime.strptime(x, "%Y-%m-%d"))
```
