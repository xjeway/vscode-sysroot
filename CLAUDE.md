# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project builds sysroots for VS Code 1.99+ to run on legacy Linux systems (CentOS/RHEL 7.9, Oracle Linux 7.9) with glibc 2.28 and kernel 3.10. It uses crosstool-ng in Docker to cross-compile a compatible runtime environment and includes patchelf for automatic patching.

## Architecture

### Multi-stage Docker Build
- **crosstool stage**: Sets up crosstool-ng toolchain with all dependencies
- **sysroot stage**: Builds the actual sysroot using parameterized architecture configs and packages it with patchelf

### Cross-compilation Configs
Three architecture configurations:
- `x86_64-gcc-8.5.0-glibc-2.28.config` - Primary target for x86_64
- `aarch64-gcc-8.5.0-glibc-2.28.config` - ARM64 support  
- `armhf-gcc-8.5.0-glibc-2.28.config` - ARM hard-float support

All configs target glibc 2.28 with kernel 3.10 for legacy system compatibility.

### Runtime Environment
`sysroot.sh` sets environment variables for VS Code server patching:
- `VSCODE_SERVER_CUSTOM_GLIBC_LINKER` - Points to sysroot's dynamic linker
- `VSCODE_SERVER_CUSTOM_GLIBC_PATH` - Library search paths in sysroot
- `VSCODE_SERVER_PATCHELF_PATH` - Location of patchelf binary

## Build Commands

### Build sysroot (default x86_64)
```bash
make
```

### Clean build artifacts
```bash
make clean
```

### Manual Docker builds
```bash
# Build just crosstool-ng environment
docker build --target crosstool -t vscode-sysroot-crosstool .

# Build complete sysroot
docker build --target sysroot -t vscode-sysroot .
```

### Architecture-specific builds
Modify `Dockerfile` ARG values:
```dockerfile
ARG ARCH=aarch64  # or armhf
ARG CONFIG_FILE=${ARCH}-gcc-8.5.0-glibc-2.28.config
```

## Development Notes

- Docker is required for builds due to case-sensitivity requirements of kernel sources
- Output tarball is placed in `toolchain/vscode-sysroot-{arch}-linux-gnu.tgz`
- The `.a` static libraries are excluded from final tarball to reduce size
- patchelf 0.18.0 is installed into the sysroot at build time