# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Custom aliases
alias cat="bat"
alias l="lsd -la --group-directories-first"
alias k="kubecolor"

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

# Custom exports
export PATH=$HOME/.istioctl/bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enable bash completions
autoload -U +X bashcompinit && bashcompinit

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
