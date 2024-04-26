FROM --platform=$TARGETPLATFORM nvidia/cuda:12.1.1-devel-ubuntu22.04

ARG BRANCH_OR_TAG=master
ARG BUILD_DATE
ARG BUILD_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.version="${BRANCH_OR_TAG}_${BUILD_VERSION}"

RUN apt update && apt install -y --no-install-recommends \
        bash ca-certificates wget git gcc sudo libgl1 libglib2.0-dev python3-dev google-perftools \
        && rm -rf /var/lib/apt/lists/*

RUN echo "LD_PRELOAD=/usr/lib/libtcmalloc.so.4" | tee -a /etc/environment

RUN useradd --home /app -M app -K UID_MIN=10000 -K GID_MIN=10000 -s /bin/bash
RUN mkdir /app
RUN chown app:app -R /app
RUN usermod -aG sudo app
RUN echo 'app ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER app
WORKDIR /app/

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh
RUN bash ./Miniconda3-latest-Linux-$(uname -m).sh -b \
    && rm -rf ./Miniconda3-latest-Linux-$(uname -m).sh

COPY . /app/stable-diffusion-webui

ENV PATH /app/miniconda3/bin/:$PATH

RUN conda install python="3.10" -y

WORKDIR /app/stable-diffusion-webui

RUN touch install.log && \
    timeout 2h bash -c "export TORCH_COMMAND=\"pip install torch==2.1.2 torchvision==0.16.2\" && ./webui.sh --skip-torch-cuda-test --no-download-sd-model 2>&1 | tee install.log &" && \
    sleep 5 && while true; do grep -q "No checkpoints found." install.log && exit 0; grep -q "ERROR" install.log && exit 1; sleep 3; done