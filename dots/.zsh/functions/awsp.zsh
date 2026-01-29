# AWS Profile Switcher
# Allows persistent AWS profile switching across terminal sessions

# Load default AWS profile if set
if [[ -f "$HOME/.aws/default_profile" ]]; then
    export AWS_PROFILE=$(cat "$HOME/.aws/default_profile")
fi

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
