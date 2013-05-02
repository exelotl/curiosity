import math/Random
import vamos/[Engine, Entity, Input, Component, Signal]
import vamos/graphics/[FilledRect, Anim]
import vamos/masks/Hitbox
import vamos/comps/[Physics, Timer]
import Level, Global, Particles

FreePlayer: class extends Entity {
	
	box:Hitbox
	rect: FilledRect
	physics:Physics
	falling := false
	finished := false
	
	init: func {
		rect = FilledRect new(10, 10, 0,0,0) .center()
		graphic = rect
		box = Hitbox new(10, 10) .center()
		mask = box
		type = "player"
		
		physics = Physics new(TYPES_SOLID)
		physics maxVelX = 200
		physics maxVelY = 200
		physics dragX = 1000
		physics dragY = 1000
		add(physics)
		
		add(Timer new~start(10, ||
			falling = true
			physics accX = 0
			physics accY = 100
			physics maxVelY = 1000
		))
		
		layer = Layers player
	}
	
	update: func (dt:Double) {
		if (falling) {
			if (physics velY > 999) {
				(scene as Level) end()
				add(Timer new~start(2, ||
					vamos scene = Scenes level1
				))
			}
		} else {
			if (Input pressed("right")) physics accX = 1000
			if (Input pressed("left")) physics accX = -1000
			if (Input released("left") || Input released("right")) physics accX = 0
			if (Input pressed("up")) physics accY = -1000
			if (Input pressed("down")) physics accY = 1000
			if (Input released("up") || Input released("down")) physics accY = 0
		}
	}
}

ANIM_WAKING := [1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,2,2,2,2,2,2,2,2,2,2,2,3,3,3,4,4,5,5,5,5,5,5,5,5,5,5,5,3,3,5,5,5,6,6,7,7,7]
ANIM_RUN_R := [9,8,10]
ANIM_RUN_L := [12,11,13]
ANIM_IDLE_R := [8]
ANIM_IDLE_L := [11]
ANIM_JUMP_R := [9]
ANIM_JUMP_L := [12]

WakingPlayer: class extends Entity {
	anim: Anim
	
	init: func {
		anim = Anim new("player.png", 14, 14) .center()
		anim play(ANIM_WAKING, 10).once()
		y += 3
		graphic = anim
		type = "player"
		layer = Layers player
		add(Timer new~start(ANIM_WAKING length / 10, ||
			scene remove(this)
			p := Player new()
			p x = x
			p y = y
			scene add(p)
		))
	}
}

Player: class extends Entity {
	
	anim: Anim
	box:Hitbox
	physics:Physics
	
	facing := 'r'
	spawnX, spawnY: Double
	
	canWin := false
	
	onRespawn := VoidSignal new()
	
	init: func {
		"PLAYER" println()
		anim = Anim new("player.png", 14, 14) .center()
		anim frame = 7
		graphic = anim
		box = Hitbox new(10, 10) .center()
		box y += 2
		mask = box
		type = "player"
		
		physics = Physics new(TYPES_SOLID)
		physics accY = 780
		physics dragX = 2000
		physics maxVelX = 180
		physics maxVelY = 800
		add(physics)
		
		layer = Layers player
	}
	
	update: func (dt:Double) {
		
		inAir := collide(TYPES_SOLID, x, y+1) == null
		
		if (Input pressed("left") || (Input released("right") && Input held("left"))) run('l')
		else if (Input pressed("right") || (Input released("left") && Input held("right"))) run('r')
		else if (Input released("left") || Input released("right")) idle()
		
		if (inAir) {
			anim play(facing=='l' ? ANIM_JUMP_L : ANIM_JUMP_R, 20) .once()
		} else {
			if (Input pressed("up")) jump()
			if (physics accX == 0)
				anim play(facing=='l' ? ANIM_IDLE_L : ANIM_IDLE_R, 20)
			else anim play(facing=='l' ? ANIM_RUN_L : ANIM_RUN_R, 20)
		}
		
		if (x > 5950 && y < 1670)
			canWin = true
		if (y > 3000 && canWin && type == "player") {
			scene as Level end()
		}
	}
	
	idle: func {
		physics accX = 0
	}
	run: func (dir:Char) {
		facing = dir
		match dir {
			case 'l' => physics accX = -2000
			case 'r' => physics accX = 2000
		}
	}
	jump: func {
		physics velY = -200
	}
	die: func {
		type = ""
		graphic = null
		mask = null
		for (i in 0..10)
			scene add(PlayerDebris new(x, y))
		for (i in 0..10) {
			p := RectParticle new(x, y, "particle1.png", 1, 100, Random randInt(0, 360))
			p add(Timer new~start(5, || scene remove(p)))
			scene add(p)
		}
		
		physics active = false
		add(Timer new~start(3, || respawn()))
	}
	
	respawn: func {
		x = spawnX
		y = spawnY
		graphic = anim
		mask = box
		type = "player"
		physics active = true
		onRespawn dispatch()
	}
	
	setSpawn: func (=spawnX, =spawnY)
}

