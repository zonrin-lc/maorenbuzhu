# L08《最后一班船》v1.4.8

本版将第二章已学的三条工作线合并为一个完整链路：守卫处理、狗队友、携带解毒药/环境收尾。

## 主线
1. E01 Guard A：F 喵叫引开
2. E02 Dog Ally：Q 叼鱼肉 + E 喂狗
3. E03 Guard B：E 派狗，必须等狗真实抵达
4. E04 Poison：Q 叼解毒药 + E 放置
5. E05 Caltrop：E 清理
6. E06 Bridge：E 放桥

## 生产规则
- Ninja 仍为固定脚本路线，不使用自由寻路。
- 狗到达 Guard B 前，Ninja 不会释放。
- 事件失败仍允许继续，累计伤害由现有 3 心系统处理。
- CatTunnel 只缩短猫赶场，不改变 Ninja Route。
- Shortcut Mastery 只来自真实捷径穿越。

## 本地试玩检查
- 标准线：A → Dog Ally → Dog Assist B → Antidote → Caltrop → Bridge → Goal
- 忙乱线：E02 未备齐鱼肉 / E03 失败后，Ninja 仍能继续到 E04；不能软锁。
- 狗协同：SEND_DOG 只能在 L08_DOG_ALLY 为 true 时生效。
