#!/usr/bin/env bash
set -euo pipefail

MARKER="# >>> eks-labs tool completions >>>"

if ! dpkg -s bash-completion >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends bash-completion
fi

sudo chown -R vscode:vscode /home/vscode/.aws /home/vscode/.kube 2>/dev/null || true

if [ -d "$HOME/.oh-my-zsh" ] && [ -f "$HOME/.zshrc" ]; then
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" \
      || echo "warn: zsh-syntax-highlighting clone failed (non-fatal)"
  fi

  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' "$HOME/.zshrc"
  sed -i 's/^plugins=.*/plugins=(git aws zsh-syntax-highlighting)/' "$HOME/.zshrc"
fi

ME="$(id -un)"
ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "$(getent passwd "$ME" | cut -d: -f7)" != "$ZSH_BIN" ]; then
  sudo chsh -s "$ZSH_BIN" "$ME" || echo "warn: could not set zsh as default shell (non-fatal)"
fi

if [ -f "$HOME/.bashrc" ] && ! grep -qF "$MARKER" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'

# >>> eks-labs tool completions >>>
[ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
if command -v kubectl >/dev/null; then
  source <(kubectl completion bash)
  alias k=kubectl
  complete -o default -F __start_kubectl k
fi
command -v helm >/dev/null && source <(helm completion bash)
command -v aws_completer >/dev/null && complete -C aws_completer aws
command -v terraform >/dev/null && complete -C "$(command -v terraform)" terraform
# <<< eks-labs tool completions <<<
EOF
fi

if [ -f "$HOME/.zshrc" ] && ! grep -qF "$MARKER" "$HOME/.zshrc"; then
  cat >> "$HOME/.zshrc" <<'EOF'

# >>> eks-labs tool completions >>>
autoload -Uz compinit bashcompinit && compinit && bashcompinit
if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
  alias k=kubectl
  compdef k=kubectl
fi
command -v helm >/dev/null && source <(helm completion zsh)
command -v aws_completer >/dev/null && complete -C aws_completer aws
command -v terraform >/dev/null && complete -C "$(command -v terraform)" terraform
# <<< eks-labs tool completions <<<
EOF
fi

terraform version
aws --version
kubectl version --client
helm version
