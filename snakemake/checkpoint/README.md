# Checkpoint for files checking

Tutorial on how to use checkpoint in snakemake.

## Aim
Checkpoint to process unknown number of files in a directory.

## Codes

### Create flag file

###Hidden this code as extra
Flag file can be used as follow:

* Enforce rule execution without input file.
* Used to create file after command is completed 

Here we will create a file without any input file.

```
rule all:
    input:
        "text.txt"

rule first:
    output:
        touch("text.txt")
```

Copy and paste the code above into a file called Snakefile.
Start the pipeline by typing the following command.  

`snakemake --cores 1`

An empty file called text.txt file is created. We will use this file to start the whole pipeline.

### Checkpoint

Generate random files inside a directory.
Paste the code below after the rule first.
This code is used to create a random number of text files inside the directory called `newContent` 

```
rule randomFiles:
    input:
        "text.txt"
        # Possible to call as follow
        # rules.first.output[0]
    output:
        newDir=directory("newContent")
    shell:
        """
        mkdir {output}
        # Pick a random number between 1 and 15
        randomNumbers=$(seq 1 15 | shuf -n 1)
        # Generate multiple new files
        for i in $(seq 1 $randomNumbers)
        do
            echo $i > {output}/$RANDOM.txt
        done
        """
```

To rerun:

`snakemake --cores 1`


<details><summary>Code for Snakefile</summary>
<p>

```
rule all:
    input:
        "newContent"

rule first:
    output:
        touch("text.txt")

rule randomFiles:
    input:
        "text.txt"
    output:
        newDir=directory("newContent")
    shell:
        """
        mkdir {output}
        randomNumbers=$(seq 1 15 | shuf -n 1)
        for i in $(seq 1 $randomNumbers)
        do
            echo $i > {output}/$RANDOM.txt
        done
        """
```

We are telling `snakemake` the final output is a directory called `newContent`.
Snakemake looks at the final file and works backward to identify required files for input and output.
This is why even on the fresh run the `text.txt` file is also created as it is the input for the fule *randomFiles*.

</p>
</details>
 
#### Convert to check point

Now we want to re-evaluate the number of files in the `newContent` folder and use that as input for the next step.
This is done by changing `rule` to `checkpoint` as below.

```
checkpoint randomFiles:
    input:
        "text.txt" 
    output:
        newDir=directory("newContent")
    shell:
        """
        mkdir {output}
        randomNumbers=$(seq 1 15 | shuf -n 1)
        for i in $(seq 1 $randomNumbers)
        do
            echo $i > {output}/$RANDOM.txt
        done
        """
```

Similar to previous script, the pipeline still generate the *newContent* directory along with the random files.

### Process unknown files

We use python function to first force python to check the directory *newContent* before processing further.
This can be called as `checkpoints.<checkpoint_name>.get(**wildcards).output[0]`.
The first output is used in this case.

To extract the new wildcards, we can use `glob_wildcards` from snakemake.   

`glob_wildcards(os.path.join(tmpdir, '{i}.txt')).i`  

We specify the location and the file extension.
In this case, the random number before `.txt` in the `newContent` directory are extracted and returned as a list.

Since we do not know the names of the random files we can combine them together to produce `final.txt`

To do this the code is wrapped under expand, with the wildcards specified.

```
def process_random_files(wildcards):
    tmpdir = checkpoints.randomFiles.get(**wildcards).output[0]
    return expand("newContent/{i}.txt",
           i = glob_wildcards(os.path.join(tmpdir, '{i}.txt')).i)
```

The python function is used as the input for rule *proccessing*.

```
rule processing:
    input:
        get_random_files
    output:
        "final.txt"
    shell:
        """
        echo {input} > {output}
        """

```

Update the rule all.

```
rule all:
    input:
        "final.txt"
```

<details><summary>Code for Snakefile</summary>
<p>

import os
import glob

def process_random_files(wildcards):
    # Force snakemake to check on tent of the checkpoint folder
    tmpdir = checkpoints.randomFiles.get(**wildcards).output[0]
    # Extract the text files in the directory
    val = glob_wildcards(os.path.join(tmpdir, '{i}.txt')).i
    return expand("newContent/{i}.txt", i=val)


rule all:
    input:
        "final.txt"

rule first:
    output:
        touch("text.txt")

checkpoint randomFiles:
    input:
        rules.first.output[0]
    output:
        newDir=directory("newContent")
    shell:
        """
        mkdir {output}
        randomNumbers=$(seq 1 15 | shuf -n 1)
        for i in $(seq 1 $randomNumbers)
        do
            echo $i > {output}/$RANDOM.txt
        done
        """

rule process:
    input:
        process_random_files
    output:
        "final.txt"
    shell:
        """
        echo {input} > {output}
        """


</p>
</details>


### Combine unknown files 

Following rule dictates how the newly generated files should be processed.

```
rule intermediate:
    input:
        "newContent/{i}.txt"
    output:
        "process/{i}.txt"
    shell:
        "cp {input} {output}"
```

The rule copys the random files from `newContent` directory to `process` directory.
We create a python function to identify the random files.

```
def aggregate_input(wildcards):
    # Gets content of the checkpoint
    checkpoint_output = checkpoints.randomFiles.get(**wildcards).output[0]
    # Use glob_wildcards to identify the wildcard
    return expand("process/{i}.txt",
           i=glob_wildcards(os.path.join(checkpoint_output, "{i}.txt")).i)

```

```
rule aggregate:
    input:
        # Input python function here
        aggregate_input
    output:
        "final.txt"
    shell:
        "cat {input} > {output}"
```

Here is the final script:

```
rule all:
    input:
        "final.txt"

rule first:
    output:
        touch("text.txt")

checkpoint randomFiles:
    input:
        "text.txt"
        # Possible to call as follow
        # rules.first.output[0]
    output:
        newDir=directory("newContent")
    shell:
        """
        mkdir {output}
        # Pick a random number between 1 and 15
        randomNumbers=$(seq 1 15 | shuf -n 1)
        # Generate multiple new files
        for i in $(seq 1 $randomNumbers)
        do
            echo $i > {output}/$RANDOM.txt
        done
        """

rule intermediate:
    input:
        "newContent/{i}.txt"
    output:
        "process/{i}.txt"
    shell:
        "cp {input} {output}"

def aggregate_input(wildcards):
    # Gets content of the checkpoint
    checkpoint_output = checkpoints.randomFiles.get(**wildcards).output[0]
    # Use glob_wildcards to identify the wildcard
    return expand("process/{i}.txt",
           i=glob_wildcards(os.path.join(checkpoint_output, "{i}.txt")).i)

rule aggregate:
    input:
        # Input python function here
        aggregate_input
    output:
        "final.txt"
    shell:
        "cat {input} > {output}"

```





