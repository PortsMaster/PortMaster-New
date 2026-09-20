#! /usr/bin/python2.7
from __future__ import print_function

import glob
import os
import os.path
import pkgutil
import shutil
import sys
import tempfile


__all__ = ["version", "bootstrap"]

def _ensurepip_is_disabled_in_debian():
    if True:
        print ('''\
ensurepip is disabled in Debian/Ubuntu for the system python.

Python modules For the system python are usually handled by dpkg and apt-get.

    apt-get install python-<module name>

Install the python-pip package to use pip itself.  Using pip together
with the system python might have unexpected results for any system installed
module, so use it on your own risk, or make sure to only use it in virtual
environments.
''')
        sys.exit(1)

_PROJECTS = [
    ("setuptools"),
    ("pip"),
]


def _run_pip(args, additional_paths=None):
    # Add our bundled software to the sys.path so we can import it
    if additional_paths is not None:
        sys.path = additional_paths + sys.path

    # Install the bundled software
    import pip._internal
    return pip._internal.main(args)


def version():
    """
    Returns a string specifying the bundled version of pip.
    """
    _ensurepip_is_disabled_in_debian()
    whl_name = 'pip'
    wheel_names = glob.glob('/usr/share/python-wheels/%s-*.whl' % whl_name)
    if len(wheel_names) == 1:
        return os.path.basename(wheel_names[0]).split('-')[1]
    raise RuntimeError('missing dependency wheel %s. Installation of the python-%s-whl package is needed to use ensurepip.' % (whl_name, whl_name))


def _disable_pip_configuration_settings():
    # We deliberately ignore all pip environment variables
    # when invoking pip
    # See http://bugs.python.org/issue19734 for details
    keys_to_remove = [k for k in os.environ if k.startswith("PIP_")]
    for k in keys_to_remove:
        del os.environ[k]
    # We also ignore the settings in the default pip configuration file
    # See http://bugs.python.org/issue20053 for details
    os.environ['PIP_CONFIG_FILE'] = os.devnull


def bootstrap(root=None, upgrade=False, user=False,
              altinstall=False, default_pip=True,
              verbosity=0):
    """
    Bootstrap pip into the current Python installation (or the given root
    directory).

    Note that calling this function will alter both sys.path and os.environ.
    """
    # Discard the return value
    _bootstrap(root=root, upgrade=upgrade, user=user,
               altinstall=altinstall, default_pip=default_pip,
               verbosity=verbosity)


def _bootstrap(root=None, upgrade=False, user=False,
               altinstall=False, default_pip=True,
               verbosity=0):
    """
    Bootstrap pip into the current Python installation (or the given root
    directory). Returns pip command status code.

    Note that calling this function will alter both sys.path and os.environ.
    """
    _ensurepip_is_disabled_in_debian()
    if altinstall and default_pip:
        raise ValueError("Cannot use altinstall and default_pip together")

    _disable_pip_configuration_settings()

    # By default, installing pip and setuptools installs all of the
    # following scripts (X.Y == running Python version):
    #
    #   pip, pipX, pipX.Y, easy_install, easy_install-X.Y
    #
    # pip 1.5+ allows ensurepip to request that some of those be left out
    if altinstall:
        # omit pip, pipX and easy_install
        os.environ["ENSUREPIP_OPTIONS"] = "altinstall"
    elif not default_pip:
        # omit pip and easy_install
        os.environ["ENSUREPIP_OPTIONS"] = "install"

    # Debian: The bundled wheels are useless to us because we must use ones
    # crafted from source code in the archive.  As we build the virtual
    # environment, copy the wheels from the system location into the virtual
    # environment, and place those wheels on sys.path.
    def copy_wheels(wheels, destdir, paths):
        for project in wheels:
            wheel_names = glob.glob(
                '/usr/share/python-wheels/{}-*.whl'.format(project))
            if len(wheel_names) == 0:
                raise RuntimeError('missing dependency wheel %s. Installation of the python-%s-whl package is needed to use ensurepip.' % (project, project))
            assert len(wheel_names) == 1, wheel_names
            wheel_name = os.path.basename(wheel_names[0])
            path = os.path.join('/usr/share/python-wheels', wheel_name)
            with open(path, 'rb') as fp:
                whl = fp.read()
            dest = os.path.join(destdir, wheel_name)
            with open(dest, 'wb') as fp:
                fp.write(whl)
            paths.append(dest)

    # check that the python-{pip,setuptools}-whl packages are installed
    missing = []
    for project in reversed(_PROJECTS):
        wheel_names = glob.glob('/usr/share/python-wheels/%s-*.whl' % project)
        if len(wheel_names) != 1:
            missing.append(project)
    if missing:
        raise RuntimeError('missing wheel(s) %s. Installation of the %s package(s) is needed to use ensurepip.' \
                           % (', '.join([missing]),
                              ', '.join(['python-%s-whl' % m for m in missing])) \
                           )

    tmpdir = tempfile.mkdtemp()

    for project in _PROJECTS:
        try:
            with open('/usr/share/python-wheels/%s.dependencies' % project) as fp:
                dependencies = [line[:-1].split()[0] for line in fp.readlines()]
        except IOError:
            dependencies = []
        copy_wheels(dependencies, tmpdir, sys.path)

    try:
        # Put our bundled wheels into a temporary directory and construct the
        # additional paths that need added to sys.path
        additional_paths = []
        copy_wheels(_PROJECTS, tmpdir, additional_paths)

        # Construct the arguments to be passed to the pip command
        args = ["install", "--no-index", "--find-links", tmpdir]
        if root:
            args += ["--root", root]
        if upgrade:
            args += ["--upgrade"]
        if user:
            args += ["--user"]
        if verbosity:
            args += ["-" + "v" * verbosity]

        return _run_pip(args + _PROJECTS, additional_paths)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)

def _uninstall_helper(verbosity=0):
    """Helper to support a clean default uninstall process on Windows

    Note that calling this function may alter os.environ.
    """
    # Nothing to do if pip was never installed, or has been removed
    try:
        import pip
    except ImportError:
        return

    # If the pip version doesn't match the bundled one, leave it alone
    # Disabled for Debian, always using the version from the python3-pip package.
    if False and pip.__version__ != _PIP_VERSION:
        msg = ("ensurepip will only uninstall a matching version "
               "({!r} installed, {!r} bundled)")
        print(msg.format(pip.__version__, _PIP_VERSION), file=sys.stderr)
        return

    _disable_pip_configuration_settings()

    # Construct the arguments to be passed to the pip command
    args = ["uninstall", "-y", "--disable-pip-version-check"]
    if verbosity:
        args += ["-" + "v" * verbosity]

    return _run_pip(args + reversed(_PROJECTS))


def _main(argv=None):
    import argparse
    parser = argparse.ArgumentParser(prog="python -m ensurepip")
    parser.add_argument(
        "--version",
        action="version",
        version="pip {}".format(version()),
        help="Show the version of pip that is bundled with this Python.",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="count",
        default=0,
        dest="verbosity",
        help=("Give more output. Option is additive, and can be used up to 3 "
              "times."),
    )
    parser.add_argument(
        "-U", "--upgrade",
        action="store_true",
        default=False,
        help="Upgrade pip and dependencies, even if already installed.",
    )
    parser.add_argument(
        "--user",
        action="store_true",
        default=False,
        help="Install using the user scheme.",
    )
    parser.add_argument(
        "--root",
        default=None,
        help="Install everything relative to this alternate root directory.",
    )
    parser.add_argument(
        "--altinstall",
        action="store_true",
        default=False,
        help=("Make an alternate install, installing only the X.Y versioned "
              "scripts (Default: pipX, pipX.Y, easy_install-X.Y)."),
    )
    parser.add_argument(
        "--default-pip",
        action="store_true",
        default=True,
        dest="default_pip",
        help=argparse.SUPPRESS,
    )
    parser.add_argument(
        "--no-default-pip",
        action="store_false",
        dest="default_pip",
        help=("Make a non default install, installing only the X and X.Y "
              "versioned scripts."),
    )

    args = parser.parse_args(argv)

    return _bootstrap(
        root=args.root,
        upgrade=args.upgrade,
        user=args.user,
        verbosity=args.verbosity,
        altinstall=args.altinstall,
        default_pip=args.default_pip,
    )
