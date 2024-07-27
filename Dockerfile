# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    zsh \
    xclip \
    evince \
    npm \
    x11-apps \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    g++ \
    pkg-config \
    doxygen

RUN apt-get update && \
    apt-get install -y texlive-latex-base texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra \
    texlive-pictures texlive-science latexmk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pynvim for Python 3
RUN pip3 install pynvim

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Clone Neovim repository and install the latest version
RUN git clone https://github.com/neovim/neovim.git && \
    cd neovim && \
    git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    cd .. && \
    rm -rf neovim

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install vim-plug for Neovim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install texlab
RUN wget https://github.com/latex-lsp/texlab/releases/download/v4.0.0/texlab-x86_64-linux.tar.gz && \
    tar -xzf texlab-x86_64-linux.tar.gz && \
    mv texlab /usr/local/bin/texlab && \
    rm texlab-x86_64-linux.tar.gz

# Create configuration directories
RUN mkdir -p ~/.config/nvim

# Copy your entire nvim configuration folder
COPY nvim/ ~/.config/nvim/

# Install packer.nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

RUN git clone --branch master https://github.com/neoclide/coc.nvim.git \
    ~/.local/share/nvim/site/pack/packer/start/coc.nvim && \
    cd ~/.local/share/nvim/site/pack/packer/start/coc.nvim && \
    npm install && \
    npm run build

# Install nvim-cmp and luasnip
RUN git clone https://github.com/hrsh7th/nvim-cmp.git \
    ~/.local/share/nvim/site/pack/packer/start/nvim-cmp

RUN git clone https://github.com/L3MON4D3/LuaSnip.git \
    ~/.local/share/nvim/site/pack/packer/start/LuaSnip

# Set the shell to zsh
SHELL ["/bin/zsh", "-c"]

