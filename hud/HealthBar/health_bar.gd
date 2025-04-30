extends TextureProgressBar

@export var player:Angel;

func _ready() -> void:
	player.health_change.connect(update)
	update()

func update(): 
	value = player.health * 100 / player.max_health
