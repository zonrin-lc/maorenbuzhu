# 《猫忍不住》v1.5.6 输入体验变更

- 新增 GameInputManager 全局输入设备检测：键鼠 / 手柄 / 触控。
- 核心操作补齐手柄默认映射：A 互动、X 叼取、B 喵叫、Y 卖萌、LB 跳跃、RB 疾跑、START 暂停。
- TouchControls 改为响应式 2×3 动作键 + 左摇杆；按钮尺寸按短边缩放。
- 修复触控按钮可能被 `MOUSE_FILTER_IGNORE` 阻止接收触控的问题。
- HUD 提示根据最近输入设备自动切换；触控模式隐藏冗余键位条。
- 交互提示支持 BITE/PUSH/FEED/PLACE_ANTIDOTE/SEND_DOG/JUMP/CAT_TUNNEL 等语义动作映射。
- 搬运物状态通过 `CatController.set_carry_item()` 同步给 UI。

## 默认手柄布局
A 互动 / X 叼取 / B 喵叫 / Y 卖萌 / LB 跳跃 / RB 疾跑 / START 暂停 / LS 重开。
