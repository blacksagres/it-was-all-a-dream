# It was all a dream 😴

I used to manually setup my machine.

## Requirements

### Debian/Ubuntu

- Ansible
- Git

### macOS

- Ansible
- Git

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
