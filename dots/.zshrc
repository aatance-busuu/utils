# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(
  git
  kubectl
  helm
  terraform
  aws
  docker
  docker-compose
  z
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# User configuration
export EDITOR='nvim'

# Load aliases
source $HOME/.aliases

# Load custom functions
for func in $HOME/.zsh/functions/*.zsh; do
    [[ -f "$func" ]] && source "$func"
done

# Enable bash completions
autoload -U +X bashcompinit && bashcompinit

# Istio CLI
export PATH=$HOME/.istioctl/bin:$PATH

# CLI Tool Completions
if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C '/opt/homebrew/bin/terraform' terraform
fi
if command -v aws >/dev/null 2>&1; then
  complete -C '/opt/homebrew/bin/aws_completer' aws
  export AWS_PAGER=""
fi
if command -v istioctl >/dev/null 2>&1; then
  source <(istioctl completion zsh)
fi
if command -v argocd >/dev/null 2>&1; then
  source <(argocd completion zsh)
fi
if command -v k9s >/dev/null 2>&1; then
  source <(k9s completion zsh)
fi
export GPG_TTY=$(tty)
