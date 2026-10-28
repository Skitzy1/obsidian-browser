"""Extract a trusted GStreamer MSI into a local dependency folder without installation.

Requires Windows Python 3.11 (msilib) and a 7z-compatible command. This copies
payload files only; it does not execute MSI actions or alter machine settings.
"""
import argparse
import pathlib
import shutil
import subprocess
import warnings

with warnings.catch_warnings():
    warnings.simplefilter("ignore", DeprecationWarning)
    import msilib


def rows(database, query, fields):
    view = database.OpenView(query)
    view.Execute(None)
    while record := view.Fetch():
        yield tuple(record.GetString(index) for index in range(1, fields + 1))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("msi", type=pathlib.Path)
    parser.add_argument("destination", type=pathlib.Path)
    args = parser.parse_args()
    package = args.msi.resolve(strict=True)
    root = args.destination.resolve()
    raw = package.parent / (package.stem + "-raw")
    subprocess.run(["7z", "x", str(package), "-o" + str(raw), "-y", "-bso0"], check=True)
    database = msilib.OpenDatabase(str(package), msilib.MSIDBOPEN_READONLY)
    directories = {key: (parent, name) for key, parent, name in
                   rows(database, "SELECT Directory, Directory_Parent, DefaultDir FROM Directory", 3)}
    components = dict(rows(database, "SELECT Component, Directory_ FROM Component", 2))

    def directory_path(key, seen=frozenset()):
        if key in seen:
            raise ValueError("Cyclic MSI directory table")
        parent, name = directories[key]
        if not parent:
            return root
        name = name.split(":", 1)[0].split("|")[-1]
        result = (directory_path(parent, seen | {key}) / name).resolve()
        if not result.is_relative_to(root):
            raise ValueError("MSI directory escapes extraction root")
        return result

    count = 0
    for identifier, component, name in rows(database, "SELECT File, Component_, FileName FROM File", 3):
        source = (raw / identifier).resolve(strict=True)
        destination = (directory_path(components[component]) / name.split("|")[-1]).resolve()
        if not source.is_relative_to(raw.resolve()) or not destination.is_relative_to(root):
            raise ValueError("MSI file escapes extraction root")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        count += 1
    print(f"Extracted {count} files to {root}")


if __name__ == "__main__":
    main()
