# VS Code Sysroot for $arch

This package contains the sysroot for $arch architecture to enable VS Code 1.99+ on legacy Linux systems.

## Installation

1. Extract the sysroot:
   ```bash
   tar zxf vscode-sysroot-$arch-linux-gnu.tgz -C ~/.vscode-server
   ```

2. Copy the environment setup script:
   ```bash
   cp sysroot.sh ~/.vscode-server/sysroot.sh
   ```

3. Source the environment in your shell profile:
   ```bash
   echo "source ~/.vscode-server/sysroot.sh" >> ~/.bashrc
   source ~/.bashrc
   ```

4. Connect to your remote server in VS Code

## Architecture: $arch
## Compatible with: CentOS 7.9, RHEL 7.9, Oracle Linux 7.9
## VS Code Version: 1.99+