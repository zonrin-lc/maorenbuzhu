extends RefCounted
class_name LayoutBookManifest

const PAGE_SIZE := Vector2i(1600, 1000)
const SCENE_SIZE := Vector2(1100.0, 680.0)
const MAP_RECT := Rect2(286, 150, 990, 612)

const LEVELS := {
    "L01": {
        "chapter": "CH01", "chapter_title": "第一章·村口风云", "display_name": "第一份差事",
        "target_time": "90s–120s", "objective": "基础移动 / 提前跑位",
        "scene": "res://scenes/levels/ch01_village/L01_first_job.tscn"
    },
    "L02": {
        "chapter": "CH01", "chapter_title": "第一章·村口风云", "display_name": "他总是踩同一个坑",
        "target_time": "90s–120s", "objective": "提前赶场 / 引开守卫",
        "scene": "res://scenes/levels/ch01_village/L02_same_old_trap.tscn"
    },
    "L03": {
        "chapter": "CH01", "chapter_title": "第一章·村口风云", "display_name": "谁在看猫",
        "target_time": "90s–120s", "objective": "视线 / 怀疑管理",
        "scene": "res://scenes/levels/ch01_village/L03_who_is_watching.tscn"
    },
    "L04": {
        "chapter": "CH01", "chapter_title": "第一章·村口风云", "display_name": "村口大事故",
        "target_time": "120s–150s", "objective": "顺序解谜 / 双路线",
        "scene": "res://scenes/levels/ch01_village/L04_village_accident.tscn"
    },
    "L05": {
        "chapter": "CH02", "chapter_title": "第二章·月下码头", "display_name": "月夜码头",
        "target_time": "90s–120s", "objective": "搬运鱼 / 铺桥",
        "scene": "res://scenes/levels/ch02_dock/L05_moonlit_dock.tscn"
    },
    "L06": {
        "chapter": "CH02", "chapter_title": "第二章·月下码头", "display_name": "狗也能当队友",
        "target_time": "90s–120s", "objective": "狗的利用 / NPC 联动",
        "scene": "res://scenes/levels/ch02_dock/L06_dog_ally.tscn"
    },
    "L07": {
        "chapter": "CH02", "chapter_title": "第二章·月下码头", "display_name": "谁先走",
        "target_time": "120s–150s", "objective": "因果链 / 调度",
        "scene": "res://scenes/levels/ch02_dock/L07_who_goes_first.tscn"
    },
    "L08": {
        "chapter": "CH02", "chapter_title": "第二章·月下码头", "display_name": "最后一班船",
        "target_time": "120s–150s", "objective": "资源冲突 / 多线程",
        "scene": "res://scenes/levels/ch02_dock/L08_last_boat.tscn"
    },
    "L09": {
        "chapter": "CH03", "chapter_title": "第三章·天守阁", "display_name": "雷雨夜",
        "target_time": "120s–150s", "objective": "环境压力 / 潜行",
        "scene": "res://scenes/levels/ch03_castle/L09_storm_night.tscn"
    },
    "L10": {
        "chapter": "CH03", "chapter_title": "第三章·天守阁", "display_name": "炸药不能乱碰",
        "target_time": "120s–150s", "objective": "连锁事故 / 预判",
        "scene": "res://scenes/levels/ch03_castle/L10_dont_touch_dynamite.tscn"
    },
    "L11": {
        "chapter": "CH03", "chapter_title": "第三章·天守阁", "display_name": "越靠近城门越忙",
        "target_time": "150s–180s", "objective": "三线程并行 / 赶场",
        "scene": "res://scenes/levels/ch03_castle/L11_busy_gate.tscn"
    },
    "L12": {
        "chapter": "CH03", "chapter_title": "第三章·天守阁", "display_name": "守门武士",
        "target_time": "180s–240s", "objective": "Boss 战 / 战中补救",
        "scene": "res://scenes/levels/ch03_castle/L12_gatekeeper_boss.tscn"
    }
}

# Visual-only design alternates. They document the intended fallback line
# without changing Ninja's real fixed RouteData.
const BACKUP_ROUTES := {
    "L01": [Vector2(110,500), Vector2(190,330), Vector2(350,320), Vector2(520,220), Vector2(760,260), Vector2(980,390)],
    "L02": [Vector2(140,340), Vector2(230,500), Vector2(430,500), Vector2(500,320), Vector2(720,300), Vector2(990,420)],
    "L03": [Vector2(140,300), Vector2(280,500), Vector2(420,500), Vector2(585,410), Vector2(720,300), Vector2(990,420)],
    "L04": [Vector2(140,340), Vector2(250,270), Vector2(420,270), Vector2(520,420), Vector2(760,500), Vector2(980,460)],
    "L05": [Vector2(110,500), Vector2(210,470), Vector2(340,480), Vector2(470,315), Vector2(650,300), Vector2(860,540), Vector2(1010,320)],
    "L06": [Vector2(110,500), Vector2(230,500), Vector2(430,435), Vector2(560,300), Vector2(760,330), Vector2(990,320)],
    "L07": [Vector2(110,480), Vector2(260,500), Vector2(430,487), Vector2(625,410), Vector2(760,280), Vector2(1000,350)],
    "L08": [Vector2(100,500), Vector2(250,530), Vector2(420,430), Vector2(600,300), Vector2(820,350), Vector2(960,320)],
    "L09": [Vector2(110,540), Vector2(260,430), Vector2(430,240), Vector2(650,300), Vector2(760,410), Vector2(940,300)],
    "L10": [Vector2(110,540), Vector2(270,430), Vector2(500,520), Vector2(700,410), Vector2(820,260), Vector2(980,260)],
    "L11": [Vector2(100,540), Vector2(280,500), Vector2(500,450), Vector2(760,350), Vector2(860,180), Vector2(1000,250)],
    "L12": [Vector2(110,540), Vector2(300,540), Vector2(500,330), Vector2(700,400), Vector2(850,300), Vector2(990,250)]
}

# Mirrors the shortcut placements already wired in the gameplay manager.
# L05/L09/L12 intentionally remain design-only in this pass; the renderer
# marks them as planned so the image does not falsely claim runtime support.
const SHORTCUTS := {
    "L01": [[Vector2(270,430), Vector2(330,360)]],
    "L02": [[Vector2(230,500), Vector2(420,500)], [Vector2(455,500), Vector2(500,320)]],
    "L03": [[Vector2(609,488), Vector2(609,368)]],
    "L04": [[Vector2(448,502), Vector2(627,502)]],
    "L05": [[Vector2(430,530), Vector2(575,530)]],
    "L06": [[Vector2(432,437), Vector2(523,437)]],
    "L07": [[Vector2(430,487), Vector2(625,487)]],
    "L08": [[Vector2(250,530), Vector2(520,410)]],
    "L09": [[Vector2(420,540), Vector2(610,540)]],
    "L10": [[Vector2(330,300), Vector2(700,410)]],
    "L11": [[Vector2(470,500), Vector2(760,350)]],
    "L12": [[Vector2(520,500), Vector2(700,380)]]
}

static func get_meta(level_id: String) -> Dictionary:
    return LEVELS.get(level_id, {})

static func chapter(level_id: String) -> String:
    return String(get_meta(level_id).get("chapter", ""))

static func scene_path(level_id: String) -> String:
    return String(get_meta(level_id).get("scene", ""))

static func backup(level_id: String) -> Array:
    return BACKUP_ROUTES.get(level_id, [])

static func shortcuts(level_id: String) -> Array:
    return SHORTCUTS.get(level_id, [])
