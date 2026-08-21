---
slug: background
title: Project background
role: project background
updated: "2026-08-21T08:31:02"
---

# Project background

## Why
NextUI 是复古游戏掌机的开源固件/用户界面,提供统一、轻量、高质量的游戏体验,替代厂商原装固件。它源自 MinUI,延续"小而专注"的设计哲学,专注游戏而非通用操作系统。

## Goals
- 低延迟:输入/渲染平均约 20ms(60fps 下 1 帧)
- 高音质:基于 libsamplerate 的重采样引擎,每个模拟器可单独配置质量/性能
- 一致的体验:主菜单、游戏内菜单、快速保存/自动恢复、按键绑定、选项界面在设备与核心之间保持一致
- 可扩展:Paks 系统让社区无需改固件即可加入模拟器与工具
- 多设备支持:覆盖多款国产掌机(Trimui、Anbernic、Miyoo、Powkiddy 等)

## Non-goals
- 不实现 OpenGL libretro API;仅支持 RGB565 像素格式
- 不做通用操作系统/应用商店;专注游戏前端
- 不对已计划退役的 SDL1.2 / 低分辨率 / 32 位设备持续投入
- 不为第三方 Paks 提供官方支持(内核作者只维护自带的 Emus/Tools)

## Target user
复古游戏掌机玩家,主要在 Linux 掌机上玩 8/16/32 位主机与 PS1 游戏,希望获得比原装固件更干净、更快、可自定义的界面。
