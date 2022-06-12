extends Combatant

func set_active(value):
	.set_active(value)
	if not active:
		return

	if not $Timer.is_inside_tree():
		return
	$Timer.start()
	yield($Timer, "timeout")
	var target
	for actor in get_parent().get_children():
		if not actor == self:
			target = actor
			break
	attack(target)
