---
id: base-platform-decision
title: "项目基座决策：保留 NextUI"
category: decision
status: active
tags: [base, license, minui, nextui]
created: "2026-11-23T00:04:39"
updated: "2026-11-23T00:06:26"
---

<!-- compiled_truth -->
## 决策

保留当前 NextUI 基座（adam-ikari/NextUI，基于 LoveRetro/NextUI），不切换到原版 shauninman/MinUI。2026-11-23 明确放弃换基座。

## 理由

- **架构不兼容**：原版 MinUI 没有 C++ 设置系统（settings.cpp / wifimenu.cpp / btmenu.cpp）、没有 CFG 配置系统、没有 lang i18n、没有 Settings.pak / LedControl.pak、没有 suspend 脚本。本会话 6 项改动里仅 USB Mass Storage PAK 能直接移植；RTC 关机需适配；SSH 设置整合 / LED 注册 / WiFi-BT 扫描提示依赖不存在的 C++ 基础设施，移植等于重写。
- **会丢失 NextUI 增强**：换基座等于放弃重写模拟引擎、屏幕同步修复、C++ 设置系统等全部 NextUI 特性。
- **许可证不更宽松**：两端都禁止商用。原版 MinUI 无正式许可证（README 仅"feel free to fork or learn from any of my repos"）；当前 NextUI 是 PolyForm Noncommercial 1.0.0（2026-08-15 起，之前 GPL-3.0）。非商用 fork 两端都允许，但换基座不解决任何许可问题。
- 当前仓库本就是 upstream (LoveRetro/NextUI) 直系，无落后。

## 合规待办（非阻塞）

- USB Mass Storage PAK 基于 josegonzalez/trimui-brick-usb-mass-storage-pak（MIT），当前仅在脚本注释标注 "Based on"，分发物应附 MIT LICENSE 文本。


## Timeline

- time: 2026-11-23T00:04:39
  kind: decision
  summary: "Created this page: 项目基座决策：保留 NextUI"
  source: 2026-11-23 session
  affects: [base-platform-decision]

- time: 2026-11-23T00:06:26
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: 2026-11-23 session
  affects: [base-platform-decision]
