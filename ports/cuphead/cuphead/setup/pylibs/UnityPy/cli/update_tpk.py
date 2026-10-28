import os

from tpk_ar.utils import download_tpk

RESOURCE_PATH = os.path.join(os.path.dirname(__file__), "..", "resources")


def update_tpk():
    print("Updating TPK file...")
    print("\tDownloading...")
    tpk_data = download_tpk()

    print("\tSaving...")
    with open(os.path.join(RESOURCE_PATH, "lzma.tpk"), "wb") as f:
        f.write(tpk_data)

    print("\tGenerating classes...")
    # import here to avoid loading a potentially broken or missing tpk file

    from UnityPy.tools.TpkClassGenerator import generate_classes

    generate_classes()
    print("\tDone.")


__all__ = ["update_tpk"]

if __name__ == "__main__":
    update_tpk()
