---
id: trimui-emmc-flash
title: "TrimUI Brick eMMC 刷写调查"
category: reference
status: active
tags: [tg5050, emmc, install]
created: "2026-11-21T13:44:52"
updated: "2026-11-21T13:44:52"
---

<!-- compiled_truth -->
NextUI 仓库**不提供官方 eMMC 刷写支持**。设计是 SD 卡启动 + 劫持 stock OS：发行包是 zip 文件树（`makefile:254-257`），没有整盘镜像/bootloader/u-boot。

- SD 卡安装是仓库唯一支持的路径；bootstrap 仅修改内置 eMMC 的 `/usr/trimui/bin/runtrimui.sh`（`skeleton/BOOT/trimui/app/MainUI:9-11`）。
- 不要把发行包 `dd` 到 `/dev/mmcblk0`：那是内置 eMMC 而非 SD，覆盖后缺 bootloader 必然无法启动。
- FEL / U-Boot 直写 eMMC 属未验证的高风险社区做法，可能变砖、覆盖 bootloader、丢数据；任何命令都需明确警示，不承诺"绝对安全"。

详见 EMMC-FLASH.md。


## Timeline

- time: 2026-11-21T13:44:52
  kind: decision
  summary: "Created this page: TrimUI Brick eMMC 刷写调查"
  source: "2026-11-21 仓库+外部资料调研"
  affects: [trimui-emmc-flash]

- time: 2026-11-21T13:44:52
  kind: decision
  summary: "记录 eMMC 调查核心结论并指向仓库文档"
  source: "2026-11-21 仓库+外部资料调研"
  affects: [trimui-emmc-flash]
