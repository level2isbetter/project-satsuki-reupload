class_name BattleActor extends Resource

signal hp_changed(hp, change)
signal died()
signal action_queue_full()
signal action_queued(queue_size, max_size)
signal action_queue_changed(queue_size, max_size)

# placeholder stats (globals changes most of these)
var name: String = "Reimu Hakurei"
var maxHP: int = 1
var hp: int = maxHP
var atk: int = 10
var def: int = 5

# DEF button stuff
var is_defending: bool = false
var defense_reduction: float = 0.5  # 50% damage reduction when defending

# queue system
var action_queue: Array = []
const MAX_QUEUE_SIZE: int = 3

func healhurt(value: int) -> void:
	var start: int = hp
	var change: int = 0
	hp += value
	hp = clampi(hp, 0, maxHP)
	change = start - hp
	emit_signal("hp_changed", hp, change)
	
	if hp <= 0:
		emit_signal("died")

func take_damage(damage: int) -> int:
	var final_damage = damage
	if is_defending:
		final_damage = int(damage * (1.0 - defense_reduction))
		final_damage = max(1, final_damage)  # Minimum 1 damage
	healhurt(-final_damage)
	return final_damage

func calculate_damage(target: BattleActor) -> int:
	# attacker's ATK - target's DEF
	# min damage is 1
	var damage = max(1, atk - target.def)
	return damage

func start_defending() -> void:
	is_defending = true

func end_defending() -> void:
	is_defending = false

func queue_action(action_type: String, target = null) -> bool:
	# action to queue if not full
	if action_queue.size() >= MAX_QUEUE_SIZE:
		action_queue_full.emit()
		return false
	
	var action = {
		"type": action_type,
		"target": target
	}
	action_queue.append(action)
	action_queued.emit(action_queue.size(), MAX_QUEUE_SIZE)
	action_queue_changed.emit(action_queue.size(), MAX_QUEUE_SIZE)
	return true

func has_queued_actions() -> bool:
	return action_queue.size() > 0

func pop_action() -> Dictionary:
	# get and remove the first action from queue
	if action_queue.size() > 0:
		var action = action_queue.pop_front()
		action_queue_changed.emit(action_queue.size(), MAX_QUEUE_SIZE)
		return action
	return {}

func clear_queue() -> void:
	action_queue.clear()
	action_queue_changed.emit(action_queue.size(), MAX_QUEUE_SIZE)
