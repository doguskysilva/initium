Tudo comeca com o sudo apt update && sudo apt full-upgrade -y

depois vem o que é chamado de essentials sudo apt install -y build-essential git curl wget unzip ca-certificates \
  ripgrep fd-find fontconfig
  

No Ubuntu o binário do fd chama fdfind. O LazyVim espera fd, então:

mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd

Depois a instalacao base: apt install neovim tmux zsh -y


