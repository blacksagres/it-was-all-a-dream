# It was all a dream

Keeps everything I like when setting up a new dev machine.

## Requirements

- Ansible (find the installer for your OS)

## Setting everything up

Run:

```bash

# No need for sudo, but you will need to give permission for the script
# based on your user

echo $(whoami) | ansible-playbook setup.yml --ask-become-pass

```
