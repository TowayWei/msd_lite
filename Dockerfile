# 第一阶段，构建应用程序
FROM arm64v8/ubuntu:latest as msd_lite-builder

# 安装必要的构建工具和依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# 克隆 msd_lite 项目
RUN git clone --recursive https://github.com/TowayWei/msd_lite.git /msd_lite

# 构建 msd_lite
WORKDIR /msd_lite/build
RUN cmake .. && make -j$(nproc)

# 列出build目录的内容以验证msd_lite是否构建成功
RUN ls -la /msd_lite/build

# 第二阶段，创建最终镜像
FROM arm64v8/busybox:stable-musl

# 从构建阶段复制构建产物到最终镜像中
COPY --from=msd_lite-builder /msd_lite/build/src/msd_lite /usr/bin/msd_lite

# 从构建阶段复制配置文件到最终镜像中
COPY --from=msd_lite-builder /msd_lite/conf/msd_lite.conf /etc/msd_lite.conf

# 确保 msd_lite 二进制文件具有执行权限
RUN chmod +x /usr/bin/msd_lite

# 暴露 msd_lite 使用的端口
EXPOSE 7022

# 设置容器启动时执行的命令
CMD ["/usr/bin/msd_lite", "-v", "-c", "/etc/msd_lite.conf"]
