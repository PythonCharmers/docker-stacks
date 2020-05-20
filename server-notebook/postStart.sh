# Check if symlinks exist, if not, make them
# Avoids errors for each restart of server with persistent volume as home
# NOTE postStart hook runs in mounted/persistent home directory
## >> Data
if [ ! -L ./Data ]; then
        ln -s /home/data/Data ./Data
fi

## >> Materials
if [ ! -L ./Materials ]; then
        ln -s /home/data/Materials ./Materials
fi

## >> Trainer
if [ ! -L ./Trainer ]; then
        ln -s /home/shared/trainer ./Trainer
fi

# > make the location for keyringrc.cfg
mkdir -p ~/.local/share/python_keyring/
cp -f /tmp/keyringrc.cfg .local/share/python_keyring/keyringrc.cfg

# > copy over simple bashrc file for terminal usage
cp -f /tmp/.bashrc ./.profile

# > watchdog

cp /tmp/.watchdog_tricks.yml ./   # everyone to run their own conversions

# > extras from /home/shared/postStart.sh
if [ -f /home/shared/postStart.sh ]; then
    {
        exec /home/shared/postStart.sh
        echo "$(date) - ran shared poststart from ${JUPYTERHUB_USER}" >> /home/shared/start_logs.log
    } || {
        echo "$(date) - ERROR failed to run shared poststart from ${JUPYTERHUB_USER}" >> /home/shared/start_logs.log
    }
fi

# Make Data and Materials read-only for users
chmod -f a-w /home/data/Data /home/data/Materials /home/data/materials.pdf

# Make Trainer folder read-only for users
chmod -f a-w /home/shared/trainer
