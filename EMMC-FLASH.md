# TrimUI Brick（tg5050）内置 eMMC 刷写调查

> 结论：NextUI 仓库不提供官方 eMMC 刷写支持。设计是 SD 卡启动 + 劫持 stock OS，发行包是 zip 文件树（makefile:254-257），无整盘镜像/bootloader/u-boot。不要把发行包 dd 到 /dev/mmcblk0。

## 仓库证据

- 无 `docs/` 目录；安装说明全为外链：`README.md` 的 Installation Guide、`skeleton/BASE/README.txt:37`。
- 全仓关键词 `emmc`、`sunxi-fel`、`boot0`、`bootloader`、`u-boot`、`/dev/mmcblk`（tg5050 相关）、`dd`、`mkfs`、`fdisk`、`parted` **均无命中**。唯一相关行：`todo.txt:475` "might also enable installing linux to emmc"，上下文是 rpmini，不是 Brick（`todo.txt:468-475`）。
- `git log --oneline --all --grep='emmc\|eMMC\|flash\|install' -i` 只命中 install/flash 通用提交（如 `89158fe5 Tg5050 (#573)`），无 eMMC 刷写提交。GitHub issue 搜索 `emmc` 命中 1 条但无关（#705 CPU 频率），"internal storage" 0 条。
- `skeleton/BOOT/` 不是磁盘镜像：`makefile:214-220` 把 `common` 变成 SD 上的 `.tmp_update/updater`，`trimui` 放入 BASE；`makefile:254-257` 把 `.system`、`.tmp_update`、`Tools` 打成 `MinUI.zip`。没有分区表、bootloader。
- 实际安装流程：`MainUI` 脚本（`skeleton/BOOT/trimui/app/MainUI:9-22`）把 stock 的 `runtrimui.sh` 改名为 `runtrimui-original.sh`，复制 NextUI 的 `runtrimui.sh` 到 `/usr/trimui/bin/`（内置 eMMC 的 rootfs），再把 `.tmp_update` 复制到 SD 并执行 updater。
- `updater`（`skeleton/BOOT/common/updater:5-40`）按 `/proc/cpuinfo` 识别平台，`tg5050` 分支在 `:24-25`；随后执行 `/mnt/SDCARD/.tmp_update/tg5050.sh`。
- `workspace/tg5050/install/boot.sh`：只操作 `/mnt/SDCARD`（`:5-8`），`:111` 把 `MinUI.zip` 解包到 SD，`:123-126` 从 SD 启动 `MinUI.pak/launch.sh`，`:129` `poweroff` 阻止 stock 再碰卡。没有写 eMMC 的刷机代码。
- 一个例外：`workspace/all/bootlogo/bootlogo.c:195-200` 会 `mount -t vfat /dev/mmcblk0p1` 并复制 `bootlogo.bmp`。这是仓库内唯一确认可写内置 eMMC 分区的功能（boot 分区改 logo），可作为"内置 eMMC p1 是 FAT 启动分区"的证据，但不等同于刷系统。
- 平台命名矛盾：仓库 `updater:24-25` 注释 `tg5050 = Trimui Smart Pro S`，但 `workspace/tg5050/platform/platform.c:375-380` 默认返回 `"Trimui Brick"`，`TODO-brick.md:1` 也写"TrimUI Brick（tg5050）"。按你手上的机型选对应发行包，别只凭代号。

## 硬件启动链

> 本节为外部资料与社区资料，非仓库证据，已标注来源。

- TrimUI Brick（TG3040）为 Allwinner A133，u-boot/bootloader/kernel 来自 stock 固件，TrimUI 未公开 BSP 源码（KNULLI Wiki `knulli.org/devices/trimui/brick/`；`knulli.org/guides/firmware-extraction/A133-firmware-extract/`）。
- stock OS 在内置存储，无 SD 也能启动；NextUI 是"在 stock OS 之上劫持启动"（Reddit r/trimui 讨论）。这与仓库 `MainUI:9-11` 的 bootstrap 行为一致。
- 全志 BROM 启动顺序（U-Boot 文档 `docs.u-boot-project.org/en/stable/board/allwinner/sunxi.html`）：先检查 SD 的 sector 16/128，再 eMMC user/boot 分区，最后 FEL。`u-boot-sunxi-with-spl.bin` 可写 SD、`/dev/mmcblkX` 第 8K/128K 或 `mmcblkXboot0`；FEL 用 `sunxi-fel uboot ...`。**但 NextUI 仓库没有这个文件**，必须取自 stock 或自建 BSP。
- 官方 stock 刷 eMMC 机制：FAT32 SD 根目录放 `trimui_tg3040.awimg`，按住 `VOL−` 再按 `POWER` 进入更新，进度条跑完重启（RetroCompass `retrocompass.web.app/en/trimui/brick/firmware-update`；firmware_brick release 资产 `TG3040_Brick_firmware_v1.1.1.zip`、`sd_recovery_BRICK_tg3040_v1.1.1_20251126.zip`）。NextUI 没有 `.awimg`。

## 可行方案（按安全性排序）

> ⚠️ 以下所有命令均为**调研说明，勿执行**。危险操作可能变砖、丢数据、覆盖 bootloader 或损耗 eMMC 寿命；本调查不提供任何"绝对安全"承诺。

### 方案 1：SD 卡安装（推荐，仓库支持）

- **前置条件**：不需拆机、短接、UART；只需 SD 卡。开发机还可用 ADB（`makefile:51`：`adb push ./build/BASE/MinUI.zip /mnt/SDCARD && adb shell reboot`）。
- **步骤示意（调研说明，勿执行）**：FAT32/MBR 格式化 SD → 解压 `releases/NextUI-*-base.zip` 到卡根（含 `trimui/`、`MinUI.zip`）→ 插卡开机 → stock 执行 `trimui/app/MainUI` 写入 bootstrap 并安装 `.system` → 自动重启/poweroff。依据：`skeleton/BASE/README.txt:37`、`MainUI:9-22`、`boot.sh:111,123-126`。
- **风险**：bootstrap 会改内置 eMMC 的 `/usr/trimui/bin/runtrimui.sh`；安装中断电可能留半状态；`poweroff` 设计是为防 stock 回写 SD（`boot.sh:129`）。没有"绝对安全"承诺。
- **可逆性**：保留 `runtrimui-original.sh` 即可恢复 stock 启动；删 SD 上 NextUI 文件不影响内置系统。

### 方案 2：仅改内置 boot 分区 logo

- **前置条件**：已能进入 NextUI；使用 bootlogo 工具。
- **步骤示意（调研说明，勿执行）**：`mount -t vfat /dev/mmcblk0p1 /mnt/boot && cp xxx.bmp /mnt/boot/bootlogo.bmp && sync && umount`（`bootlogo.c:195-200`）。
- **风险**：写错分区/文件可能丢开机 logo；不涉及 bootloader，但仍写内置 flash。
- **可逆性**：备份原 `bootlogo.bmp` 即可恢复。

### 方案 3：官方 .awimg 恢复 stock（仅恢复 stock，不能刷 NextUI）

- **前置条件**：FAT32 SD、官方 `.awimg`；组合键 `VOL− + POWER`；无需拆机。
- **步骤示意（调研说明，勿执行）**：拷贝 `trimui_tg3040.awimg` 到卡根 → 关机 → 按住 VOL− 按 POWER → 进度条完成自动重启。
- **风险**：这是整包刷写，会覆盖 eMMC 上的 bootloader/kernel/rootfs；文件不匹配或中途断电会变砖。NextUI 没有 `.awimg`，所以**不能用来刷 NextUI**。
- **可逆性**：用官方 `sd_recovery_BRICK_tg3040_*.zip` 恢复 stock（不保证成功）。

### 方案 4：FEL / U-Boot 直写 eMMC（高风险）

- **前置条件**：进入 FEL（无有效启动介质、FEL 键或特制 SD magic），USB-OTG 连主机，`sunxi-tools`/Zadig 驱动；需要 stock 的 boot0/u-boot/kernel 二进制文件。社区有 Brick 用户用 `sunxi-fel` 尝试救砖但缺 bootloader 文件而失败（Reddit r/trimui `1p9urdy`）。
- **步骤示意（调研说明，勿执行）**：`sunxi-fel uboot u-boot-sunxi-with-spl.bin`（FEL 引导 U-Boot）→ `mmc dev 1` / `mmc write $addr 0x10 0x7f0`（写 eMMC user 区）或 `mmc bootpart enable 1 1` + `echo 0 > /sys/block/mmcblkXboot0/force_ro` + `dd if=u-boot-sunxi-with-spl.bin of=/dev/mmcblkXboot0`（写 boot 分区）。命令来源为 U-Boot 文档，**不是仓库实践**。
- **风险**：⚠️ 写错设备节点会毁 SD 或 eMMC；错误 boot0/u-boot 直接变砖；boot 分区有持久写保护配置（`mmc bootbus`/`mmc partconf`）；整片重写加速 eMMC 磨损。
- **可逆性**：仅当 FEL 仍可用时可重刷；否则需官方 recovery 或拆机编程器。

## 辟谣：不要 dd NextUI 到 /dev/mmcblk0

用户提到的"从 SD 启动后 dd 镜像到 /dev/mmcblk0"对 NextUI 不适用：

- 发行包是 zip 文件树（`makefile:254-257`），**没有整盘镜像**；`dd` 一个 zip 不会产生可启动系统。
- `/dev/mmcblk0` 是内置 eMMC（跑 stock），不是 SD；`boot.sh` 全程用 `/mnt/SDCARD`（`:5-8`）。
- NextUI 的 bootloader/u-boot/kernel 来自 stock（KNULLI Wiki），dd 覆盖后没有这些组件必然无法启动。
- 这是社区对"通用 Linux 镜像"的习惯做法，属于**推测/误用**，不是仓库证据，也不是 Brick 的有效方案。

## 一句话回答

用 SD 卡；要"不插卡启动"就得自己造含 stock BSP 的 `.awimg`/FEL 镜像，仓库没有任何支持，且变砖风险自负。

## 来源与日期

- 调查日期：**2026-11-21**。
- **仓库证据**：`README.md`、`skeleton/BASE/README.txt`、`makefile`、`skeleton/BOOT/**`、`workspace/tg5050/install/boot.sh`、`workspace/tg5050/platform/platform.c`、`workspace/all/bootlogo/bootlogo.c`、`todo.txt`、`TODO-brick.md`、git log 与 GitHub issue 搜索，证据行号见上文。
- **外部资料**：KNULLI Wiki、U-Boot 官方文档、RetroCompass、Reddit r/trimui、TrimUI 官方 firmware_brick release。
- **推测/社区常见做法**：FEL/dd 直接刷 eMMC 的具体命令来自通用 Allwinner 实践，未在 NextUI 仓库或 Brick 上验证；仅作风险说明，**勿执行**。
