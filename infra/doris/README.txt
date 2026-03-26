Apache Doris 本地快速部署（开发/演示）

【当前环境说明】
- Windows 上请先安装 Docker Desktop，并启用 WSL2 后端。
- 官方脚本 start-doris.sh 仅支持在 Linux / macOS 上执行。
- 若 WSL 里只有「docker-desktop」而没有 Ubuntu，无法用 bash 跑 start-doris.sh，请用下方「方式一（Windows）」。

【方式一（Windows）：Docker Desktop 直接启动（无需 Ubuntu WSL）】
1. 确保 Docker Desktop 已运行，PowerShell 中可执行：docker version
2. 在本目录执行（默认版本 4.0.4，可改）：
   powershell -ExecutionPolicy Bypass -File .\start-doris-windows.ps1
   或指定版本：.\start-doris-windows.ps1 -Version 4.0.4
3. 连接 FE（MySQL 协议，默认无密码）：
   mysql -uroot -P9030 -h127.0.0.1
4. 停止：docker compose -f docker-compose-doris.yaml down
5. 说明：脚本会生成本目录下的 docker-compose-doris.yaml（与 macOS 分支相同的桥接网络布局）。

【方式二：WSL2 Ubuntu + start-doris.sh】
1. 安装 Docker Desktop：https://www.docker.com/products/docker-desktop/
2. 打开 Ubuntu（WSL），确保 docker 可用：docker version
3. 进入本目录（按你的盘符修改路径）：
   cd /mnt/d/code/UI-Test/infra/doris
4. 赋予执行权限并启动（版本需与镜像一致，例如 4.0.4）：
   chmod +x start-doris.sh
   bash start-doris.sh -v 4.0.4
5. 使用 MySQL 客户端连接 FE（默认无密码）：
   mysql -uroot -P9030 -h127.0.0.1
6. 停止集群（在同目录）：
   docker compose -f docker-compose-doris.yaml down
   或：docker-compose -f docker-compose-doris.yaml down

【方式三：纯 Linux 服务器】
- 参考官方文档二进制安装：https://doris.apache.org/docs/gettingStarted/quick-start/

【说明】
- Docker 部署仅用于开发测试，勿用于生产。
- 脚本会生成 docker-compose-doris.yaml 并拉取 apache/doris:fe-* / be-* 镜像。

【镜像拉取失败时】
- 检查网络/VPN/公司代理；Docker Desktop → Settings → Resources / Docker Engine 可配置 registry 镜像或 HTTP(S) proxy。
- 拉取中断时可重复执行 start-doris-windows.ps1 或 docker compose -f docker-compose-doris.yaml up -d。
