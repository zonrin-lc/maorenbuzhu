# 《猫忍不住》v1.5.3 动画层级反馈改动

基线：v1.5.2 反馈品质整合版。

## 本次变更
- 新增 `scripts/actors/animation_feedback_driver.gd`，统一角色动作优先级。
- 猫接入 MOVE / CARRY / ACTION / EMOTE 表现。
- 忍者接入 ALERT / MOVE / HIT / DEATH / VICTORY。
- 守卫接入 ACTION / MOVE / IDLE，并把被引开时灰度移交给表现驱动器。
- 狗接入 ACTION / EMOTE / MOVE / IDLE。
- Boss 接入 ACTION / HIT / DEATH / VICTORY，并把战斗/非战斗基础色调移交给表现驱动器。
- 受击与死亡采用现有 SpriteSheet 帧，不增加外部美术资源。
- 胜利跳跃保存并恢复 Sprite 基础坐标。
- 受击闪白在表现驱动器内部应用，避免被角色主循环覆盖。

## 不改变的内容
- 事件成功/失败判定
- Ninja HP
- Suspicion
- 路线和路点
- Score / Paw
- 存档
- 关卡数据

## 验证
- `scripts/qa/audit_animation_v15_3.py`：0 errors
- Python 脚本 compileall：PASS
- merge conflict marker scan：0
- Godot 4 runtime：当前环境未提供，未作实机运行声明
