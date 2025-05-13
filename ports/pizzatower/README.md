## Pizza Tower -- PortMaster Edition
Pizza Tower is a fast paced 2D platformer, with an emphasis on movement, exploration and score attack. Featuring highly stylized pixel art inspired by the cartoons from the '90s, and a highly energetic soundtrack. This port uses texture externalization and compression to gain performance so even small linux-arm64 SoCs can run it.
It is the culmination of the combined efforts of those listed in the Thanks section below.

<div align="center">
  <table>
    <tr>
      <td align="center">
        <p align="center">Pizza Tower Launch Trailer</p>  
        <a href="https://www.youtube.com/watch?v=Wlq6fFOqI28">
          <img src="https://img.youtube.com/vi/Wlq6fFOqI28/0.jpg" alt="Pizza Tower Launch Trailer" width="300"/>
        </a>
      </td>
      <td align="center">
        <p>&nbsp;</p> <!-- Adjust spaces to match -->
        <img src="https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2231450/ss_3e70c43ffd6f492f6e4dce7965499d41fad47052.1920x1080.jpg" alt="Pizza Tower Screenshot" width="300"/>
      </td>
    </tr>
  </table>
</div>

## Installation
- Purchase the game on Steam.
- Copy all the game data to `pizzatower/assets`.
- Have fun.

## Notes
- Peppino is yellow due to the texture hacks that make this port possible. It may be fixed in the future.
- This port uses a file `swapabxy.txt` to align device buttons with glyph prompts. If they are incorrect for you, delete `pizzatower/swapabxy.txt` and restart the game.
- This port does not run well on low power devices like the RK3326. If you attempt to do so, try lowering the ingame options.

## Thanks
Tour De Pizza -- The amazing game.  
JohnnyOnFlame -- GMLoader-Next, FMOD compatibility, Game Port and [UTMT-CLI fork](https://github.com/JohnnyonFlame/UTMT-PortMaster).  
Regular Character -- Initial FMOD Research and Game Port.  
Cyril "kotzebuedog" Deletre -- Port engineering assistance (FMOD Research).  
Jeod -- GMLoader-Next improvements and Game Port.  
UnderminersTeam -- For the original [UTMT-CLI utility](https://github.com/UnderminersTeam/UndertaleModTool).  