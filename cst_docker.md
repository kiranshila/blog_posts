---
title: CST Studio in Podman (Docker/OCI)
draft: false
date: 2023-09-03
tags:
  - rf
---

I need to interact with a lot of [EDA](https://en.wikipedia.org/wiki/Electronic_design_automation) in my work as an RF engineer.
Unfortunatley, these behemoth pieces of software are always

1. Extremely proprietary
2. Very touchy in how they're installed
3. Horribly vendored

The consequences of these are that they usually are built for Windows, as that OS lends itself to that kind of software.
This is fundamentally at odds with how professionals use the software, though.
For example: the engineer will probably want to use Windows on her machine as that's what's embedded in the corporate realm
for "security" purposes and the Office suite, etc.
But then say you want to simulate parts of a [large radio telescope](https://www.deepsynoptic.org/).
You wouldn't run that simulation on a personal computer, but submit to a cluster.

These clusters do not run Windows.
So, the vendors of these software packages have to somehow patch things up to get them to run in Linux.
Some companies are much better at this than others.

For example, the [Keysight ADS](https://www.keysight.com/us/en/products/software/pathwave-design-software/pathwave-advanced-design-system.html)
software makes a boatload of assumptions about how it's installed that's not even true on RHEL, it's supposedly supported platform. Not only that
but just "installing on RHEL" doesn't work if there are prerequisites, except Keysight puts these installation instructions behind a paywall???

[Microwave Office](https://www.cadence.com/en_US/home/tools/system-analysis/rf-microwave-design/awr-microwave-office.html) simply doesn't support Linux.

[HFSS](https://www.ansys.com/products/electronics/ansys-hfss) does, but has similar stickiness with prerequisites and ANSYS are copyright fiends with zero ethics.

If I was working on a project by myself, I would use open source software (not necessarily free). Then, I could introspect the code and make the proper modification such that it worked properly on my machine.
I would accept the responsibility of not running on a "supported platform".
However, that's not possible really in the current state of EDA software and is doubly impossible when you need to work with other people who will only
use the proprietary stuff.

## CST Studio

As I'm switching away from ANSYS (and I encourage everyone else to do the same, they are really a profoundly shitty company) - the only viable alternative to HFSS is [CST Studio](https://www.3ds.com/products-services/simulia/products/cst-studio-suite/) from Dassault Systèmes. They provide a Linux version, an actually usable student license, and great install documentation.
The docs go far enough to recognize that even though Ubuntu isn't "officially supported", they walk through the steps on how to install it.
If I used Ubuntu, I'd be done.
Unfortunately, I [don't](https://archlinux.org/).
I tried all sorts of tricks to get it to work properly on my machine, but it looks like there is a bunch of RHEL-ness embedded deep in their applications.

## OCI Container

If these companies really wanted to distribute these apps for Linux and not run into these horrid vendoring issues, they should use the likes of flatpack or AppImage.
However, they don't and probably will never.
As I don't want to run these apps in a VM, because many of them use hardware graphics acceleration (and that's a tricky thing to get right with GPU passthrough), "docker" seems like a nice approach.

As the "docker image" concept has been generalized into the [open container initiative](https://opencontainers.org/), and I prefer podman over docker, the rest of these of these instructions will use that. However, the `docker` command should be a drop-in replacement.

It took me days of tinkering, but I finally got CST Studio to run without a hitch (including GPU acceleration with NVIDIA) in an OCI container.

First, you need to download the "golden" zip of CST and place it in some folder next to this Containerfile (Dockerfile):

```dockerfile
# Source NVIDIA so we have CUDA support
FROM nvidia/cuda:12.2.0-runtime-rockylinux8
# Setup timezone info
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Install prereqs
RUN yum update -y && \
    yum install -y --allowerasing \
    alsa-lib bind-utils cups-libs libXScrnSaver libXcomposite libXtst \
    libcurl libgomp libnsl libtiff libtool-ltdl libxkbcommon-x11 libxml2 \
    mesa-libGLU motif net-tools nss pciutils-libs redhat-lsb-core \
    shared-mime-info xcb-util-image xcb-util-keysyms xcb-util-renderutil \
    xcb-util-wm xdg-utils xorg-x11-server-Xvfb glibc-locale-source dbus-x11 \
    libXdamage libglvnd-opengl ncurses && \
    yum -y clean all && \
    rm -rf /var/cache
# Setup locale
RUN localedef --no-archive -i en_US -f UTF-8 en_US.UTF-8 && \
    export LANG=en_US.UTF-8
# Generating a universally unique ID for the Container
RUN  dbus-uuidgen > /etc/machine-id
# Create the user account
RUN useradd -ms /bin/bash cstuser
# Copy installer and extract
COPY CST_S2_2023.CST_S2_2023.SIMULIA_CST_Studio_Suite.Linux64.tar /installer.tar
RUN tar xf /installer.tar --directory /tmp
COPY responses.txt /tmp/responses.txt
RUN cd /tmp && ./SIMULIA_CST_Studio_Suite.Linux64/install.sh --nogui --installerjava --replay responses.txt
RUN rm -rd /tmp/*
USER cstuser
WORKDIR /home/cstuser
CMD /opt/cst/CST_Studio_Suite_2023/cst_design_environment_gui
```

A couple of notes here, I'm using the nvidia base container to get hardware acceleration support to work. If you have a GPU that respects user freedom, you probably don't need this and can just install MESA normally. However, as far as I can tell, CST doesn't have a software fallback, so this is required for NVIDIA cards.

Next you have to create the installer `responses.txt` file.
These responses will differ depending on your licensing setup.

The way to create it is to only run the build up to, but not including the `COPY responses.txt` line, just comment the rest out.
Then, you run the installer once and record the responses. To do this, you would edit the `Containerfile` by commenting out that `COPY` line and running

```sh
podman build --tag cst-studio .
```

and then

```sh
podman run -it cst-studio bash
```

Then, once you're in the container, you navigate to the install directory and run the installer with

```sh
./install.sh --record responses.txt --nogui
```

Once the installer is finished, you copy out the responses into the same dir as the `Containerfile` and run the rest of it.
You will need a lot of hard disk space for this (>100GB), just FYI.
