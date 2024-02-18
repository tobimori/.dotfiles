# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
# path
export PATH="$PATH:$HOME/.composer/vendor/bin" # composer

# aliases
alias nano="micro"
alias cd="z"

# launch ruby env
eval "$(rbenv init - zsh)"

# launch starship
eval "$(starship init zsh)"

# launch zoxide
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/Users/tobimori/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
