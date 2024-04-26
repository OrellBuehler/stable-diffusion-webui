FROM nvidia/cuda:12.4.1-base-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8
WORKDIR /webui
RUN apt-get update &&\
    apt-get install -y \
    wget \
    git \
    python3 \
    python3-pip \
    python-is-python3
RUN python -m pip install --upgrade pip wheel
COPY . /webui

RUN python launch.py --skip-torch-cuda-test --exit
RUN python -m pip install opencv-python-headless

WORKDIR /webui

RUN useradd -ms /bin/bash defaultuser
USER defaultuser

RUN git config --global --add safe.directory /webui

CMD ["python", "launch.py"]

