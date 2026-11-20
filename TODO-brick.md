# TrimUI Brick（tg5050）待办优化

本文件记录 TrimUI Brick（tg5050）的待办优化，来源为 2026-11-19 调研（工作会话 + todo.txt + README + 代码）；已完成项见正文备注。

### 1. 渲染上下文初始化慢，冷启动多耗约 300ms
影响：高（每次开机必现）
证据：todo.txt:56-60「just getting the rendering context going takes ~500ms versus ~200ms on other devices」；brain/stack.md:39；workspace/tg5050/install/boot.sh 与 paks/MinUI.pak/launch.sh 有 /tmp/nextui_boottime 计时打点
规模：大
备注：上游曾试自编译 SDL2 无改善。

### 2. 关机/挂起偶发卡死
影响：高（需硬断电、有丢档风险）
证据：todo.txt:61-62「try to reproduce hung shutdowns and fix」、todo.txt:379-381「while (1) pause(); prevents shutdown on some platforms」；workspace/tg5050/platform/platform.c PLAT_powerOff 固定 sleep(2)
规模：中
备注：需先稳定复现。

### 3. Deep sleep 失败回退与 overheat 规避不稳
影响：高（README 称 deep sleep 是 Brick 过热 bug 的解法）
证据：README.md:77,117-121；workspace/all/common/api.c:4443-4471（超时后失败直接 poweroff）、:4504-4516（依赖 $BIN_PATH/suspend）；skeleton/SYSTEM/tg5050/bin/suspend echo mem 重试 5 次
规模：中
备注：suspend 脚本的 tg5040 遗留路径与蓝牙启动路径已在 2026-11-20 修正。

### 4. 显示校准数据在 tg5050 空转
影响：中（色准；BrickPro 预设标注 TODO）
证据：workspace/all/common/displaycal.h:23-30；workspace/tg5050/libmsettings/msettings.c:117-120 默认禁用、:263 强制 displaycal_enabled=0、:284-286 applyDisplayCalSettings 空实现、:474-477 setter 忽略入参
规模：小-中
备注：需先确认 /dev/disp 是否支持；不支持则隐藏 UI 或改说明。

### 5. 音频 underrun、爆音与核心切换后状态未恢复
影响：中
证据：todo.txt:164-175「400 SAMPLES fix isn't a true fix, it just minimizes the side effect」、todo.txt:274-281；workspace/tg5050/platform/platform.c:318-343 非原生采样率统一回退 48000
规模：中-大
备注：无。

### 6. 8888→565→8888 转换与 CPU→GPU 纹理拷贝开销
影响：中（PS1/高分辨率核心掉帧）
证据：todo.txt:207-220「this might be a bottleneck ... not a single BASE or EXTRA core requests 8888」；todo.txt:222-228 SDL_UnlockTexture 阻塞 3-11ms
规模：中
备注：无。

### 7. Ambient LED 分区与物理灯数错位，Brick 4 区 / Pro 5 区未完整支持
影响：中低
证据：workspace/all/common/api.c:727-753 Brick 布局按 count 剪裁；workspace/tg5050/platform/platform.c PLAT_getNumLeds 当前返回 3
规模：中
备注：2026-11-20 已修零值槽全灭 bug 并对齐 3 槽；完整支持需 DEVICE 型号检测并提高共享 MAX_LIGHTS。

### 8. 设备识别/耳机与 USB 状态缺失，休眠超时默认值与文档不符
影响：中低
证据：workspace/tg5050/install/boot.sh:13,38 依赖 MainUI 字符串与 DEVICE；workspace/tg5050/platform/platform.c PLAT_getModel 默认值已改为 Trimui Brick、PLAT_isUSBConnected 未实现；todo.txt:64-66 建议改用 /proc/device-tree/model、todo.txt:412「can't detect headphone state at boot?」；workspace/all/common/config.h:233 默认 30s vs README.md:121「After two minutes」
规模：小-中
备注：PLAT_getModel 默认值 2026-11-20 已修，剩余 USB/耳机检测与超时默认值待定。

每项实施前需重新验证证据中的行号，代码可能已变。
