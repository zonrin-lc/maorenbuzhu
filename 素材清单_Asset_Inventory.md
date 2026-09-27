# 《猫忍不住》可用素材清单（Ninja Adventure Asset Pack 全量盘点）

> 盘点日期：2026-09-27 ｜ 素材包路径：`Ninja Adventure - Asset Pack/`
> 标注说明：✓ = 已接入工程；⚠️ = 有缺口/待办；其余为可直接调用的库存。
> 设计约束：美术与音频严格限于本素材包（GDD §10），唯一缺口为猫叫声效（§9.3）。

---

## 1. 角色（Actor）

### 1.1 猫（玩家角色，5 皮肤）
| 素材路径 | 说明 | 状态 |
|---|---|---|
| `Actor/Animal/CatBlack/SpriteSheetYellow.png` | 黑猫（默认皮肤，黄领巾） | ✓ |
| `Actor/Animal/Cat/SpriteSheet.png` | 灰猫 | ✓ 已入工程，待接 Meta 解锁 |
| `Actor/Animal/CatOrange/SpriteSheet.png` | 橘猫（L04 解锁） | ✓ 同上 |
| `Actor/Animal/CatWhite/SpriteSheet.png` | 白猫（L08 解锁） | ✓ 同上 |
| `Actor/Animal/CatCyclop/SpriteSheet.png` | 独眼猫（Hard+ 解锁） | ✓ 同上 |

规格：16×16 双帧（idle/walk），左右靠 flip_h。各皮肤带 Faceset 头像。

### 1.2 忍者（NPC"主角"）
| 素材 | 说明 | 状态 |
|---|---|---|
| `Actor/Character/NinjaBlue/SpriteSheet.png` | 蓝忍者（64×112：4 方向 × 7 动作行） | ✓ |
| 同目录 `SeparateAnim/`（Idle/Walk/Attack/Jump/Dead/Item/Special×2） | 单动作分表，演出用 | 可用 |
| `NinjaRed / NinjaGreen / NinjaYellow / NinjaGray / NinjaDark / NinjaFire / NinjaThunder / NinjaWater / NinjaLeaf / NinjaEskimo / NinjaBomb / NinjaMasked / NinjaMageBlack / NinjaMageOrange / NinjaBlue2 / NinjaRed2 / RedNinja3` | 忍者人格变体（RC OPTIONAL，换"蠢法"） | 库存 18 款 |

### 1.3 守卫 / 武士
| 素材 | 说明 | 状态 |
|---|---|---|
| `Actor/Character/SamuraiRed` | 红武士（村庄守卫） | ✓ |
| `Actor/Character/SamuraiBlue` | 蓝武士（码头守卫） | ✓ |
| `Samurai / GladiatorBlue / RedGladiator / Knight / KnightGold` | 备用武士/骑士 | 库存 |

### 1.4 Boss
| 素材 | 说明 | 状态 |
|---|---|---|
| `Actor/Boss/GiantBlueSamurai`（Idle/Walk 12 帧 48×48 + Attack/Charge/Hit 左右分向） | 守门武士（L12） | ✓ |
| `GiantRedSamurai / TenguRed / TenguBlue / DragonBlue / DragonGreen / DemonCyclop×2 / GiantFrog×2 / GiantSlime×2 / GiantSpirit / GiantRacoon×2 / GiantBamboo×2 / GiantFlam / SquidGreen / SquidRed` | Boss 备选池 | 库存 18 款 |

### 1.5 动物
| 素材 | 说明 | 状态 |
|---|---|---|
| `Actor/Animal/Dog` | 恶狗（L05+） | ✓ |
| `Dog2 / DogBlack / DogOrange / DogYellow` | 狗换色 | 库存 |
| `Fish` | 游鱼（码头水景） | 库存 |
| `Pig / Chicken / Frog / Racoon / Monkey / Parrot / Horse / Cow / Donkey / Hyena / Lion 系 / WildBoar / Hamster` 等 | 村民动物/彩蛋 | 库存 26 种 |

### 1.6 村民 / 人形 NPC（居酒屋、背景）
- 老板娘指定：`Actor/Character/Woman`、`OldWoman`
- 其他：`OldMan×3`、`Villager×6`、`Village6`、`Boy`、`Child`、`Monk / Monk2`、`Master`、`Hunter`、`Inspector`、`Noble`、`Sultan×2`、`Shaman` 等 **60+ 款**，全部 4 方向 × 7 动作
- `Shadow.png`（通用影子）

---

## 2. 道具（Items）

| 类别 | 素材 | 状态/用途 |
|---|---|---|
| 事件机关 | `Object/CrateEmpty` ✓、`Projectile/CrateDynamite` ✓、`Projectile/Caltrop` ✓、`Potion/LifePot` ✓、`Food/Fish` ✓、`Object/Gourd` ✓、`Scroll/Scroll` ✓ | 11 类事件点全部接入 |
| 载具 | `Vehicles/FishNet` ✓（绊绳）、`Vehicles/Crane` ✓（Boss 吊车）、`Vehicles/Boat`、`Vehicles/Sail`、`FishNetFull` | Boat/Sail 可装饰码头 |
| 收集品 | `Treasure/GoldCoin / SilverCoin / Coin2 / BigTreasureChest / LittleTreasureChest / GoldKey / SilverKey / GoldCup / SilverCup`、`Resource/Gem×4 / Bar×6` | 鱼干外奖励备选 |
| 食物 | `Food/`：寿司、烤串、饭团、面条、茶、鱼、肉、蜂蜜等 22 款 | 居酒屋摆桌（§10 指定） |
| 药水 | `Potion/MilkPot / WaterPot / Heart / Medipack / EmptyPot` | 解毒药变体 |
| 工具 | `Tool/`：斧锤镐镰铲水壶铁砧 8 款 | 白盒装饰备选 |
| 资源 | `Resource/Branch / Rock / Grass / Water / feather` | 同上 |
| 武器 | `Weapons/` 24 套：Katana、Sai、Ninjaku、Bow、Rapier、Whip 等 | 武士/Boss 持械演出备选 |
| 其他 | `Other/Letter×3 / Stamp`（任务书信）、`Action/Interact.png / Hit.png`（交互提示） | 可用 |

---

## 3. 背景与地形（Backgrounds）

### 3.1 地块图集（16px 网格）
| 素材 | 状态/用途 |
|---|---|
| `TilesetField.png` | ✓ 村庄草地（已裁纯绿填充块） |
| `TilesetFloor.png` | ✓ 码头泥土 / 城堡石板（雪地调暗） |
| `TilesetNature.png` | ✓ 树木/灌木/花草/岩石装饰层 |
| `TilesetHouse.png` | ✓ 村庄民居/道场 |
| `TilesetWater.png` | 水面 |
| `TilesetRelief.png / TilesetHole.png` | 悬崖/断桥（§4.3 指定） |
| `TilesetVillageAbandoned.png` | 荒废村庄（备选风格） |
| `TilesetDungeon.png` | 道具（雕像/火炬/宝箱） |
| `TilesetTowers.png` | 城堡塔楼（第三章外观升级备选） |
| `TilesetDesert / TilesetElement / TilesetFloorB / TilesetFloorDetail / TilesetLogic / Pipes / tileset_bed / tileset_camp` | 库存 |

### 3.2 室内（居酒屋结算场景）
`Interior/TilesetInterior.png`、`TilesetInteriorFloor.png`、`TilesetWallSimple.png`、`Elements.png`（桌椅家具）——结算演出素材齐备。

### 3.3 动画装饰（序列帧）
| 素材 | 状态/用途 |
|---|---|
| `Animated/Water Ripples` | ✓ 码头水面涟漪（4 帧） |
| `Animated/Flower / Plant` | 村庄花草动画备选 |
| `Animated/Waterfall` | 水景 |
| `Animated/Flag` | 旗帜（城堡/码头地标） |
| `Animated/WaterMill + MillPropeller` | 水车（村庄地标） |
| `Animated/QuickSand` | 流沙染紫 = 毒沼泽（§4.4 指定） |
| `Animated/Conveyor Belt` | 传送带（码头备选机关） |

---

## 4. 特效（FX）

| 类别 | 素材 | 状态/用途 |
|---|---|---|
| 攻击 | `Attack/Claw / ClawDouble`（猫爪，§4.7 指定）、`Slash / SlashCurved / SlashDoubleCurved / Cut / CutDouble / CutX / CircularSlash` | 待接事件成功/拍飞反馈 |
| 元素 | `Elemental/Explosion`（炸药桶 §4.6）、`Thunder`（雷雨夜 §6.3）、`Water / WaterPillar / Ice / Flam / Plant / Rock / RockSpike` | 待接 |
| 魔法 | `Magic/Aura / Shield / Spark`（引线火花 §4.6）`/ Circle / Spirit / Boost` | 待接 |
| 环境 | `Environment/Fog`（毒雾染绿 §4.4）、`Particle/`（雨/雪/落叶/光柱）、`Smoke / SmokeCircular`（声响/气浪） | 待接 |
| 投射物 | `Projectile/Kunai / Shuriken` | 库存 |

---

## 5. UI（Ui）

| 素材 | 状态/用途 |
|---|---|
| `Arrow.png` | ✓ 忍者方向箭头（NinjaLocator） |
| `Emote/emote1~30.png` | 情绪气泡 30 款——忍者情绪状态机（§3.2）指定，⚠️ 待接入 |
| `Input/Keyboard` + `Input/Gamepad` + `Input/Mouse` | 按键图标全套（InputDisplay 动态绑定提示用） |
| `Dialog/DialogBox*.png` | 对话框（结算吹牛/台词） |
| `Receptacle/`（方/圆容器条） | 体力条 |
| `Font/NormalFont.ttf` | 像素字体（建议统一全局字体） |
| `Skill Icon/`（Items&Weapon / Job&Action / Meteo / Spell） | 图标 100+ |
| `Theme/Theme Wood` + `Wip/` 10 套备选主题 | 木质主题适合居酒屋 |

---

## 6. 音频（Audio）

### 6.1 音乐（41 首，`Musics/`）
| 曲目 | 状态/用途 |
|---|---|
| `23 - Road` | ✓ 第一章村庄 |
| `26 - Lost Village` | ✓ 村庄紧张层 |
| `18 - Aquatic` | ✓ 第二章码头 |
| `10 - Dark Castle` | ✓ 第三章天守阁 |
| `28 - Tension` | ✓ Boss |
| `20 - Good Time` | ✓ 居酒屋结算 |
| `27 - Chill` | 结算备选 |
| `17 - Fight / 24 - Final Area / 30 - Ruins / 14 - Curse` 等 35 首 | 库存 |

### 6.2 音效（132 个 wav，`Sounds/`）
| 类别 | 状态/用途 |
|---|---|
| ✓ `Jingles/Success1`（事件成功）、`GameOver`（失败）、`Secret1`（读图）、`Secret2`（卖萌） | 已接入 |
| `Jingles/LevelUp1~3 / Success2~4 / Secret3~4 / GameOver2~4` | 评分递进（§9.2） |
| `Sounds/Voice/Voice1~10` | 忍者语气音（§9.2，待接） |
| `Sounds/Creature/Dog` | ✓ 狗叫 |
| `Sounds/Bonus/PowerUp1` | **得手签名音**（§9.2 品牌识别点，待接） |
| `Sounds/Bonus/Bonus` | 自我消解"恍然大悟"音（§9.2） |
| `Sounds/Hit & Impact / Alert / Whoosh & Slash / Jump & Bounce / Magic & Skill / Menu / Ambient / Elemental` | 扣血/警报/挥砍/跳跃/菜单/雷雨氛围等 |

### 6.3 缺口
⚠️ **猫叫声效**（F 喵叫）——包内无猫叫，方向已定"外部原创"（GDD §9.3 / §15.1-4）。

---

## 7. 当前接入度

| 类别 | 已接入 | 库存待接 |
|---|---|---|
| 角色 | 猫 5 皮肤 / 忍者 / 武士×2 / 狗 / Boss | 忍者变体 18、Boss 备选 18、NPC 60+、动物 25 |
| 道具 | 11 类事件机关 | 收集/食物/工具/武器等 80+ |
| 地块 | 5 张图集 | 12 张图集 |
| 动画装饰 | 水面涟漪 | 瀑布/旗帜/水车/花草/流沙等 8 类 |
| 特效 | 未接 | 30+ 类 |
| UI | 箭头 | 情绪气泡/对话框/字体/按键图标/主题 |
| 音频 | 6 曲 + 5 音效 | 35 曲 + 127 音效 |

**性价比最高的下一批**（与 GDD 品牌识别点对应）：
1. `Ui/Emote` 情绪气泡 → 忍者情绪状态机（§3.2，喜剧表现核心）
2. `Interior` + 食物 + 老板娘 → 居酒屋结算场景（§7，招牌画面）
3. `Bonus/PowerUp1` 得手签名音 + `Voice1~10` 忍者语气音（§9.2，声音记忆点）
