---
name: Create a new port
about: Create a new port in PortMaster.
title: 'New Port: '
---

# New Port for { Game Title }

## Game Information
- **Title**: { Game Title }
- **URL**: { Link to project page or source control page }

## Submission Requirements

### CFW Tests
Ensure your game has been tested on all major CFWs:
- [ ] AmberELEC
- [ ] ArkOS
- [ ] JELOS

### Resolution Tests
Test all major resolutions:
- [ ] 480x320
- [ ] 640x480
- [ ] Higher resolutions (e.g., 1280x720)

## File Structure
- Your port should have the following structure:
  - portname/
    - port.json
    - README.md
    - screenshot.jpg
    - cover.jpg
    - Port Name.sh
    - portname/
      - <portfiles here>

## Additional Resources
For an in-depth guide on creating a pull request, refer to: [PortMaster Game Packaging Guide](https://portmaster.games/packaging.html#creating-a-pull-request)