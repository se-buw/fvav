import subprocess

from setuptools import find_packages, setup

package_name = "motion_safety_verifier"

dafny_export_folder = "motion_safety_verifier_dafny"

# Compile Dafny to Python during colcon build
subprocess.check_call(
    [
        "dafny",
        "build",
        "motion_safety_verifier.dfy",
        "-t",
        "py",
        "-o",
        dafny_export_folder,
    ],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.STDOUT,
)

# Make generated Dafny Python folder importable
open(f"{dafny_export_folder}-py/__init__.py", "a").close()

setup(
    name=package_name,
    version="0.0.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    entry_points={
        "console_scripts": [
            "motion_safety_verifier = motion_safety_verifier.wrapper:main",
        ],
    },
)