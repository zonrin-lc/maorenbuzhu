# 《猫忍不住》L11「越靠近城门越忙」v1.4.11

本版把第三章中段从线性关升级为“双线程压力关”，基于当前 v1.4.x 工程骨架。

## 主要落地
- 7 个 MAIN：守卫 A / 炸药 / 狗 / 毒雾 / 守卫 B / 蒺藜 / 城门。
- 炸药为非阻挡线程：读图结束后开启 6 秒窗口，超时会扣 1 心但不会结束整关。
- 守卫 A 成功离岗后启动守卫 B 的 8 秒补位窗口；B 仍是固定路线阻挡事件。
- 狗用鱼肉被引到侧区，作为中段减压而不是永久队友。
- 解毒药与鱼肉加入 L11 携带链。
- 城门新增为 PASSIVE 终段事件，路线扩展为“城门 → Goal”，避免抵达城门直接跳 Goal。
- 加入 L11 CatTunnel，仅缩短猫的赶场距离，不修改 Ninja 固定路线。
- Guard A/B 禁用通用 GUARD_DISTRACT，避免一次操作同时拉走两名守卫。
- HUD 显示双线程状态与两个压力计时器。

## 验收
- 7 MAIN：PASS
- E02 non-blocking：PASS
- E07 gate：PASS
- 8s Guard B timer：PASS
- 6s Dynamite side window：PASS
- Dog diversion：PASS
- Goal route expanded：PASS
- 静态脚本扫描：PASS

> 当前环境无 Godot 4 Runtime，本版未声明实机运行通过。
