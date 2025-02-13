## Unofficial Dockerfile for 3D Gaussian Splatting for Real-Time Radiance Field Rendering
## Bernhard Kerbl, Georgios Kopanas, Thomas Leimkühler, George Drettakis
## https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/

# Use the base image with PyTorch and CUDA support
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 AS dev-base


# NOTE:
# Building the libraries for this repository requires cuda *DURING BUILD PHASE*, therefore:
# - The default-runtime for container should be set to "nvidia" in the deamon.json file. See this: https://github.com/NVIDIA/nvidia-docker/issues/1033
# - For the above to work, the nvidia-container-runtime should be installed in your host. Tested with version 1.14.0-rc.2
# - Make sure NVIDIA's drivers are updated in the host machine. Tested with 525.125.06

ENV DEBIAN_FRONTEND=noninteractive

# Update and install tzdata separately
RUN apt-get update && apt-get install -y tzdata wget git
RUN apt-get update && apt-get install -y libgl1-mesa-dev libglib2.0-0

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm -r Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/opt/miniconda3/bin:$PATH

RUN conda init && \
    conda update conda -y && \
    conda install -n base conda-libmamba-solver -y && \
    conda config --set solver libmamba && \
    exec bash

RUN pip install --upgrade setuptools wheel

WORKDIR /workspace

# Create a Conda environment and activate it
RUN conda create -n cf3dgs python=3.10
ENV CONDA_DEFAULT_ENV=cf3dgs

RUN conda install -y conda-forge::cudatoolkit-dev=11.7.0 pytorch==2.0.0 torchvision==0.15.0 pytorch-cuda=11.7 -c pytorch -c nvidia

RUN git clone https://github.com/NVlabs/CF-3DGS --recursive
RUN pip install -r requirements.txt

