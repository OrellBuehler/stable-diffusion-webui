FROM debian:buster-slim

# Install dependencies
RUN apt update
RUN apt install wget git python3 python3-venv libgl1 libglib2.0-0 -y

RUN useradd -ms /bin/bash defaultuser

USER defaultuser
WORKDIR /home/defaultuser/stable-diffusion-webui

COPY . .

CMD [ "webui.sh" ]

