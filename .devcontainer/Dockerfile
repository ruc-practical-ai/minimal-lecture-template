FROM alpine:latest

ARG USERNAME=developer
ARG GROUPNAME=$USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user; adapted from:
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
# and converted to work with alpine
RUN apk update && apk add sudo bash
RUN addgroup -g 1000 $GROUPNAME
RUN adduser -h /home/$USERNAME -G $GROUPNAME -s /bin/bash -D $USERNAME
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
