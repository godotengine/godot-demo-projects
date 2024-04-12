extends Combatant


func set_active(value):
	super.set_active(value)
	if not active:
		return

	if not $Timer.is_inside_tree():
		return
	$Timer.start()
	await $Timer.timeout
	var target
	for actor in get_parent().get_children():
		if not actor == self:
			target = actor
			break
	attack(target)
