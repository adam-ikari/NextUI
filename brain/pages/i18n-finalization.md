---
id: i18n-finalization
title: "I18N 收尾决策"
category: decision
status: active
tags: [i18n, minarch, settings]
created: "2026-11-20T15:53:16"
updated: "2026-11-20T15:56:58"
---

<!-- compiled_truth -->
## 决策

- strftime 本地化格式串不使用 `%B`（月份名）/`%p`（AM/PM）：嵌入式目标 locale 未保证加载；中文格式用 `%Y-%m-%d %H:%M` 纯数字形式。
- `MenuItem.name` 是 `char*`，`LANG()` 返回 `const char*`：静态初始化列表不能用 `LANG()`（非常量表达式），在 `Options_updateVisibility()` 等进入菜单前的函数里用 `LANG()` 覆盖 name 字段。
- `LANG(key)` 在构建时求值，语言切换需重启应用才对已构建菜单生效；属已知限制，未修复。

## 范围

- 2026-11-20 收尾：ma_menu.c 的 options_menu 8 项、成就详情 10 处文案、settings.cpp 底部按钮提示完成本地化。
- 验证：`gcc/g++ -fsyntax-only` 全部 0 error；`git diff --check` 干净；402 个 LANG enum key 与 lang.c 词条一一对应，无缺失/重复。


## Timeline

- time: 2026-11-20T15:53:16
  kind: decision
  summary: "Created this page: I18N 收尾决策"
  source: 2026-11-20 session
  affects: [i18n-finalization]

- time: 2026-11-20T15:56:58
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: 2026-11-20 session
  affects: [i18n-finalization]
