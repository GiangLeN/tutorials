# Rarefraction for metagenome

## Aims

To find the rarefraction curve at different percentage


## Codes

### Sampling raw reads

Combine all raw reads together

`cat *.fastq.gz > total.fastq.gz`

Count the number of raw reads

`zcat total.fastq.gz | echo $((`wc -l`/4))`

Install seqtk tool using conda 

```
# Create environment for seqtk tool
conda create --name seqtk seqtk kraken2
# Activate the env
conda activate seqtk
```

Create loop to split the raw into smaller files 
```
for i in {5..100..10}  # start number, last number and gap value
do
        seqtk sample -s100 total.fastq.gz $i > split_"$i".fq.gz  # -s is the seed. If file is paired then keep the same seed
        kraken2 --db db_dir  --threads 12 --use-names --report-zero-counts --report kr_"$i".report --output kr"$i".output split_"$i".fq.gz

done
```

Clone kraken output manipulator
Note: Might need to edit the script as it is not compatable with python 3.7
Edit the line open("rb") to just ("r")

`git clone https://github.com/npbhavya/Kraken2-output-manipulation.git`

Create environment to run file

`conda create --name rarefraction python numpy pandas r r-vegan r-tidyverse`

Move all report files to a directory

`mv *.report kraken_reports/`

Merge kraken files
`python Kraken2-output-manipulation/kraken-multiple.py -d kraken_reports/ -r F -c 2 -o kraken-report-final`

Convert merged file to csv

`cat kraken-report-final | tr -d "[']" | sed 's/\t/,/g' > kraken_report_all_R.csv`

Draw figure

`Rscript Rarefaction-curves.R`

