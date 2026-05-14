extends GutTest

# unit test for damage and defending damage
func test_damage_and_defense():
	var actor = BattleActor.new()
	actor.maxHP = 100
	actor.hp = 100
	actor.defense_reduction = 0.5
	
	var normal_damage = actor.take_damage(20)
	assert_eq(normal_damage, 20, "Normal Damage Mismatch")
	assert_eq(actor.hp, 80, "HP after normal hit mismatch")
	
	actor.start_defending()
	var defending_damage = actor.take_damage(20)
	assert_eq(defending_damage, 10, "Defending damage reduction mismatch")
	assert_eq(actor.hp, 70, "HP after defending hit mismatch")
	
# died unit test
func test_actor_died():
	var actor = BattleActor.new()
	actor.maxHP = 10
	actor.hp = 10

	watch_signals(actor)
	
	actor.healhurt(-10)
	
	assert_signal_emitted(actor, "died", "died signal should emit when hp is 0")
	assert_eq(actor.hp, 0, "HP clamp to 0 on lethal damage")

# spell unit test
func test_battle_spell_lookup():
	var fire = BattleSpells.get_spell("FIRE")
	var unknown = BattleSpells.get_spell("not_real_spell")
	
	assert_eq(fire["name"], "Fire", "Spell name mismatch")
	assert_eq(fire["cost"], 7, "Spell cost mismatch")
	assert_eq(fire["damage"], 60, "Spell damage mismatch")
	
	assert_eq(unknown, {}, "Unknown spells should return an empty dict")

# action queue limit + fifo stuff test
func test_battle_action_queue():
	var actor = BattleActor.new()

	assert_true(actor.queue_action("ATK", "enemy_a"), "First queue action failed")
	assert_true(actor.queue_action("DEF"), "Second queue action failed")
	assert_true(actor.queue_action("SPL", "fire"), "Third queue action failed")

	var over_limit = actor.queue_action("ATK", "enemy_b")
	assert_false(over_limit, "Queue should reject actions beyond MAX_QUEUE_SIZE")

	var first = actor.pop_action()
	var second = actor.pop_action()
	var third = actor.pop_action()
	var empty = actor.pop_action()

	assert_eq(first["type"], "ATK", "Queue order mismatch (1st action)")
	assert_eq(second["type"], "DEF", "Queue order mismatch (2nd action)")
	assert_eq(third["type"], "SPL", "Queue order mismatch (3rd action)")
	assert_eq(empty, {}, "Popping empty queue should return empty Dictionary")

# damage formula check (might sound redundant? similar to test 1, not really tho)
func test_battle_calculate_damage():
	var attacker = BattleActor.new()
	var tank_target = BattleActor.new()
	var normal_target = BattleActor.new()

	attacker.atk = 5
	tank_target.def = 20

	var min_damage = attacker.calculate_damage(tank_target)
	assert_eq(min_damage, 1, "Damage should have minimum of 1")

	attacker.atk = 20
	normal_target.def = 5

	var normal_damage = attacker.calculate_damage(normal_target)
	assert_eq(normal_damage, 15, "Normal damage formula mismatch")
