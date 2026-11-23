---
id: stability-audit-2026-11
title: "稳定性审计发现与处置（2026-11-23）"
category: reference
status: active
tags: [stability, bug, audit]
created: "2026-11-23T09:31:05"
updated: "2026-11-23T09:31:52"
---

<!-- compiled_truth -->
## 已修复（本会话，均已推送）

- **WiFi/BT 扫描线程退出标志数据竞争**：`wifimenu.hpp`/`btmenu.hpp` 的 `quit` 改 `std::atomic<bool>`，worker 循环去掉对主线程 `globalQuit` 的跨线程读取。commit d315c475。
- **GFX_wrapText 首词超宽 NULL 解引用**：`api.c` wrap 分支 `prev[0]='\n'` 加 NULL 保护（首词就超宽时 prev 为 NULL）。commit a624b14e。
- **CFG_sync 非原子写**：改为 tmp 文件 + fflush/fsync + rename，防掉电/kill 损坏 minuisettings.txt。commit a624b14e。
- **升级包解压失败仍删包**：`workspace/{tg5040,tg5050}/install/boot.sh` 对齐 h700 检查 unzip 返回值，失败 exit 保留包。commit 4080ca5f。
- **陈旧 /tmp/next**：三平台 `MinUI.pak/launch.sh` 启动循环前 `rm -f /tmp/next`，防崩溃残留命令被 eval。commit 4080ca5f。

## 未修复（已评估，需更大改动或真机证据）

高优先级但未做（涉及所有权重构/double-free 风险，需成体系处理，不适合小改动）：
- **子菜单永不析构**：`menu.hpp:172` `~AbstractMenuItem` 的 `delete submenu` 被注释；顶层 WiFi/BT 子菜单无人 delete，worker 线程在退出 Settings 后仍每 2s 扫描。修需统一 submenu 所有权（颜色 picker 由 unique_ptr + submenu 双重引用，直接 delete 会双重释放）。
- **items.clear() 泄漏**：`wifimenu.cpp:167,214`/`btmenu.cpp:202,251` 每 2s clear 后重建网络项，旧 NetworkItem/options 未 delete，长时间停留可 OOM。与子菜单所有权、scope 并发是同一组问题，须一起设计。
- **scope/items 并发无有效同步**：`menu.cpp:321-343` performLayout 持 ReadLock 却写 scope；worker 释锁后才 performLayout/selectByName；`items.at()` 无边界检查 → 列表项数变化窗口可抛 out_of_range 崩溃。
- **GFX_truncateText 无界 strcpy**：`api.c:1019-1032` strcpy 无长度、`len<4` 时负偏移写；源是 ROM 路径可达 512 字节，多调用方缓冲 256。修要改签名加缓冲长度，调用方多，风险中。
- **文本函数固定 line[256]**：`api.c:2201,2601,2652` 长单行文本可栈溢出。

中低优先级（影响小或需真机）：
- 信号 handler 用非 volatile 变量（settings.cpp:34-52 等）；SIGSTOP 不可捕获是死代码。appQuit 作 `const int&` 传给 Menu，改 volatile 需扩散签名。
- fancontrol 锁文件被 C 层 unlink（tg5050）；蓝牙初始化无锁（tg5040/tg5050，h700 有锁可移植）。
- run_hooks.sh 无超时 wait 可无限阻塞（加 timeout 会影响第三方 hook 等待语义）。
- 早期关机分支在 PATH 设置前调 poweroff_next（缺真机证据，正常关机路径同样裸调用，未改）。
- makefile.native 空格缩进 recipe、COMPILE_CORES 变量作用域、makefile:280 空 RELEASE_VERSION。


## Timeline

- time: 2026-11-23T09:31:05
  kind: decision
  summary: "Created this page: 稳定性审计发现与处置（2026-11-23）"
  source: 2026-11-23 session
  affects: [stability-audit-2026-11]

- time: 2026-11-23T09:31:52
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: 2026-11-23 session
  affects: [stability-audit-2026-11]
