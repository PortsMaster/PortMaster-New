## Notes

Thanks to The Diligent Circle for continuing to maintain such a fun game.


## Compile

From the Portmaster Docker image:

Install [gnu gettext](https://www.gnu.org/software/gettext/)
Download the tarball.  Make, make install, ldconfig -v

Next build my fork of starfighter:

```shell
git clone https://github.com/bmdhacks/starfighter

cd starfighter
./autogen.sh
./configure SF_RUN_IN_PLACE=1 --prefix=/root/starfighter_install
make
make install

copy the starfighter_install directory to the ports/starfighter/starfighter in portmaster.

```
