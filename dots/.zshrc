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

# Enable bash completions
autoload -U +X bashcompinit && bashcompinit

# Load default AWS profile if set
if [[ -f "$HOME/.aws/default_profile" ]]; then
    export AWS_PROFILE=$(cat "$HOME/.aws/default_profile")
fi

# AWS profile switcher function
awsp() {
    local AWS_PROFILE_FILE="$HOME/.aws/default_profile"
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local NC='\033[0m'
    # Format: profile|account_id
    local PROFILES=(
        "busuu|331868046896"
        "busuu-prod|526745048846"
        "busuu-non-prod|841596778795"
        "busuu-sandbox|543227299426"
        "chegg-aws-busuu-verbling-nonprod|852617132818"
        "verbling|614942315762"
    )

    _awsp_list() {
        local current=""
        [[ -f "$AWS_PROFILE_FILE" ]] && current=$(cat "$AWS_PROFILE_FILE")
        echo "AWS Profiles:\n"
        printf "  %-3s %-35s %s\n" "" "PROFILE" "ACCOUNT_ID"
        printf "  %-3s %-35s %s\n" "" "-------" "----------"
        for entry in "${PROFILES[@]}"; do
            local profile="${entry%%|*}"
            local account_id="${entry##*|}"
            if [[ "$profile" == "$current" ]]; then
                printf "  ${GREEN}*${NC} ${YELLOW}%-35s${NC} %s\n" "$profile" "$account_id"
            else
                printf "    %-35s %s\n" "$profile" "$account_id"
            fi
        done
    }

    case "$1" in
        -u|--unset)
            [[ -f "$AWS_PROFILE_FILE" ]] && rm "$AWS_PROFILE_FILE"
            unset AWS_PROFILE
            echo "Default profile unset"
            ;;
        -h|--help)
            echo "Usage: awsp [PROFILE]"
            echo "\nSet the default AWS profile persistently\n"
            echo "Options:"
            echo "  -u, --unset     Remove default profile"
            echo "  -h, --help      Show this help message"
            echo "\nExamples:"
            echo "  awsp              # List profiles (current marked with *)"
            echo "  awsp busuu-prod   # Switch to busuu-prod"
            ;;
        "")
            _awsp_list
            ;;
        -*)
            echo "Unknown option: $1"
            awsp -h
            ;;
        *)
            local found=false
            for entry in "${PROFILES[@]}"; do
                local profile="${entry%%|*}"
                [[ "$profile" == "$1" ]] && found=true && break
            done
            if [[ "$found" == false ]]; then
                echo "Error: Profile '$1' not found.\n"
                _awsp_list
                return 1
            fi
            echo "$1" > "$AWS_PROFILE_FILE"
            export AWS_PROFILE="$1"
            echo -e "Changed AWS profile to: ${YELLOW}$1${NC}"
            ;;
    esac
}

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
