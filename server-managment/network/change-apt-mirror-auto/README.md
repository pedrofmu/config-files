# Automatically configure mirror if the prefered mirror is not accesible

## How to set up 

1. Change PREFERRED_MIRROR to your preferred mirror
2. Be sure that you have netselect-apt installed on your system
3. Run the script autautomatically, for example using a crontab:
```bash
crontab -e
```
    Add the following line: "@reboot /usr/local/bin/cambiar_mirror.sh"
