extends Node

func _ready():
	var f = File.new()
	f.open("res://CEconfig/config.json", File.READ)
	config = parse_json(f.get_as_text())
	f.close()

var autosave = true

var config
var data
var framesdata = []
var path
