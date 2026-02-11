#!/bin/bash

echo "🔧 Setting up Python and Virtualenv tools..."

# Step 0: Detect OS and Set Package Manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Error: Cannot detect OS. Exiting..."
    exit 1
fi

if [[ "$OS" == "ubuntu" ]]; then
    echo "detected Ubuntu - Using apt..."
    sudo apt update
    sudo apt install -y python3 python3-pip
    VENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
elif [[ "$OS" == "fedora" ]]; then
    echo "detected Fedora - Using dnf..."
    sudo dnf install -y python3 python3-pip
    # Fedora usually puts pip scripts in /usr/bin
    VENVWRAPPER_SCRIPT="/usr/bin/virtualenvwrapper.sh"
else
    echo "❌ Error: This script is only compatible with Ubuntu or Fedora. Detected: $OS"
    exit 1
fi

# Step 1: Install virtualenv and virtualenvwrapper system-wide
# Fedora 43 and modern Ubuntu both require --break-system-packages for global pip installs
sudo pip3 install --break-system-packages virtualenv virtualenvwrapper

# Step 2: Define shell config variables
WORKON_HOME="/opt/virtualenvs"
VENVWRAPPER_PYTHON="/usr/bin/python3"

echo "📁 Creating virtualenvs directory at $WORKON_HOME..."
sudo mkdir -p "$WORKON_HOME"
sudo chmod 777 "$WORKON_HOME"

# Step 3: Validate wrapper script exists before adding to config
if [ ! -f "$VENVWRAPPER_SCRIPT" ]; then
    # Fallback search if standard paths fail
    VENVWRAPPER_SCRIPT=$(which virtualenvwrapper.sh 2>/dev/null)
fi

echo "💾 Updating ~/.zshrc to enable virtualenvwrapper..."

# Step 4: Append configuration to .zshrc if not already present
if ! grep -q "virtualenvwrapper.sh" ~/.zshrc; then
  cat <<EOL >> ~/.zshrc

# ▶ Virtualenvwrapper Setup
export WORKON_HOME=$WORKON_HOME
export VIRTUALENVWRAPPER_PYTHON=$VENVWRAPPER_PYTHON
source $VENVWRAPPER_SCRIPT
export VIRTUAL_ENV_DISABLE_PROMPT=1
EOL
  echo "✅ .zshrc updated!"
else
  echo "⚠️ .zshrc already contains virtualenvwrapper config. Skipping..."
fi

echo "✅ Setup complete! Restart your terminal or run:"
echo "source ~/.zshrc"

echo "🚀 Try it out with: mkvirtualenv testenv && workon testenv"
