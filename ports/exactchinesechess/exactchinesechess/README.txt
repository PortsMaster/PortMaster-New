Runtime files for the Exact Chinese Chess PortMaster package.

Current release binary:

  exactcc.aarch64

The launcher chooses exactcc.${DEVICE_ARCH}. The short name is intentional:
muOS foreground process matching uses a kernel process name with a 15 character
limit, so exactcc.aarch64 fits without truncation.

Do not advertise another architecture in port.json until its matching binary is
included and tested.
