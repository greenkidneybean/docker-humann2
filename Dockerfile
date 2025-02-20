# Use the biobakery base image
FROM quay.io/biocontainers/humann2:0.11.2--py27_1

# Install some prerequisites
# Add the bucket command wrapper, used to run code via sciluigi
RUN pip install boto3==1.4.7 awscli==1.11.146 argparse bucket_command_wrapper==0.3.0

# Install the SRA toolkit
RUN cd /usr/local/bin && \
	wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz && \
	gunzip sratoolkit.2.8.2-ubuntu64.tar.gz && \
	tar xvf sratoolkit.2.8.2-ubuntu64.tar && \
	ln -s /usr/local/bin/sratoolkit.2.8.2-ubuntu64/bin/* /usr/local/bin/ && \
	rm sratoolkit.2.8.2-ubuntu64.tar

# Download the utilities
RUN mkdir /usr/local/humann2 && \
	humann2_databases --download utility_mapping full /usr/local/humann2/utils

# Test the installation
RUN humann2_test --run-functional-tests-tools

# Use /share as the working directory
RUN mkdir /share
WORKDIR /share

# Set the default langage to C
ENV LC_ALL C

# Add the run script to the PATH
ADD run.py /usr/local/bin/

# install databases
RUN mkdir /databases
ENV REF_DB /databases
RUN humann2_databases --download chocophlan full $REF_DB
RUN humann2_databases --download uniref uniref90_diamond $REF_DB
