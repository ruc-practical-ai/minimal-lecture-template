# export DEBIAN_FRONTEND=noninteractive

# ==========================
# Basic package installation
# ==========================

echo "Installing basic packages..."

apk update \
    && apk add --no-cache curl vim build-base gcc linux-headers musl-dev git python3 python3-dev py3-pip \
    && rm -rf /var/cache/apk/*

if [ $? -eq 0 ]; then
    echo "Basic packages installed!"
else
    echo "Failed to install basic packages."
    exit 1
fi

echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

if grep -q "^root ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "Enabled sudo for root!"
else
    echo "Failed to enable sudo for root."
    exit 1
fi

echo "Changing ownership of all files in workspace to user group..."

sudo chown -R developer:developer .

if [ $? -eq 0 ]; then
    echo "Success!"
else
    echo "Failed to change ownership."
    exit 1
fi

echo "Linking Python to Python3..."

ln -sf /usr/bin/python3 /usr/bin/python

# =====================
# Account configuration
# =====================

user_name="developer"
group_name="developer"
command_line_aliases_file="https://raw.githubusercontent.com/mauro-j-sanchirico/personal-scripts/refs/heads/main/bash_aliases/command_line.bash_aliases"
git_aliases_file="https://raw.githubusercontent.com/mauro-j-sanchirico/personal-scripts/refs/heads/main/bash_aliases/git.bash_aliases"
poetry_aliases_file="https://raw.githubusercontent.com/mauro-j-sanchirico/personal-scripts/refs/heads/main/bash_aliases/poetry.bash_aliases"

echo "Getting convenient bash shortcuts..."

developer_home="/home/$user_name"

add_aliases() {
    touch $developer_home/.bashrc
    file_name=$(basename "$1")
    curl -o "$developer_home/$file_name" $1
    echo "source $developer_home/$file_name" >> "$developer_home/.bashrc"
}

add_aliases $command_line_aliases_file
add_aliases $git_aliases_file
add_aliases $poetry_aliases_file

echo "source $developer_home/.bashrc" >> "$developer_home/.bash_profile"
echo "source $developer_home/.bashrc" >> "$developer_home/.profile"

# ===================
# Poetry installation
# ===================

poetry_dir=".local/bin"
poetry_command="$developer_home/$poetry_dir/poetry"
install_command="curl -sSL https://install.python-poetry.org | python3 -"

echo "Installing Poetry..."

sudo -u "$user_name" bash -c "$install_command"

if "$poetry_command" --version &>/dev/null; then
    echo "Poetry installed!"
else
    echo "Failed to install Poetry."
fi

echo "Adding Poetry to path..."

echo "export PATH=\"$developer_home/$poetry_dir:\$PATH\"" >> $developer_home/.bashrc

echo "Configuring Poetry virtual environments..."

"$poetry_command" config virtualenvs.in-project true

echo "Installing repository..."

"$poetry_command" install --with dev --no-root

if [ $? -eq 0 ]; then
    echo "Repository dependencies installed!"
else
    echo "Failed to install repository dependencies."
    exit 1
fi

echo "Success!"

exit 0