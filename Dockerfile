FROM amazonlinux:2@sha256:0cdc09882f5bc2fe506a6f5ba84ab01b50787c12bcea6a1e4762ab6174450a37

# Software versions
ARG NODEJS_VERSION=12.18.4
ARG RUBY_VERSION=2.6.4
ARG USER=ruby

RUN amazon-linux-extras enable postgresql10 && \
  yum install -y \
  awscli \
  bzip2 \
  gcc \
  git \
  make \
  openssl-devel \
  postgresql-devel \
  postgresql10 \
  readline-devel \
  shadow-utils \
  sudo \
  tar \
  unzip \
  util-linux \
  which \
  zlib-devel

RUN adduser ${USER}

USER ${USER}

ENV PATH="/home/${USER}/.rbenv/bin:${PATH}"
ENV PATH="/home/${USER}/.rbenv/versions/${RUBY_VERSION}/bin/:${PATH}"
ENV PATH="/home/${USER}/.nodenv/bin:${PATH}"
ENV PATH="/home/${USER}/.nodenv/versions/${NODEJS_VERSION}/bin/:${PATH}"

# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    cd ~/.rbenv && src/configure && make -C src && \
    eval "$(rbenv init -)" && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    rbenv install ${RUBY_VERSION} && \
    gem install bundler:2.0.2

# Install nodenv
RUN git clone https://github.com/nodenv/nodenv.git ~/.nodenv && \
    cd ~/.nodenv && src/configure && make -C src && \
    eval "$(nodenv init -)" && \
    git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build && \
    nodenv install ${NODEJS_VERSION} && \
    npm install -g yarn
