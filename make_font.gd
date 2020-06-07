tool
extends EditorScript

export(String) var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?.,-+$ "
export(String) var path = "res://assets/font.png"
export(String) var out_path = "res://assets/font.tres"
export(int) var x0 = 0
export(int) var y0 = 0
export(int) var w = 24
export(int) var h = 35

func _run():
    var bf = BitmapFont.new()
    var texture = load(path)
    var texture_width = texture.get_width()
    bf.add_texture(texture)
    
    var x = x0
    var y = y0
    
    for c in characters.to_utf8():
        bf.add_char(c, 0, Rect2(x, y, w, h))
        x += w
        if x >= texture_width:
            x = 0
            y += h
    ResourceSaver.save(out_path, bf)
        
