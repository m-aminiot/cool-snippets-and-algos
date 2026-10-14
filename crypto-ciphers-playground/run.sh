#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

# Add new menu labels and their matching main.py choices here.
labels=("ChaCha20" "AGSM")
# main.py currently names the AGSM branch "aegs".
choices=("chacha20" "aegs")

cyan='' blue='' green='' yellow='' red='' dim='' reset=''
if [[ -t 1 && "${TERM:-dumb}" != "dumb" && -z "${NO_COLOR+x}" ]]; then
    cyan=$'\033[1;36m'
    blue=$'\033[1;34m'
    green=$'\033[1;32m'
    yellow=$'\033[1;33m'
    red=$'\033[1;31m'
    dim=$'\033[2m'
    reset=$'\033[0m'
fi

printf '\n%s' "$cyan"
cat <<'BANNER'
      ____ ____  __   ______ _____ ___
     / ___|  _ \ \ \ / /  _ \_   _/ _ \
    | |   | |_) | \ V /| |_) || || | | |
    | |___|  _ <   | | |  __/ | || |_| |
     \____|_| \_\  |_| |_|    |_| \___/

             C O N T R O L   P A N E L
BANNER
printf '%s\n' "$reset"
printf '    %s[ ENCRYPTION TOOLKIT ]  Select. Enter. Encrypt.%s\n' "$dim" "$reset"

while true; do
    printf '\n%s    +------------------------------------------------------+%s\n' "$blue" "$reset"
    printf '    | %-52s |\n' 'ALGORITHMS / Select your cipher'
    printf '%s    +------------------------------------------------------+%s\n' "$blue" "$reset"
    for index in "${!labels[@]}"; do
        printf '    | %s[%s]%s %-48s |\n' "$cyan" "$((index + 1))" "$reset" "${labels[index]}"
    done
    printf '    | %s[%s]%s %-48s |\n' "$dim" "$((${#labels[@]} + 1))" "$reset" 'Exit'
    printf '%s    +------------------------------------------------------+%s\n\n' "$blue" "$reset"

    printf '    %s[?]%s Select an option %s>%s ' "$cyan" "$reset" "$cyan" "$reset"
    if ! read -r selection; then
        printf '\n    %s[ Exit ]%s Goodbye!\n\n' "$dim" "$reset"
        exit 0
    fi

    if [[ "$selection" == "$((${#labels[@]} + 1))" || "$selection" == "exit" ]]; then
        printf '\n    %s[ Exit ]%s Goodbye!\n\n' "$dim" "$reset"
        exit 0
    fi

    selected_index=-1
    for index in "${!labels[@]}"; do
        if [[ "$selection" == "$((index + 1))" ]]; then
            selected_index=$index
            break
        fi
    done

    if (( selected_index < 0 )); then
        printf '\n    %s[!]%s Invalid option. Choose a number from the menu.\n' "$yellow" "$reset"
        continue
    fi

    printf '\n    %s:: %s / MESSAGE INPUT%s\n' "$cyan" "${labels[selected_index]}" "$reset"
    printf '    %sType your message, then press Enter.%s\n' "$dim" "$reset"
    printf '    %s[>]%s Plaintext %s>%s ' "$cyan" "$reset" "$cyan" "$reset"
    if ! IFS= read -r user_plaintext; then
        printf '\n    %s[ Exit ]%s Goodbye!\n\n' "$dim" "$reset"
        exit 0
    fi

    printf '\n    %s[+]%s Running %s...\n' "$green" "$reset" "${labels[selected_index]}"
    printf '    %s--------------------------------------------------------%s\n\n' "$dim" "$reset"
    if ! choice="${choices[selected_index]}" plaintext="$user_plaintext" python3 main.py; then
        printf '\n    %s[!]%s main.py failed. Returning to the menu.\n' "$red" "$reset" >&2
    fi
done
