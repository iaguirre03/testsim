
# place here any commands that need to be run before analysing the samples

 echo 'mkdir -p res/genome'

echo 'wget -O res/genome/ecoli.fast.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz' 


for sampleid in $(ls data/*.fastq.gz | cut -d "_" -f1 | sed 's:data/::' | sort | uniq)
do

echo "Running FastQC..."
echo 'mkdir -p out/fastqc'
echo 'fastqc -o out/fastqc data/${sampleid}_?.fastq.gz'

echo "Running cutadapt..."
echo 'mkdir -p log/cutadapt'
echo 'mkdir -p out/cutadapt'
echo 'cutadapt \
    -m 20 \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o out/cutadapt/${sampleid}_1.trimmed.fastq.gz \
    -p out/cutadapt/${sampleid}_2.trimmed.fastq.gz data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz \
     log/cutadapt/${sampleid}.log'


echo "Running STAR index..."
mkdir -p res/genome/star_index
STAR \
    --runThreadN 8 \
    --runMode genomeGenerate \
    --genomeDir res/genome/star_index/ \
    --genomeFastaFiles res/genome/ecoli.fast \
    --genomeSAindexNbases 9

echo "Running STAR alignment..."
mkdir -p out/star/${sampleid}
STAR \
    --runThreadN 4 \
    --genomeDir res/genome/star_index/ \
    --readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix out/star/${sampleid}/

done
# place here any commands that need to run after analysing the samples

