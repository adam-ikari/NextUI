---
slug: flow
title: Key flows
role: key flows
updated: "2026-08-21T08:57:15"
---

# Key flows

## End-to-end path of a typical request
```mermaid
sequenceDiagram
  participant U as User
  participant N as nextui.elf
  participant P as pak launch.sh
  participant M as minarch.elf
  U->>N: 浏览 Roms 并选择 ROM
  N->>N: 按 ROM 父目录标签(如 (GB))匹配 Emus/&lt;platform&gt;/&lt;TAG&gt;.pak
  N->>P: 调用 pak 的 launch.sh
  P->>M: minarch.elf &lt;core&gt; "&lt;ROM&gt;"
  M->>M: 加载 *_libretro.so 并运行游戏
  U->>M: 按 MENU 呼出游戏内菜单
  M-->>N: 退出游戏,返回主菜单
```
## Other important flows
- **开机**: 平台 boot → keymon → nextui.elf 主界面;SYSTEM/&lt;platform&gt;/bin 下的服务(batmon、audiomon、gametime 等)随系统启动
- **设置保存**: UI 修改 → .userdata/&lt;platform&gt;/minuisettings.txt;Paks 通过 default.cfg 提供默认选项与按键绑定
- **游戏切换器**: 游戏内按 SELECT 快速切换最近游玩,不退出当前游戏
- **Paks 安装**: 更新时 .system 被整体重建;额外 Paks 必须放在 SD 卡根部的 Emus/ / Tools/ 下
