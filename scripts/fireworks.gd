extends AnimatedSprite2D

func trigger(offset):
	
	if offset % 10 == 1 or offset % 10 == 3 or offset % 10 == 6:
		var score = get_node("../HUD")
		
		visible = true
		play("default")
		await self.animation_finished
		await get_tree().create_timer(0.1).timeout
		visible = false
		score.score += 500
		score.update_score()
			
		if offset % 10 == 3 or offset % 10 == 6:
			var fireworks2 = get_node("../Fireworks2")
			fireworks2.visible = true
			fireworks2.play("default")
			
			await fireworks2.animation_finished
			await get_tree().create_timer(0.1).timeout
			fireworks2.visible = false
			score.score += 500
			score.update_score()
			
			var fireworks3 = get_node("../Fireworks3")
			fireworks3.visible = true
			fireworks3.play("default")
			await fireworks3.animation_finished
			await get_tree().create_timer(0.1).timeout
			fireworks3.visible = false
			score.score += 500
			score.update_score()
			
			if offset % 10 == 6:
				var fireworks4 = get_node("../Fireworks4")
				fireworks4.visible = true
				fireworks4.play("default")
				
				await fireworks4.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks4.visible = false
				score.score += 500
				score.update_score()
				var fireworks5 = get_node("../Fireworks5")
				fireworks5.visible = true
				fireworks5.play("default")
				await fireworks5.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks5.visible = false
				score.score += 500
				score.update_score()
				
				fireworks5.visible = false
				var fireworks6 = get_node("../Fireworks6")
				fireworks6.visible = true
				fireworks6.play("default")
				await fireworks6.animation_finished
				await get_tree().create_timer(0.1).timeout
				fireworks6.visible = false
				score.score += 500
				score.update_score()
