# vscode-sysroot

允许 VS Code 1.99+ 在旧版 Linux 系统上运行的多平台 sysroot 构建工具。

使用 `crosstool-ng` 在 Docker 中构建 glibc 2.28 和 kernel 3.10 的 sysroot，遵循 [VS Code 官方文档](https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions) 的说明。同时将 [patchelf](https://github.com/NixOS/patchelf) 安装到 sysroot 中。一旦复制到远程系统并设置好环境变量，服务器将在启动时自动修补自身。

已确认在 CentOS 7.9 / RHEL 7.9 / Oracle Linux 7.9 上工作。
可能也适用于 Ubuntu 18.04，但请参见下面的说明。

## 支持的架构

- **x86_64** - 64位 x86 架构（默认）
- **aarch64** - 64位 ARM 架构
- **armhf** - ARM 硬浮点架构

## 快速开始

### 构建单个架构

```bash
# 构建 x86_64 sysroot（默认）
make

# 构建特定架构
make sysroot-aarch64
make sysroot-armhf
```

### 构建所有架构

```bash
# 构建所有支持的架构
make all-archs
```

### 安装和使用

1. 确保已安装 Docker
2. 使用 `make` 构建 sysroot 压缩包到 `toolchain/` 目录
3. 将对应的 sysroot 压缩包复制到远程旧版服务器：
   ```bash
   # 对于 x86_64
   scp toolchain/vscode-sysroot-x86_64-linux-gnu.tgz user@remote-server:~/
   
   # 对于 aarch64
   scp toolchain/vscode-sysroot-aarch64-linux-gnu.tgz user@remote-server:~/
   
   # 对于 armhf
   scp toolchain/vscode-sysroot-armhf-linux-gnu.tgz user@remote-server:~/
   ```
4. 在远程服务器上解压 sysroot：
   ```bash
   tar zxf vscode-sysroot-<arch>-linux-gnu.tgz -C ~/.vscode-server
   ```
5. 复制 `sysroot.sh` 到远程服务器：
   ```bash
   scp sysroot.sh user@remote-server:~/.vscode-server/sysroot.sh
   ```
6. 在远程服务器的 `.bashrc` 或其他登录脚本中添加：
   ```bash
   source ~/.vscode-server/sysroot.sh
   ```

现在连接到远程服务器，在 VS Code 的 `Output > Remote - SSH` 标签页中，您将在 `Starting server...` 后看到 `Patching glibc` 和 `Patching linker`。任何错误输出也会在此标签页中显示。

## 高级用法

### 更新 vscode-linux-build-agent 子树

```bash
./update-vendor.sh
```

### 清理构建产物

```bash
# 清理构建产物
make clean

# 清理所有 Docker 镜像
make clean-all
```

### 查看帮助

```bash
make help
```

## CI/CD 支持

项目包含 GitHub Actions 工作流，支持：

- 多平台自动构建
- Docker 镜像发布到 GitHub Container Registry
- 自动发布到 GitHub Releases

### 手动触发构建

在 GitHub 仓库页面，转到 Actions 标签，选择 "Build Multi-Platform Sysroot" 工作流，点击 "Run workflow" 按钮。

## 故障排除

### Ubuntu 18.04

在 Ubuntu 18.04 上（使用 kernel 4.15 或更高版本），此配置未经测试但可能可以直接工作。
但是，您可能需要在配置文件中将以下版本更改为 `"4.15"`（或更高）：

```
CT_LINUX_VERSION="3.10"
CT_GLIBC_MIN_KERNEL="3.10"
```

在 [Microsoft 的示例](https://github.com/microsoft/vscode-linux-build-agent/blob/main/x86_64-gcc-8.5.0-glibc-2.28.config) 中，它们设置为 `4.19.287`。如果您确认这一点，请提交 issue 分享您的发现。

## 项目结构

```
vscode-sysroot/
├── .github/workflows/          # GitHub Actions 工作流
├── vendor/vscode-linux-build-agent/  # Microsoft 官方构建代理（子树）
├── x86_64-gcc-8.5.0-glibc-2.28.config
├── aarch64-gcc-8.5.0-glibc-2.28.config
├── armhf-gcc-8.5.0-glibc-2.28.config
├── Dockerfile                  # 多平台 Docker 构建
├── Makefile                    # 多架构构建脚本
├── sysroot.sh                  # 环境变量设置脚本
└── update-vendor.sh            # 子树更新脚本
```
