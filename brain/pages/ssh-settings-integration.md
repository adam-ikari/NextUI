---
id: ssh-settings-integration
title: "SSH Server 设置整合决策"
category: decision
status: active
tags: [ssh, settings, tg5040, tg5050]
created: "2026-11-22T08:51:22"
updated: "2026-11-22T08:51:34"
---

<!-- compiled_truth -->
## 决策

- SSH Server 整合进系统设置（Settings 菜单 toggle），不做独立 Tools PAK；避免双开关状态分裂。用户明确要求。
- 复用 stock sshd，不自建 dropbear：启用 `systemval enablessh 1` + `/usr/sbin/sshd`，禁用 `systemval enablessh 0` + `killall -9 sshd`。命令序列来自社区验证过的 nextui-nativessh-pak。
- 平台守卫 `tg5040 || tg5050`（updater 映射：tg5040=Brick/BrickPro/Smart Pro，tg5050=Smart Pro S）；两平台 launch.sh 均已加应用段。真机需确认 `/usr/sbin/sshd` 与 `systemval enablessh` 有效（tg5040 需 stock ≥1.1.1）。
- 配置持久化走 CFG 链（`CFG_SSH_ENABLED`，键 `ssh_enabled`，存 `$SHARED_USERDATA_PATH/minuisettings.txt`），非 config.ini；每个 setter 内 `CFG_sync()` 立即写盘。
- **开机应用照搬现有 wifi/bluetooth 模式**：launch.sh 用 `nextval.elf ssh_enabled` 读 CFG，执行系统命令。否决新建 boot.d hook 安装机制（仓库无系统级安装先例，徒增复杂度）；否决复用旧 PAK 的 auto.sh marker（回到独立脚本形态）。
- **重启生效，不做即时生效**：toggle 只写 CFG，sshd 在下次启动 MinUI 时由 launch.sh 应用。描述文案已注明"重启生效"。与 wifi/bluetooth 行为一致。否决 setter 里 system() 即时调用：需重复 shell 命令逻辑、阻塞 UI 线程，且 wifi 等同类设置都不即时生效。

## 范围

- 改动：config.h/config.c（CFG 链 5 处）、lang.h/lang.c（SSH_SERVER/SSH_SERVER_DESC 双语）、settings.cpp（toggle）、两平台 launch.sh（SSH 应用段）、删除两个独立 SSH PAK。
- 验证：两 launch.sh `sh -n` 通过；settings desktop native 编译通过；nextval 实测 `ssh_enabled=1` 写入→读出→sed 提取全链路正确；i18n 2 枚举 ↔ 2 词条配对。
- commit `67ae02043e`，已推送 origin/main。


## Timeline

- time: 2026-11-22T08:51:22
  kind: decision
  summary: "Created this page: SSH Server 设置整合决策"
  source: 2026-11-22 session
  affects: [ssh-settings-integration]

- time: 2026-11-22T08:51:34
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: 2026-11-22 session
  affects: [ssh-settings-integration]
