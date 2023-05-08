#class_name DwTexture, "DwTexture.svg"
extends TextureRect

signal texture_loaded(errno)

const GROUP_NAME = "res://addons/dw_texture/dw_texture.gd"

enum ErrorEnum {
	SUCCESS=0,
	ERROR=1
}

var active := false

export var download_url:String setget set_download_url  # https://example.com/xxx.png
export var auto_download:bool = true setget set_auto_download
export var max_connections:int = 3 setget set_max_connections
export var use_cache:bool = true setget set_use_cache
export var cache_path:String setget set_cache_path  # user://caches/%s

onready var HttpNode:HTTPRequest

#
#
#
func _ready():
	if auto_download:
		load_texture()


#
#
#
func _process(delta):
	if active:
		_check_status()

#
#
#
func load_texture():
	
	if use_cache:
		if cache_path:
			var dir := Directory.new()
			var dirpath = cache_path.get_base_dir()
			if dir.dir_exists(dirpath) == false:
				dir.make_dir_recursive(dirpath)
			
			var file := File.new()
			if file.file_exists(cache_path):
				load_cache_image()
				active = false
				return
	
	if download_url:
		if HttpNode == null:
			HttpNode = HTTPRequest.new()
			HttpNode.connect("request_completed", self, "_on_request_completed")
			self.add_child(HttpNode)
			HttpNode.add_to_group(GROUP_NAME)
		active = true

#
#
#
func _check_status():
	
	if use_cache:
		var file := File.new()
		if file.file_exists(cache_path):
			load_cache_image()
			active = false
			return
	
	var active_status_count = 0
	if HttpNode.get_http_client_status() == 0:
		for node in get_tree().get_nodes_in_group(GROUP_NAME):
			if node.get_http_client_status() > 0:
				active_status_count = active_status_count + 1
		
		if active_status_count < max_connections:
			active = false
			HttpNode.request(download_url)

#
#
#
func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error retrieving image")
		emit_signal("texture_loaded", ErrorEnum.ERROR)
		return
	create_image(body)
	emit_signal("texture_loaded", ErrorEnum.SUCCESS)
	
#
#
#
func create_image(body):
	var image = Image.new()
	image.load_png_from_buffer(body)
	
	if use_cache and cache_path:
		image.save_png(cache_path)	
	
	return create_texture(image)

#
#
#
func load_cache_image():
	var image = Image.new()
	image.load(cache_path)
	return create_texture(image)

#
#
#
func create_texture(image:Image):
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	set_texture(texture)
	emit_signal("texture_loaded", ErrorEnum.SUCCESS)
	return texture

#
#
#
func set_download_url(url):
	download_url = url
	return self

#
#
#
func set_cache_path(file_name):
	cache_path = file_name
	return self

#
#
#
func set_auto_download(val:bool):
	auto_download = val
	return self

#
#
#
func set_max_connections(val:int):
	max_connections = val
	return self

#
#
#
func set_use_cache(val:bool):
	use_cache = val
	return self
#
#
#
func remove_cache_file():
	var file := File.new()
	if file.file_exists(cache_path):
		var dir = Directory.new()
		dir.remove(cache_path)
	return self
