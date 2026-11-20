---
id: i18n-finalization
title: "I18N 收尾决策"
category: decision
status: active
tags: [i18n, minarch, settings]
created: "2026-11-20T15:53:16"
updated: "2026-11-20T17:35:56"
---

<!-- compiled_truth -->
## 决策

- strftime 本地化格式串不使用 `%B`（月份名）/`%p`（AM/PM）：嵌入式目标 locale 未保证加载；中英格式统一用 `%Y-%m-%d %H:%M` 纯数字形式。
- `MenuItem.name` 是 `char*`，`LANG()` 返回 `const char*`：静态初始化列表不能用 `LANG()`（非常量表达式），在 `Options_updateVisibility()` / `OptionSaveChanges_openMenu()` / `OptionShortcuts_openMenu()` 等进入菜单前的函数里用 `LANG()` 覆盖 name/desc 字段。
- `refreshLocalizedLabels()` 必须在 `GFX_init()`（内部调用 `CFG_init()` → `LANG_set()`）之后调用，否则默认简中下写入的取值标签全是英文。
- `LANG(key)` 在构建时求值，语言切换需重启应用才对已构建菜单生效；属已知限制，未修复。

## 范围

- 2026-11-20 收尾：ma_menu.c 选项菜单与成就详情、ma_frontend_opts.c 模拟器选项子菜单、settings.cpp 底部按钮提示完成本地化。
- 验证：`gcc/g++ -fsyntax-only` 全部 0 error；`git diff --check` 干净；403 个 LANG enum key 与 lang.c 词条一一对应，无缺失/重复。


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

- time: 2026-11-20T17:35:56
  kind: decision
  summary: Rewrote compiled_truth to the new best understanding
  source: 2026-11-20 review fixes
  affects: [i18n-finalization]
