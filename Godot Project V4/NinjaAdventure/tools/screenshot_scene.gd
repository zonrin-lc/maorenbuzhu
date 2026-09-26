extends Node2D

# 工具场景：以正常模式（含 autoload）加载目标场景，运行若干帧后截图退出
# 用法：Godot --path . tools/screenshot_scene.tscn -- <scene_path> <out_png> [frames]

func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() < 2:
        push_error("usage: <scene_path> <out_png> [frames]")
        get_tree().quit()
        return
    var packed := load(args[0]) as PackedScene
    if packed == null:
        push_error("LOAD_FAIL " + args[0])
        get_tree().quit()
        return
    add_child(packed.instantiate())
    var frames := int(args[2]) if args.size() > 2 else 90
    for i in frames:
        await get_tree().process_frame
    await get_tree().process_frame
    var img := get_viewport().get_texture().get_image()
    if img:
        img.save_png(args[1])
        print("SCREENSHOT_SAVED")
    else:
        push_error("SCREENSHOT_FAIL")
    get_tree().quit()
