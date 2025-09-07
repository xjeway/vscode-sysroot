# 支持的架构列表
ARCHS := x86_64 aarch64 armhf

# 默认构建x86_64
all: sysroot-x86_64

# 构建所有架构
all-archs: $(addprefix sysroot-,$(ARCHS))

# 为每个架构构建sysroot
sysroot-%:
	@echo "Building sysroot for architecture: $*"
	@mkdir -p toolchain
	@case $* in \
		x86_64) \
			docker build --build-arg ARCH=x86_64 --build-arg CONFIG_FILE=x86_64-gcc-8.5.0-glibc-2.28.config -t vscode-sysroot-$* --target sysroot . ;; \
		aarch64) \
			docker build --build-arg ARCH=aarch64 --build-arg CONFIG_FILE=aarch64-gcc-8.5.0-glibc-2.28.config -t vscode-sysroot-$* --target sysroot . ;; \
		armhf) \
			docker build --build-arg ARCH=armhf --build-arg CONFIG_FILE=armhf-gcc-8.5.0-glibc-2.28.config -t vscode-sysroot-$* --target sysroot . ;; \
	esac
	@docker run -it --rm -v $$PWD/toolchain:/out vscode-sysroot-$* cp vscode-sysroot-$*-linux-gnu.tgz /out/
	@ls -l toolchain/vscode-sysroot-$*-linux-gnu.tgz

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
	@echo "  all          - Build x86_64 sysroot (default)"
	@echo "  all-archs    - Build all architectures (x86_64, aarch64, armhf)"
	@echo "  sysroot-ARCH - Build sysroot for specific architecture"
	@echo "  crosstool    - Build crosstool-ng environment only"
	@echo "  clean        - Remove build artifacts"
	@echo "  clean-all    - Remove all build artifacts and Docker images"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Supported architectures: $(ARCHS)"

.PHONY: all all-archs sysroot crosstool clean clean-all help $(addprefix sysroot-,$(ARCHS))
