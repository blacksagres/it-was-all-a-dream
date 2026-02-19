# It was all a dream

Keeps everything I like when setting up a new dev machine.

## Requirements

### Debian/Ubuntu

- Ansible (find the installer for your OS)

### macOS

- [Homebrew](https://brew.sh)
- Ansible via Homebrew:

```bash
brew install ansible
```

## Setting everything up

### Debian/Ubuntu

```bash
# No need for sudo, but you will need to give permission for the script
# based on your user

echo $(whoami) | ansible-playbook setup.yml --ask-become-pass
```

### macOS

```bash
ansible-playbook setup.yml
```

## Fonts

Run the font downloader script to install Nerd Fonts:

```bash
bash font-downloader.sh
```

Works on both Linux (Pop!\_OS/Debian) and macOS.
