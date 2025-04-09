#!/usr/bin/env python3

import os
import sys
import re
import webbrowser
import urllib.request

# NOTE: This should be a string, but keeping it as float so version checks from
# older versions of this script continue working (they parse this script).
installer_ver = 22.0307

package_url = "https://distribute.re-volt.io/packs/"
release_url = "https://distribute.re-volt.io/releases/"
packagelist_url = "http://distribute.re-volt.io/packages.txt"
rvgl_version_url = "http://distribute.re-volt.io/releases/rvgl_version.txt"
help_url = "https://re-volt.gitlab.io/rvgl-docs/os-specifics.html#gnulinux"
launcher_url = "https://re-volt.gitlab.io/rvgl-launcher"
installer_url = "https://rvgl.org/downloads/install_rvgl.py"

rvgl_packages = ("rvgl_assets", "rvgl_win32", "rvgl_win64", "rvgl_linux")

releases = [
  {
    "name": "original",
    "packages": ["game_files", "soundtrack", "rvgl_assets", "rvgl_linux", "rvgl_dcpack"],
    "description":
        "    RVGL for GNU/Linux.\n"
        "    Includes original soundtrack."
  },
  {
    "name": "basic",
    "packages": ["game_files", "rvgl_assets", "rvgl_linux", "rvgl_dcpack"],
    "description":
        "    RVGL for GNU/Linux.\n"
        "    Does not include the soundtrack."
  },
  {
    "name": "online",
    "packages": ["game_files", "rvgl_assets", "rvgl_linux", "rvgl_dcpack",
                   "io_tracks", "io_cars", "io_tracks_bonus", "io_cars_bonus",
                   "io_lmstag", "io_loadlevel", "io_music", "io_skins",
                   "io_clockworks", "io_clockworks_modern", "io_soundtrack"],
    "description":
        "    RVGL for GNU/Linux.\n"
        "    Includes community soundtrack and\n"
        "    additional content for playing online."
  },
]

options = {
    "wget": "-q --show-progress"
}


def check_installer_reqs():
    """ Checks for installer pre-requisites """
    if sys.version_info[0] < 3:
        print("Python 3.x is required!")
        return False

    if os.system("wget --help > /dev/null") != 0:
        print("The 'wget' command is missing!")
        return False

    with os.popen("wget --help") as p:
        if "--show-progress" not in p.read():
            options["wget"] = "-q"

    if os.system("unzip -h > /dev/null") != 0:
        print("The 'unzip' command is missing!")
        return False

    return True


""" Convert a version string into a tuple """
def parse_version(version):
    try:
        groups = re.match(r"(\d+)(?:\.(\d+))?(\w+)?(?:-(\d+))?", version).groups("")
        major = parse_int(groups[0])
        minor = parse_int(groups[1])
        revision = parse_int(groups[3])
        return (major, minor, revision)
    except Exception:
        return (0, 0, 0)


""" Convert a string into integer """
def parse_int(value):
    try:
        return int(value)
    except Exception:
        return 0


def get_packages():
    response = urllib.request.urlopen(packagelist_url)
    data = response.read()
    return data.decode('utf-8').split("\n")


def get_version_file(package):
    if package in rvgl_packages:
        return "rvgl_version"
    else:
        return package


def ask_bool(question, default=True):
    """ Asks for user input, ENTER can be used to confirm the
        default option (written in caps) """
    if default is True:
        y, n, ans = "Y", "n", "y"
    else:
        y, n, ans = "y", "N", "n"

    response = input("{} [{}/{}]: ".format(question, y, n))

    if response.lower() == ans or response == "":
        return default
    else:
        return not default


def ask_string(question, default=""):
    """ Asks for user input, ENTER can be used to confirm the
        default option """
    response = input("{} [{}]: ".format(question, default))

    if response == "":
        return default
    else:
        return response


def ask_path(question, default="~/.rvgl"):
    """ Asks for a path and replaces ~ with the user path """
    response = ask_string(question, default)
    return os.path.expanduser(response)


def download(url, filename=None, redl=False):
    """ Downloads a file if it doesn't exist already. The file can be force-
        downloaded by passing redl=True. The output filename can be overriden
        through the filename parameter. """
    if not filename:
        filename = url.split("/")[-1]
    if redl and os.path.isfile(filename):
        os.remove(filename)
    if not os.path.isfile(filename):
        # TODO: Handle spaces in filename and/or url?
        os.system("wget -O {} {} {}".format(filename, options["wget"], url))
    else:
        print("File already exists. ({})".format(filename))

    if os.path.isfile(filename):
        return True
    else:
        print("Could not find {}".format(filename))
        return False


def download_script():
    """ Downloads an updated version of this installer script """
    filename = installer_url.split("/")[-1]
    filename_new = filename + ".new"

    if not download(installer_url, filename=filename_new, redl=True):
        print("Download failed.")
        exit()

    os.replace(filename_new, filename)
    os.chmod(filename, 0o755)


def download_pack(pack, redl=False):
    """ Downloads a pack. redl=True has to be passed for updates """
    print("Downloading {}...".format(pack))
    os.chdir(".packs")
    if not download("{}{}.zip".format(package_url, pack), redl=redl):
        print("Package download failed.")
        exit()

    version = get_version_file(pack)
    if not download("{}{}.txt".format(release_url, version), redl=redl):
        print("Version file download failed.")
        exit()
    os.chdir("..")


def extract_pack(pack):
    """ Extracts a pack from the packs folder """
    if os.path.isfile(".packs/{}.zip".format(pack)):
        print("Extracting {}...".format(pack))
        os.system("unzip -o .packs/{}.zip > /dev/null".format(pack))
        write_version(pack)


def write_version(pack):
    """ Updates the version file for a package """
    version = get_version_file(pack)
    os.system("cp -f .packs/{}.txt .versions".format(version))

    if pack in rvgl_packages:
        os.chdir(".versions")
        os.system("ln -sf {}.txt {}.txt".format(version, pack))
        os.chdir("..")


def get_rvgl_version():
    """ Gets the current version of RVGL """
    try:
        response = urllib.request.urlopen(rvgl_version_url)
        data = response.read()
        return data.decode('utf-8').strip()
    except Exception as e:
        return ""


def get_installer_version():
    """ Gets the current version of the installer """
    try:
        response = urllib.request.urlopen(installer_url)
        data = response.read()
        data = data.decode('utf-8').split("installer_ver = ")[1]
        return data.split("\n")[0].strip().strip('"')
    except Exception as e:
        return ""


def get_dist_version(package):
    """ Gets the pack version from the website """
    try:
        url = "{}{}.txt".format(release_url, package)
        response = urllib.request.urlopen(url)
        data = response.read()
        return data.decode("utf-8").strip()
    except Exception as e:
        return ""


def get_local_version(package):
    """ Gets the pack version from the local .versions folder """
    try:
        fname = ".versions/{}.txt".format(package)
        with open(fname, "r") as f:
            return f.readline().strip()
    except Exception as e:
        return ""


def get_installed_packages(packs_list):
    """ Gets the list of packages currently installed """
    if not os.path.isdir(".versions"):
        return []

    packs = []
    for p in os.listdir(".versions"):
        name, ext = os.path.splitext(p)
        if ext != ".txt":
            continue
        if name in packs_list:
            packs.append(name)

    return sorted(packs)


def check_install_path(path):
    """ Checks if the installation path has all required folders """
    versions_dir = os.path.join(path, ".versions")
    if not os.path.isdir(versions_dir):
        os.makedirs(versions_dir)

    packs_dir = os.path.join(path, ".packs")
    if not os.path.isdir(packs_dir):
        os.makedirs(packs_dir)


def list_packages():
    print("Available packages:")
    packages = get_packages()
    installed_packages = get_installed_packages(packages)
    for pack in packages:
        if pack in installed_packages:
            print(pack, "[installed]")
        else:
            print(pack)


def install():
    """ Installs the complete game """
    if not ask_bool("This will install RVGL. Continue?"):
        exit()

    rvgl_ver = get_rvgl_version()
    if not rvgl_ver:
        print("Could not get RVGL version. Are you online?")
        exit()

    print("")
    print("Current RVGL version: {}\n".format(rvgl_ver))

    install_path = ask_path("Where would you like to install RVGL?")

    if not os.path.isdir(install_path):
        try:
            os.makedirs(install_path)
            print("Created \"{}\"".format(install_path))
        except Exception as e:
            print("Could not create directory:\n    {}".format(e))
            exit()

    print("")
    print("RVGL will be installed to \"{}\".".format(install_path))
    if len(os.listdir(install_path)) > 1:
        print("Warning: Directory is not empty!")
    print("")


    print("Available releases:")
    for i in range(len(releases)):
        print("{:2}. {}".format(i, releases[i]["name"]))
        print("{}".format(releases[i]["description"]))
    print("")

    dl_release = ask_string("Enter your choice.", "2")

    for i in range(len(releases)):
        if dl_release in ("{}".format(i), releases[i]["name"]):
            release = releases[i]
            break
    else:
        print("Invalid release choice.")
        exit()

    print("")

    try:
        os.chdir(install_path)
    except Exception as e:
        print("Cannot change to install directory:\n    {}".format(e))
        exit()

    check_install_path("")

    for pack in release["packages"]:
        download_pack(pack)

    print("")

    print("Extracting packs...")
    for pack in release["packages"]:
        extract_pack(pack)
    print("")

    print("Done.")
    print("")

    print("Starting RVGL setup...")
    os.system("./setup")

    if not ask_bool("Keep installation files?"):
        os.system("rm -r .packs")

    print("")

    if ask_bool(
            "Some libraries need to be installed.\n"
            "Would you like to open the help page?"):
        webbrowser.open(help_url)
    else:
        print("You can view information about required packages here:\n{}".format(help_url))

    print("")
    print("Installation complete.")
    print("To start RVGL, cd to \"{}\" and type ./rvgl or use the desktop launcher.".format(install_path))


def update():
    """ Searches for pack and game updates """
    if not "rvgl" in os.listdir():
        install_path = ask_path("Which installation would you like to update?")
        check_install_path(install_path)
        os.chdir(install_path)
    else:
        print("Using the RVGL installation in the current folder.")
        install_path = "."

    print("")

    packages = get_packages()
    installed_packages = get_installed_packages(packages)

    packlist = installed_packages
    for package in ("rvgl_assets", "rvgl_linux"):
        if package not in installed_packages:
            packlist.append(package)
    packlist.sort()

    updates = []
    for package in packlist:
        if package in rvgl_packages:
            continue
        local_ver = get_local_version(package)
        dist_ver = get_dist_version(package)
        if parse_version(local_ver) < parse_version(dist_ver):
            print("Update available for {}: {}".format(package, dist_ver))
            updates.append(package)
        else:
            print("Package {} is up to date: {}".format(package, local_ver))

    if updates:
        print("")
        print("Updates are available for the following packages:")
        for package in updates:
            print(package)
        print("")

        if ask_bool("Install package updates?"):
            print("")
            for package in updates:
                download_pack(package, redl=True)
                extract_pack(package)
            print("")

    local_ver = get_local_version("rvgl_version")
    dist_ver = get_dist_version("rvgl_version")
    if parse_version(local_ver) < parse_version(dist_ver) or "game_files" in updates:
        print("")
        print("Update available for RVGL: {}".format(dist_ver))
        for package in packlist:
            if package not in rvgl_packages:
                continue
            download_pack(package, redl=True)
            extract_pack(package)
        print("")
    else:
        print("RVGL is up to date: {}\n".format(local_ver))

    print("Updates complete.")


def add():
    """ Adds specified packages to the installation """
    if len(sys.argv) == 2:
        print_usage()
        exit()

    if not "rvgl" in os.listdir():
        install_path = ask_path("Where would you like to install the packages?")
        check_install_path(install_path)
        os.chdir(install_path)
    else:
        print("Using the RVGL installation in the current folder.")
        install_path = "."

    packages = get_packages()
    installed_packages = get_installed_packages(packages)

    packlist = sys.argv[2:]

    for package in ("rvgl_assets", "rvgl_linux"):
        if package in packlist:
            continue
        if package not in installed_packages:
            packlist.append(package)
        elif "game_files" in packlist:
            packlist.append(package)

    for package in sorted(packlist):
        if package in packages:
            download_pack(package)
            extract_pack(package)
        else:
            print("Unknown package: {}".format(package))

    print("")
    print("Done.")


def check():
    """ Check for new version of the installer """
    print("=== RVGL Installer {} ===".format(installer_ver))
    print("Checking for updates...")
    local_ver = str(installer_ver)
    dist_ver = get_installer_version()

    if parse_version(local_ver) < parse_version(dist_ver):
        print("Update available for the installer.")
        print("Current version: {}".format(local_ver))
        print("Available version: {}".format(dist_ver))
        if not ask_bool("Would you like to download it?"):
            print("You must update the launcher to continue.")
            exit()

        download_script()
        return False

    print("")
    print(
        "NOTE: RVGL Installer is deprecated. Consider using RVGL Launcher instead,\n"
        "which is a newer and actively maintained cross-platform replacement.\n"
        "Download: {}\n".format(launcher_url))

    if not ask_bool("Do you still want to continue?", False):
        return False

    print("")
    return True


def print_usage():
    """ Prints the usage message """
    print(
        "Usage:\n"
        "install_rvgl                   Install RVGL or update existing game\n"
        "install_rvgl install           Install RVGL\n"
        "install_rvgl update            Update packages and RVGL\n"
        "install_rvgl add <packages>    Download and install packages\n"
        "install_rvgl list              Display available packages\n"
    )


if not check_installer_reqs():
    exit()

if not check():
    exit()

if len(sys.argv) <= 1:
    if "rvgl" in os.listdir():
        update()
    else:
        install()

elif sys.argv[1] == "install":
    install()

elif sys.argv[1] == "update":
    update()

elif sys.argv[1] == "add":
    add()

elif sys.argv[1] == "list":
    list_packages()

else:
    print_usage()
