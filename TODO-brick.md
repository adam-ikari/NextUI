# TrimUI Brick（tg5050）待办优化

本文件记录 TrimUI Brick（tg5050）的待办优化，来源为 2026-11-19 调研（工作会话 + todo.txt + README + 代码）；已完成项见正文备注。

### 1. 渲染上下文初始化慢，冷启动多耗约 300ms
影响：高（每次开机必现）
证据：todo.txt:56-60 与 brain/stack.md:39 的 ~500ms vs ~200ms 观测实为 tg5040（Smart Pro），非 tg5050；workspace/tg5050/install/boot.sh 与 paks/MinUI.pak/launch.sh 的 /tmp/nextui_boottime 打点均不覆盖渲染初始化（nextui.elf 内部）。
规模：大
备注：2026-11-21 审查结论：需真机计时剖析。渲染初始化（generic_video.c:605-709 PLAT_initVideo）全平台共享，tg5050 无多余步骤；源码已有被注释的 main_begin/graphics init 计时（nextui.c:2251-2252,2262），取消注释并在 SDL_CreateWindow/Renderer/GL_CreateContext/纹理创建前后加 SDL_GetTicks 日志即可得到 tg5050 实际耗时。上游自编译 SDL2 无改善是 tg5040 结论，不可外推。

### 2. 关机/挂起偶发卡死
影响：高（需硬断电、有丢档风险）
证据：todo.txt:61-62「try to reproduce hung shutdowns and fix」、todo.txt:379-381「while (1) pause(); prevents shutdown on some platforms」；workspace/tg5050/platform/platform.c PLAT_powerOff 固定 sleep(2)
规模：中
备注：2026-11-21 审查结论：未发现可安全修复的 bug。tg5050 的 PLAT_powerOff 与 tg5040 逐字一致，原生 poweroff 与 tg5040/h700 的差异属平台启动链设计而非漏补；api.c 的 killall -STOP→-TERM 修复已包含。真因需硬件复现与日志（stock poweroff / SD sync 阻塞 / framebuffer 写入），不做推测性改动。

### 3. Deep sleep 失败回退与 overheat 规避不稳
影响：高（README 称 deep sleep 是 Brick 过热 bug 的解法）
证据：README.md:77,117-121；workspace/all/common/api.c:4443-4471（超时后失败直接 poweroff）、:4504-4516（依赖 $BIN_PATH/suspend）；skeleton/SYSTEM/tg5050/bin/suspend echo mem 重试 5 次
规模：中
备注：2026-11-21 已修 suspend 脚本的 false-negative retval 防护（补回 tg5040 同款 time_asleep>5 逻辑，避免唤醒后立即再次挂起或被误判失败关机）；overheat 规避本身仍依赖硬件验证。

### 4. 显示校准数据在 tg5050 空转
影响：中（色准；BrickPro 预设标注 TODO）
证据：workspace/all/common/displaycal.h:23-30；workspace/tg5050/libmsettings/msettings.c:117-120 默认禁用、:263 强制 displaycal_enabled=0、:284-286 applyDisplayCalSettings 空实现、:474-477 setter 忽略入参
规模：小-中
备注：2026-11-21 已修复：settings.cpp 的 hasDisplayCal() 现已对 Brick/BrickPro 型号返回 false，隐藏无用的白点校正菜单；底层空实现保持不变。

### 5. 音频 underrun、爆音与核心切换后状态未恢复
影响：中
证据：todo.txt:164-175「400 SAMPLES fix isn't a true fix, it just minimizes the side effect」、todo.txt:274-281；workspace/tg5050/platform/platform.c:318-343 非原生采样率统一回退 48000
规模：中-大
备注：2026-11-21 审查结论：需真机复现，代码层无安全修复。400 SAMPLES 方案作者自否为真修复（todo.txt:166）且上游已删除（077285f5）；当前已含 8 帧 ring buffer、动态速率调节、填充阈值暂停；SND_resetAudio 每次完整重建音频状态，采样率回退与 tg5040 一致，无"切换后未 apply"的 bug。下一步需 Brick 真机开 show_debug 记录 buffer_free/ratio/buffer_ms 与爆音时刻的相关性。

### 6. 8888→565→8888 转换与 CPU→GPU 纹理拷贝开销
影响：中（PS1/高分辨率核心掉帧）
证据：todo.txt:207-220「this might be a bottleneck ... not a single BASE or EXTRA core requests 8888」；todo.txt:222-228 SDL_UnlockTexture 阻塞 3-11ms
规模：中
备注：2026-11-21 审查结论：已过期，无需改。上游在提交 568d8318/c8d35d3a 已把 Lock/Unlock 切成 SDL_UpdateTexture（tg5050 初始提交 89158fe5 即用 UpdateTexture）；当前无 Lock/Unlock 调用点，不存在 8888 往返。核心帧走 GL 上传（generic_video.c glTexSubImage2D），继续优化需真机剖析颜色转换与上传耗时，改共享文件只有风险无收益。

### 7. Ambient LED 分区与物理灯数错位，Brick 4 区 / Pro 5 区未完整支持
影响：中低
证据：workspace/all/common/api.c:727-753 Brick 布局按 count 剪裁（共享代码）；skeleton/BOOT/common/updater:21-25 型号映射（TG3040/4040→tg5040，TG5050→Smart Pro S）；Brick/Pro 的 4/5 区实现见 workspace/tg5040/platform/platform.c 与 ledsettings_brick*.txt（commit 07194642）
规模：中
备注：2026-11-21 审查结论：前提错配，不做改动。仓库铁证 `skeleton/BOOT/common/updater:21-25` 明确 TG3040/TG4040→tg5040（Brick/Brick Pro）、TG5050→Smart Pro S，即 tg5050 实为 Smart Pro S（3 区），无 4/5 区硬件证据；Brick(4 区)/BrickPro(5 区) 的完整 LED 支持早已在 tg5040 实现（commit 07194642，含 is_brick/is_brickpro 检测、4/5/3 计数、per-zone sysfs 节点）。TODO 原文让 tg5050 支持 4/5 区是平台归属错误。唯一潜在缺口是 `api.c:727-753` 的 ambient 从不写索引 4（Pro 的 rear 区），但设计意图不明、无 git 铁证、需真机确认，不做推测性修改。

### 8. 设备识别/耳机与 USB 状态缺失，休眠超时默认值与文档不符
影响：中低
证据：workspace/tg5050/install/boot.sh:13,38 依赖 MainUI 字符串与 DEVICE；workspace/tg5050/platform/platform.c PLAT_getModel 默认值已改为 Trimui Brick、PLAT_isUSBConnected 已实现（读 /sys/class/udc/*/state）；todo.txt:64-66 建议改用 /proc/device-tree/model、todo.txt:412「can't detect headphone state at boot?」；workspace/all/common/config.h:233 默认 120s（2026-11-21 由 30s 修正）与 README.md:121「After two minutes」一致
规模：小-中
备注：2026-11-21 已修 PLAT_getModel 默认值、PLAT_isUSBConnected（/sys/class/udc/*/state）与休眠超时默认值（config.h 30s→120s，恢复 README 两分钟语义）；仅剩耳机检测因硬件限制未做。

每项实施前需重新验证证据中的行号，代码可能已变。
