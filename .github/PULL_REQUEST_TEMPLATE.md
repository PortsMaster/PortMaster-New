## Game Information
- **New Port for**: { Game Title }
- **URL**: { Link to project page or source control page }

## Authorship & Testing

- [ ] I wrote and understand this script/patch myself, or clearly marked which parts came from an AI assistant and reviewed them
- [ ] I can explain every non-standard line in my launch script

## Submission Requirements

### CFW Tests
Ensure your game has been tested on all major CFWs:
- [ ] ArkOS
- [ ] AmberELEC
- [ ] ROCKNIX
- [ ] muOS
- [ ] Knulli
- [ ] Crossmix (Optional)
- [ ] Other (add here)

### Resolution Tests
Test all major resolutions:
- [ ] 480x320 (Optional)
- [ ] 640x480
- [ ] 720x720 (RGB30) (Optional)
- [ ] Higher resolutions (e.g., 1280x720)

## File Structure
- Your port should have the following structure:
  - portname/
    - port.json
    - README.md
    - screenshot.png
    - cover.png
    - gameinfo.xml
    - Port Name.sh
    - portname/
      - <portfiles here>

## Script Conventions

Before submitting, check your launch script against a few recently merged ports of a similar type. 
If your script is significantly longer that or does over complicate things that don't appear in any merged port, remove that logic unless you can point to a game-specific reason it's needed. 
Reviewers will ask why non-standard logic is there.

## Additional Resources
For an in-depth guide on creating a pull request, refer to: [PortMaster Game Packaging Guide](https://portmaster.games/packaging.html#creating-a-pull-request)
