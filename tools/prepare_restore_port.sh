
if [ -d "ports/restore.portmaster" ]; then
    ## Fetch the latest version of the Restore PortMaster.sh
    cd "ports/restore.portmaster/restore.portmaster"

    wget "https://github.com/PortsMaster/PortMaster-GUI/releases/latest/download/Install.PortMaster.sh"
    mv "Install.PortMaster.sh" "Install.PortMaster.txt"

    cd ../..
fi
