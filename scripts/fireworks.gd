extends AnimatedSprite2D

func trigger(offset):
	
	if offset % 10 == 1 or offset % 10 == 3 or offset % 10 == 6:
		var score = get_node("../../HUD")
		var sound = get_node("../../Animation Sounds")
		
		visible = true
		play("default")
		await self.animation_finished
		await get_tree().create_timer(0.1).timeout
		visible = false
		score.score += 500
		score.update_score()
		display_points(global_position)
			
		if offset % 10 == 3 or offset % 10 == 6:
			var fireworks2 = get_node("../Fireworks/Fireworks2")
			fireworks2.visible = true
			fireworks2.play("default")
			sound.stream = load("res://sounds/smb_fireworks.wav")
			sound.playing = true
			
			await fireworks2.animation_finished
			await get_tree().create_timer(0.1).timeout
			fireworks2.visible = false
			score.score += 500
			score.update_score()
			display_points(fireworks2.global_position)
			
			var fireworks3 = get_node("../Fireworks/Fireworks3")
			fireworks3.visible = true
			fireworks3.play("default")
			sound.stream = load("res://sounds/smb_fireworks.wav")
			sound.playing = true
			await fireworks3.animation_finished
			await get_tree().create_timer(0.1).timeout
			fireworks3.visible = false
			score.score += 500
			score.update_score()
			display_points(fireworks3.global_position)
			
			if offset % 10 == 6:
				var fireworks4 = get_node("../Fireworks/Fireworks4")
				fireworks4.visible = true
				fireworks4.play("default")
				sound.stream = load("res://sounds/smb_fireworks.wav")
				sound.playing = true
				await fireworks4.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks4.visible = false
				score.score += 500
				score.update_score()
				display_points(fireworks4.global_position)
				
				var fireworks5 = get_node("../Fireworks/Fireworks5")
				fireworks5.visible = true
				fireworks5.play("default")
				sound.stream = load("res://sounds/smb_fireworks.wav")
				sound.playing = true
				await fireworks5.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks5.visible = false
				score.score += 500
				score.update_score()
				display_points(fireworks5.global_position)
				
				fireworks5.visible = false
				var fireworks6 = get_node("../Fireworks/Fireworks6")
				fireworks6.visible = true
				fireworks6.play("default")
				sound.stream = load("res://sounds/smb_fireworks.wav")
				sound.playing = true
				await fireworks6.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks6.visible = false
				score.score += 500
				score.update_score()
				display_points(fireworks6.global_position)
				
func display_points(object_position):
	var points_label = preload("res://UI/points_label.tscn").instantiate()
	points_label.text = str(500)
	points_label.position = object_position + Vector2(10, 0)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
