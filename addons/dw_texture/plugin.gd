tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("DwTexture", "TextureRect", preload("res://addons/dw_texture/dw_texture.gd"), preload("DwTexture.svg"))
	pass


func _exit_tree():
	remove_custom_type("DwTexture")
	pass
