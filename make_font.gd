tool
extends EditorScript

export(String) var characters = "0123456789.KMG"
export(String) var path = "res://assets/digit_font.png"
export(String) var out_path = "res://assets/digits.tres"
export(int) var x0 = 0
export(int) var y0 = 0
export(int) var w = 28
export(int) var h = 35

func _run():
    var bf = BitmapFont.new()
    bf.add_texture(load(path))
    
    var x = x0
    var y = y0
    
    for c in characters.to_utf8():
        bf.add_char(c, 0, Rect2(x, y, w, h))
        x += w
    ResourceSaver.save(out_path, bf)
        
