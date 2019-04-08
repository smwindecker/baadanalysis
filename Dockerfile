FROM rocker/verse:3.5.1
LABEL maintainer="Saras Windecker"
LABEL email="saras.windecker@gmail.com"

## Update and install extra packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tcl8.6-dev tk8.6-dev \ 
    clang \
    mesa-common-dev\
    libglu1-mesa-dev \
    libgsl0-dev \
    libomp-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

## Add in opts
# Global site-wide config for clang
RUN mkdir -p $HOME/.R/ \
    && echo "\nCXX=clang++ -ftemplate-depth-256\n" >> $HOME/.R/Makevars \
    && echo "CC=clang\n" >> $HOME/.R/Makevars

## Add in required R packages
RUN . /etc/environment \
  && install2.r --error \
  devtools downloader stringr multcomp doBy mgcv lmerTest car MuMIn hier.part gtools RColorBrewer hexbin magicaxis

## Add in required R packages (without suggestions)
RUN . /etc/environment \
  && install2.r --error --deps FALSE \
  xtable knitr png gridBase gridExtra tinytex

# Install github packages
RUN installGithub.r \
    --deps "TRUE" \
    richfitz/datastorr \
    traitecoevo/baad.data \
    richfitz/remake

# Remove unnecessary tmp files
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# R user
ENV USER rstudio

# Copy files
COPY . /home/$USER
RUN chmod u+rw /home/$USER/ms/manuscript.tex

# Set working directory
WORKDIR /home/$USER