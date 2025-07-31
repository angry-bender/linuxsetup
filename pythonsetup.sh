#!/bin/bash

echo "🔧 Setting up Python and Virtualenv tools..."

# Step 1: Ensure Python and pip are installed
sudo apt update
sudo apt install -y python3 python3-pip

# Step 2: Install virtualenv and virtualenvwrapper system-wide
sudo pip3 install --break-system-packages virtualenv virtualenvwrapper

# Step 3: Define shell config variables
WORKON_HOME="/opt/virtualenvs"
VENVWRAPPER_PYTHON="/usr/bin/python3"
VENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"

echo "📁 Creating virtualenvs directory at $WORKON_HOME..."
sudo mkdir -p "$WORKON_HOME"
sudo chmod 775 "$WORKON_HOME"

echo "💾 Updating ~/.zshrc to enable virtualenvwrapper..."

# Step 4: Append configuration to .zshrc if not already present
if ! grep -q "$VENVWRAPPER_SCRIPT" ~/.zshrc; then
  cat <<EOL >> ~/.zshrc

# ▶ Virtualenvwrapper Setup
export WORKON_HOME=$WORKON_HOME
export VIRTUALENVWRAPPER_PYTHON=$VENVWRAPPER_PYTHON
source $VENVWRAPPER_SCRIPT
EOL
  echo "✅ .zshrc updated!"
else
  echo "⚠️ .zshrc already contains virtualenvwrapper config. Skipping..."
fi

echo "✅ Setup complete! Restart your terminal or run:"
echo "source ~/.zshrc"

echo "🚀 Try it out with: mkvirtualenv testenv && workon testenv"
