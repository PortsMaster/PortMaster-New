## RomM Client
This application interfaces with a RomM server instance and allows you to download and manage roms for your device. It's extremely useful when coupled with tailscale vpn and limited storage space.

## Setup
RomM is short for Rom Manager. This is the client, which connects to a RomM server instance. This app comes with a configuration to connect to the [RomM Demo](https://demo.romm.app/) server which showcases the project with copyright-free roms. In order to use it with your own RomM server, follow the [RomM documentation](https://docs.romm.app/latest/) 
on their website and join the RomM Discord server for help if needed. PortMaster will not assist with setting up or using a RomM server.

Once your server is active, you can modify the `.env` file in the `ports/romm` folder with your new information: your server ip address/hostname and your logon username and password.

```
# Should be formatted as https://<hostname>/ or http://<ip>:<port>/
HOST="https://demo.romm.app"
USERNAME="demo"
PASSWORD="demo"
```

## Useful Links:
[RomM GitHub page](https://github.com/rommapp/romm)
[RomM App GitHub page](https://github.com/rommapp/muos-app)

## Thanks 
[RomM Project Team](https://romm.app/) -- RomM and the client application  
Jeod -- Getting RomM Client to run on emulationstation through PortMaster