class_name BattleQueue extends RefCounted

static func render_slots(queue_slots: Array, upcoming_turns: Array, player_icon: Texture2D, enemy_icon: Texture2D) -> void:
	for i in range(queue_slots.size()):
		var slot: TextureRect = queue_slots[i]
		if i < upcoming_turns.size():
			var turn_data = upcoming_turns[i]
			slot.texture = player_icon if turn_data.get("is_player", false) else enemy_icon
			slot.modulate = Color.WHITE
		else:
			slot.texture = null
			slot.modulate = Color(1, 1, 1, 0.3)

static func calculate_turn_order(current_player, alive_enemies: Array, player_actor, count: int = 3) -> Array:
	var actors: Array = []
	const ATB_SPEED: float = 0.25

	if current_player and current_player.has_node("ATBBar"):
		var player_atb: TextureProgressBar = current_player.get_node("ATBBar")
		var player_time_to_ready: float = (player_atb.max_value - player_atb.value) / ATB_SPEED
		actors.append({
			"is_player": true,
			"time_to_ready": max(0.0, player_time_to_ready),
			"refill_time": player_atb.max_value / ATB_SPEED,
			"id": "player"
		})

	var enemy_index: int = 0
	for enemy in alive_enemies:
		if enemy.has_node("ATBBar"):
			var enemy_atb: TextureProgressBar = enemy.get_node("ATBBar")
			var enemy_time_to_ready: float = (enemy_atb.max_value - enemy_atb.value) / ATB_SPEED
			actors.append({
				"is_player": false,
				"time_to_ready": max(0.0, enemy_time_to_ready),
				"refill_time": enemy_atb.max_value / ATB_SPEED,
				"id": "enemy_" + str(enemy_index)
			})
			enemy_index += 1

	var turn_order: Array = []
	var simulated_time: float = 0.0
	var max_simulation_time: float = 100000.0
	var player_actions_remaining: int = player_actor.action_queue.size() if player_actor else 0

	while turn_order.size() < count and simulated_time < max_simulation_time:
		if actors.is_empty():
			break

		var next_actor = null
		var min_time: float = INF
		for actor in actors:
			if actor["time_to_ready"] < min_time:
				min_time = actor["time_to_ready"]
				next_actor = actor

		if next_actor == null:
			break

		simulated_time += min_time
		for actor in actors:
			actor["time_to_ready"] -= min_time

		if next_actor["is_player"]:
			turn_order.append({"is_player": true})
			if player_actions_remaining > 0:
				player_actions_remaining -= 1
		else:
			turn_order.append({"is_player": false})

		next_actor["time_to_ready"] = next_actor["refill_time"]

	return turn_order
