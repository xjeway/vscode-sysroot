# 支持的架构列表
ARCHS := x86_64 aarch64 armhf

# GCC版本选择 (8.5.0 或 10.5.0)
GCC_VERSION ?= 8.5.0

# 默认构建x86_64
all: sysroot-x86_64

# 构建所有架构
all-archs: $(addprefix sysroot-,$(ARCHS))

# 构建所有架构（GCC 10.5.0）
all-archs-gcc10: GCC_VERSION=10.5.0
all-archs-gcc10: $(addprefix sysroot-gcc10-,$(ARCHS))

# 为每个架构构建sysroot
sysroot-%: Dockerfile
	@echo "Building sysroot for architecture: $* with GCC $(GCC_VERSION)"
	@mkdir -p toolchain
	@case $* in \
		x86_64) \
			docker build --build-arg ARCH=x86_64 --build-arg CONFIG_FILE=x86_64-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-$* --target sysroot . ;; \
		aarch64) \
			docker build --build-arg ARCH=aarch64 --build-arg CONFIG_FILE=aarch64-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-$* --target sysroot . ;; \
		armhf) \
			docker build --build-arg ARCH=armhf --build-arg CONFIG_FILE=armhf-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-$* --target sysroot . ;; \
	esac
	@docker run -it --rm -v $$PWD/toolchain:/out vscode-sysroot-$* cp vscode-sysroot-$*-linux-gnu.tgz /out/
	@ls -l toolchain/vscode-sysroot-$*-linux-gnu.tgz

# 明确的目标规则
sysroot-x86_64: Dockerfile
	@$(MAKE) sysroot-x86_64-internal

sysroot-aarch64: Dockerfile
	@$(MAKE) sysroot-aarch64-internal

sysroot-armhf: Dockerfile
	@$(MAKE) sysroot-armhf-internal

# 内部构建规则
sysroot-x86_64-internal:
	@echo "Building sysroot for architecture: x86_64 with GCC $(GCC_VERSION)"
	@mkdir -p toolchain
	@docker build --build-arg ARCH=x86_64 --build-arg CONFIG_FILE=x86_64-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-x86_64 --target sysroot .
	@docker run -i --rm -v $$PWD/toolchain:/out vscode-sysroot-x86_64 cp vscode-sysroot-x86_64-linux-gnu.tgz /out/
	@ls -l toolchain/vscode-sysroot-x86_64-linux-gnu.tgz

sysroot-aarch64-internal:
	@echo "Building sysroot for architecture: aarch64 with GCC $(GCC_VERSION)"
	@mkdir -p toolchain
	@docker build --build-arg ARCH=aarch64 --build-arg CONFIG_FILE=aarch64-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-aarch64 --target sysroot .
	@docker run -i --rm -v $$PWD/toolchain:/out vscode-sysroot-aarch64 cp vscode-sysroot-aarch64-linux-gnu.tgz /out/
	@ls -l toolchain/vscode-sysroot-aarch64-linux-gnu.tgz

sysroot-armhf-internal:
	@echo "Building sysroot for architecture: armhf with GCC $(GCC_VERSION)"
	@mkdir -p toolchain
	@docker build --build-arg ARCH=armhf --build-arg CONFIG_FILE=armhf-gcc-$(GCC_VERSION)-glibc-2.28.config --build-arg PREFIX_DIR=vendor/vscode-linux-build-agent/ -t vscode-sysroot-armhf --target sysroot .
	@docker run -i --rm -v $$PWD/toolchain:/out vscode-sysroot-armhf cp vscode-sysroot-armhf-linux-gnu.tgz /out/
	@ls -l toolchain/vscode-sysroot-armhf-linux-gnu.tgz

# GCC 10.5.0 版本的构建目标
sysroot-gcc10-%:
	@$(MAKE) sysroot-$* GCC_VERSION=10.5.0

# 构建单个架构的sysroot（向后兼容）
sysroot: sysroot-x86_64

# 构建crosstool-ng环境
crosstool:
	docker build --target crosstool -t vscode-sysroot-crosstool .

# 清理构建产物
clean:
	rm -rf toolchain
	docker rmi -f vscode-sysroot-x86_64 vscode-sysroot-aarch64 vscode-sysroot-armhf 2>/dev/null || true

# 清理所有Docker镜像
clean-all: clean
	docker rmi -f vscode-sysroot-crosstool 2>/dev/null || true

# 显示帮助信息
help:
	@echo "Available targets:"
	@echo "  all              - Build x86_64 sysroot with GCC 8.5.0 (default)"
	@echo "  all-archs        - Build all architectures with GCC 8.5.0"
	@echo "  all-archs-gcc10  - Build all architectures with GCC 10.5.0"
	@echo "  sysroot-ARCH     - Build sysroot for specific architecture (GCC 8.5.0)"
	@echo "  sysroot-gcc10-ARCH - Build sysroot for specific architecture (GCC 10.5.0)"
	@echo "  crosstool        - Build crosstool-ng environment only"
	@echo "  clean            - Remove build artifacts"
	@echo "  clean-all        - Remove all build artifacts and Docker images"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Supported architectures: $(ARCHS)"
	@echo "Supported GCC versions: 8.5.0 (default), 10.5.0"
	@echo ""
	@echo "Examples:"
	@echo "  make sysroot-aarch64        # Build aarch64 with GCC 8.5.0"
	@echo "  make sysroot-gcc10-x86_64   # Build x86_64 with GCC 10.5.0"
	@echo "  make all-archs-gcc10        # Build all architectures with GCC 10.5.0"

.PHONY: all all-archs sysroot crosstool clean clean-all help $(addprefix sysroot-,$(ARCHS)) $(addprefix sysroot-,$(ARCHS))-internal
