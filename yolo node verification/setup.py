import subprocess
from setuptools import find_packages, setup

dafny_export_folder = "yolo_sign_node_dafny"

# Run dafny build
subprocess.check_call(
    [
        "dafny",
        "build",
        "yolo_sign_node_verification.dfy",
        "-t",
        "py",
        "-o",
        dafny_export_folder,
    ],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.STDOUT,
)

# to make the dafny export directory a python module
open(f"{dafny_export_folder}-py/__init__.py", "a").close()

package_name = 'yolo_sign_node'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='seav',
    maintainer_email='swaraj.sudhakar.sonawane@uni-weimar.de',
    description='TODO: Package description',
    license='TODO: License declaration',
    extras_require={
        'test': [
            'pytest',
        ],
    },
    entry_points={
        'console_scripts': [
		'yolo_node = yolo_sign_node.yolo_node:main',
        ],
    },
)
