# 使用适合 arm64 架构的基础镜像
FROM arm64v8/ubuntu:latest

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

# 将构建好的 msd_lite 二进制文件复制到镜像中
COPY --from=build /msd_lite/build/msd_lite /usr/local/bin/msd_lite

# 确保 msd_lite 二进制文件具有执行权限
RUN chmod +x /usr/local/bin/msd_lite

# 从项目的conf目录复制默认配置文件到镜像的/etc目录下
COPY conf/msd_lite.conf /etc/msd_lite.conf

# 暴露 msd_lite 使用的端口
EXPOSE 7022

# 设置容器启动时执行的命令
ENTRYPOINT ["/usr/local/bin/msd_lite"]
CMD ["-v", "-c", "/etc/msd_lite.conf"]
