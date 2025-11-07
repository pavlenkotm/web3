from setuptools import setup, find_packages

setup(
    name="web3-cli",
    version="1.0.0",
    description="Command-line tools for Ethereum blockchain interactions",
    author="Web3 Developer",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "web3>=6.15.0",
        "eth-account>=0.11.0",
        "click>=8.1.7",
        "rich>=13.7.0",
        "python-dotenv>=1.0.0",
    ],
    entry_points={
        "console_scripts": [
            "web3cli=web3cli.cli:cli",
        ],
    },
    python_requires=">=3.9",
)
