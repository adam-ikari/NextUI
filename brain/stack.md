---
slug: stack
title: Tech stack
role: tech-stack choices
updated: "2026-11-19T10:15:47"
---

# Tech stack

## Technology choices
| domain | candidates | decision | rationale |
|---|---|---|---|
| 语言 | C / C++ | C(C99) | 资源受限嵌入式目标,依赖少、启动快、跨工具链稳定 |
| 图形/输入/音频 | SDL1.2 / SDL2 | SDL2(SDL1.2 正在退役) | 跨设备一致;渲染上下文启动快 |
| 音频重采样 | libsamplerate / 内置重采样 | libsamplerate | 高质量;可逐模拟器配置质量/性能 |
| 模拟器接口 | 独立模拟器 / libretro | libretro 核心 + 自研 minarch 前端 | 核心共用且与前端(存档/暂停/菜单)深度集成 |
| 光盘镜像 | ISO / CHD | libchdr | 支持压缩 CHD 镜像 |
| 成就系统 | RetroAchievements API | rcheevos 集成 | 与 libretro 核心无缝配合 |
| 构建 | CMake / make | make + 交叉编译工具链容器 | MinUI 遗产,直接简单 |
| UI 字体 | font1 (Next) / LXGW / Fusion Pixel | Fusion Pixel 12px 像素字体为默认 | 中英文风格统一,像素字体在现有 SCALE1 尺寸下更清晰 |
| UI 语言 | English / 简体中文 | 简体中文为默认,双语词条经 lang.h/lang.c 管理 | 本地化优先;语言设置仍可在系统菜单切换 |
| UI 字号 | 各应用自定义 / 统一字体角色 | 标题 font.large(16),取值/说明 font.small(12) | 主菜单、设置、模拟器菜单使用相同字号角色,消除视觉差异 |

## Decision mindmap
```mermaid
graph LR
  D[模拟器运行] --> C1[独立模拟器]
  D --> C2[libretro 核心]
  C2 --> P[minarch.elf 自研前端]
  R[渲染] --> P2[SDL2 RGB565]
  A[音频] --> P3[libsamplerate]
  U[UI] --> F[Fusion Pixel 默认字体]
  U --> L[lang.h/lang.c 双语]
  U --> S[统一 font.large/font.small 角色]
```

## Open items
- 退役 SDL1.2 / 低分辨率 / 32 位设备的最终清单与时间点(见 `todo.txt` 讨论)
- tg5040 启动耗时优化(渲染上下文 ~500ms vs 其他设备 ~200ms,原因未定)
