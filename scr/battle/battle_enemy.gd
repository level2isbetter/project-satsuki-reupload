extends TextureButton

@export var enemy_type: String = "placeholder"

var data: BattleActor = null
var _hit_reaction_tween: Tween = null
var _base_position: Vector2
@onready var _atb_bar: ATBBar = $ATBBar
@onready var _hp_bar: TextureProgressBar = $EnemyHP

const HIT_SHAKE_DISTANCE: float = 10.0
const HIT_SHAKE_TIME: float = 0.035
const HIT_FLASH_TIME: float = 0.05
const HIT_FLASH_COLOR: Color = Color(1.7, 0.65, 0.65, 1.0)

func _ready() -> void:
	# Create the enemy data
	var enemy_factory = Enemies.new()
	data = enemy_factory.create_enemy(enemy_type)
	_base_position = position
	
	# connect to died signal
	data.died.connect(_on_enemy_died)
	
	# connect ATB bar filled signal
	if _atb_bar:
		_atb_bar.filled.connect(_on_atb_bar_filled)
		
	# connect hp bar
	

func take_damage(damage: int) -> int:
	var actual_damage = 0
	if data:
		actual_damage = data.take_damage(damage)
		if actual_damage > 0 and data.hp > 0:
			play_hit_reaction()
		_update_hp_display()
	return actual_damage

func play_hit_reaction() -> void:
	if not is_inside_tree():
		return
		
	Globals.play_sfx(preload("res://aud/sfx/battle/hit.ogg"), 1)

	if is_instance_valid(_hit_reaction_tween):
		_hit_reaction_tween.kill()

	position = _base_position
	modulate = Color.WHITE

	_hit_reaction_tween = create_tween()
	_hit_reaction_tween.tween_property(self, "modulate", HIT_FLASH_COLOR, HIT_FLASH_TIME)
	_hit_reaction_tween.parallel().tween_property(self, "position", _base_position + Vector2(-HIT_SHAKE_DISTANCE, 0), HIT_SHAKE_TIME)
	_hit_reaction_tween.tween_property(self, "position", _base_position + Vector2(HIT_SHAKE_DISTANCE, 0), HIT_SHAKE_TIME)
	_hit_reaction_tween.parallel().tween_property(self, "modulate", Color.WHITE, HIT_FLASH_TIME)
	_hit_reaction_tween.tween_property(self, "position", _base_position, HIT_SHAKE_TIME)

func _update_hp_display() -> void:
	if _hp_bar and data:
		_hp_bar.max_value = data.maxHP
		_hp_bar.value = data.hp

func _on_enemy_died() -> void:
	Globals.play_sfx(preload("res://aud/sfx/battle/fade.ogg"))
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_atb_bar_filled() -> void:
	if data and is_instance_valid(self):
		var battle = get_tree().get_first_node_in_group("battle")
		if battle:
			battle.enemy_attack(self)
		
		# Reset ATB
		if _atb_bar:
			_atb_bar.reset()
