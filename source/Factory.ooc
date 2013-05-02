use mxml
import math/Random
import vamos/[Entity, Input, Util, Signal]
import vamos/display/Color
import vamos/graphics/[Image, RepeatImage, GraphicList, SpriteMap, Anim]
import vamos/masks/[Hitbox, MaskList]
import vamos/comps/[Timer, Tween, Physics]
import Player, Global, Particles

Factory: class {
	
	create: static func (data:XmlNode)  -> Entity {
		
		e: Entity
		
		data getElement() print()
		
		match (data getElement()) {
			case "free_player" => e = FreePlayer new()
			case "waking_player" => e = WakingPlayer new()
			case "player" => e = Player new()
			case "red_box_enemy" => e = RedBoxEnemy new(data)
			case "dirt_block" => e = DirtBlock new(data)
			case "seed" => e = Seed new(data)
			case "grapple" => e = Grapple new()
			case "portal_entrance" => e = PortalEntrance new(data)
			case "portal_exit" => e = PortalExit new(data)
			case "checkpoint" => e = Checkpoint new()
			case "atmosphere" => e = Atmosphere new(data)
			case "bug1" => e = Bug1 new()
			case "non_grapple" => e = NonGrapple new(data)
			case "fall_end" => e = FallEnd new(data)
			case "flower_detached" => e = FlowerDetached new()
		}
		
		if (e) {
			e x += data getAttr("x") toDouble()
			e y += data getAttr("y") toDouble()
			return e
		}
		null
	}
	
}



RedBoxEnemy: class extends Entity {
	box: Hitbox
	reactionBox: Hitbox
	image: Image
	
	mode: String
	deadly := true
	
	startX, startY: Double
	tremble: Double = 0
	spin: Double = 0
	stomping: Bool = false
	
	init: func (xml:XmlNode) {
		mode = xml getAttr("mode")
		startX = xml getAttr("x") toDouble()
		startY = xml getAttr("y") toDouble()
		
		image = Image new("red_box_enemy.png").center().assign(this)
		box = Hitbox new(10, 10).center().assign(this)
		type = "red_box_enemy"
		
		match mode {
			case "gate" =>
				image alpha = 0
				deadly = false
			case "spin" =>
				reactionBox = Hitbox new(10, 80).center()
			case "stomp" =>
				reactionBox = Hitbox new(2, 40, -1, -5)
		}
	}
	
	update: func (dt:Double) {
		
		match mode {
			case "tremble" =>
				if (collide("player", x, y-20))
					tremble = 1
				if (tremble > 0) {
					image x = Random randInt(-tremble*2, tremble*2)
					image y = Random randInt(-tremble, tremble)
					tremble -= dt
				}
			case "spin" =>
				mask = reactionBox
				if (collide("player")) spin = 1000
				mask = box
				
				if (spin > 0) {
					image angle += spin * dt
					spin -= dt*410
				} else if (image angle as Int % 90 != 0) {
					image angle += 5*dt
				}
			case "stomp" =>
				if (stomping) {
					y += dt*200
					if (collide("solid")) stomping = false
				} else {
					mask = reactionBox
					if (collide("player")) stomping = true
					mask = box
					
					if (y != startY) {
						y -= (y-startY) sign() * 60 * dt
						if ((y-startY) abs() < 1) y = startY
					}
				}
			case "falling" =>
				y += dt*140
				if (collide("fall_end"))
					y -= 480
		}
		
		p := collide("player") as Player
		
		if (p) {
			if (deadly) {
				p die()
			} else match mode {
				case "gate" =>
					mode = "idle"
					add(Tween new~start(1, |n|
						image alpha = n*255
					) then(|| deadly = true))
			}
		}
	}
}



DirtBlock: class extends Entity {
	box: Hitbox
	sprite: SpriteMap
	hidden: Bool
	grown: Bool
	
	init: func (xml:XmlNode) {
		hidden = xml getAttr("hidden") == "True"
		sprite = SpriteMap new("dirt_block.png", 20, 20).center().assign(this)
		box = Hitbox new(20, 20).center().assign(this)
		type = "dirt_block"
	}
	
	update: func (dt:Double) {
		if (hidden && !grown) {
			player := scene getFirst("player")
			if (player) {
				n:UInt8 = 200 - min((x - player x) abs()*8, 200)
				sprite color set(255,n,n,n)
			}
		}
	}
	
	grow: func {
		grown = true
		sprite color set(0xffffffff)
		sprite frame = 1
		scene add(BigStem new(x-20, y-50, 4))
	}
}




STEM_ANIM := [0,1,2,3,4,5,6,7,8,9,10,11]

BigStem: class extends Entity {
	
	masks := MaskList new()
	anim := Anim new("plant_stem.png", 40, 40).center()
	
	init: func (=x, =y, remaining:Int) {
		
		anim play(STEM_ANIM, 10).once().assign(this)
		masks add(Hitbox new(16, 2, -1, 24)).
		      add(Hitbox new(16, 2, 23, 5)).
		      assign(this)
		
		add(Timer new~start(1, ||
			if (remaining > 1)
				scene add(BigStem new(x, y-40, remaining-1))
			else scene add(BigFlower new(x-5, y-45))
		))
		
		type = "big_plant"
	}
}

FLOWER_ANIM := [0,1,2,3,4,5,6,7,8,9]

BigFlower: class extends Entity {
	anim := Anim new("flower.png", 50, 50).center()
	init: func (=x, =y) {
		anim play(FLOWER_ANIM, 10).once().assign(this)
		type = "big_flower"
	}
}



Seed: class extends Entity {
	box: Hitbox
	image: Image
	holder: Entity
	
	init: func (xml:XmlNode) {
		image = Image new("seed.png").center().assign(this)
		box = Hitbox new(3, 5).center().assign(this)
		type = "seed"
	}
	
	update: func (dt:Double) {
		if (holder) {
			x += (holder x - x) * 0.2
			y += (holder y - 9 - y) * 0.2
			
			if (Input pressed("down")) {
				dirt := holder collide("dirt_block", holder x, holder y+1) as DirtBlock
				if (dirt && !dirt grown) {
					dirt grow()
					scene remove(this)
				}
			}
			
		} else {
			holder = collide("player")
		}
	
	}
}



Grapple: class extends Entity {
	
	box: Hitbox
	
	image: Image
	chain: RepeatImage
	graphics: GraphicList
	
	holder: Entity
	holderPhysics:Physics
	
	maxLength: Double = 240
	firing: Bool
	sticking: Bool
	retracting: Bool
	
	init: func {
		image = Image new("grapple.png") .center()
		chain = RepeatImage new("grapple_chain.png")
		chain y = 2
		chain repeatY = 0
		graphics = GraphicList new([chain, image]) .assign(this)
		
		box = Hitbox new(3,5) .center() .assign(this)
	}
	
	update: func (dt:Double) {
		if (holder) {
			chain repeatY = max(holder y-y-6, 0) / chain height
			match {
				case firing =>
					x += (holder x - x) * 0.4
					y -= 300*dt
					if (collide("non_grapple") || collide("solid", x, y+6)) {
						firing = false
					}else if (collide("solid")) {
						sticking = true
						firing = false
					} else if (holder y - y > maxLength) {
						retracting = true
						firing = false
					}
				case retracting =>
					x += (holder x - x) * 0.4
					y += 400*dt
					if (y > holder y - 9) {
						y = holder y - 9
						retracting = false
					}
				case sticking =>
					holderPhysics velY = -100
					holderPhysics nudgeX = (x-holder x) * 0.6
					if (y > holder y+2) {
						sticking = false
					}
					if (Input pressed("down") || Input pressed("up")) {
						sticking = false
						retracting = true
					}
				case =>
					x += (holder x - x) * 0.4
					y += (holder y - 9 - y) * 0.4
					if (Input pressed("down"))
						firing = true
			}
		} else {
			holder = collide("player")
			if (holder)
				holderPhysics = holder get("physics") as Physics
			if (holderPhysics)
				holder as Player onRespawn add(|| firing = sticking = retracting = false)	
			else holder = holderPhysics = null
		}
	}
	
}



PortalEntrance: class extends Entity {
	
	gotoID:Int
	
	init: func (data:XmlNode) {
		gotoID = data getAttr("goto") toInt()
		Image new("portal_entrance.png") center() .assign(this)
		Hitbox new(8, 8) center() .assign(this)
		type = "portal_entrance"
	}
	
	update: func (dt:Double) {
		player := collide("player")
		if (player) {
			scene each("portal_exit", |e|
				exit := e as PortalExit
				if (exit id == gotoID) {
					warp (player, exit)
					return false
				}
				true
			)
		}
	}
	
	warp: func (player:Entity, exit:PortalExit) {
		player x = exit x
		player y = exit y
	}
}

PortalExit: class extends Entity {
	
	id: Int
	
	init: func (data:XmlNode) {
		Image new("portal_exit.png") center() .assign(this)
		id = data getAttr("id") toInt()
		type = "portal_exit"
	}
}



Checkpoint: class extends Entity {
	
	init: func {
		Hitbox new(40, 40) center() .assign(this)
		type = "checkpoint"
	}
	
	update: func (dt:Double) {
		player := collide("player") as Player
		if (player) {
			player setSpawn(x, y)
		}
	}
}



Atmosphere: class extends Entity {
	
	lastTriggered: static Atmosphere
	
	song: String
	particleColor: Color
	particleSpeed: Double
	particleAngle: Double
	
	init: func (data:XmlNode) {
		Hitbox new(40, 40) center() .assign(this)
		
		song = data getAttr("music")
		if (song == "0") song = null
		else song = "song"+song
		
		particleColor set(data getAttr("p_color"))
		particleAngle = data getAttr("p_angle") toDouble()
		particleSpeed = data getAttr("p_speed") toDouble()
		
		type = "atmosphere"
	}
	
	update: func (dt:Double) {
		player := collide("player") as Player
		if (player && lastTriggered != this) {
			lastTriggered = this
			
			if (song) Audio play(song)
			
			scene each("rect_particle", |e|
				p := e as RectParticle
				p color = particleColor
				p setMotion(
					Random randInt(particleSpeed, particleSpeed+10),
					Random randInt(particleAngle-5, particleAngle+5))
				true
			)
			
		}
	}
}



Bug1: class extends Entity {
	
	physics := Physics new(["solid"])
	sprite := SpriteMap new("bug1.png", 4, 4) .center()
	
	box := Hitbox new(4, 3) .center()
	detector := Hitbox new(60, 40, -30, -20)
	
	init: func {
		graphic = sprite
		mask = box
		
		add(physics)
		physics accY = 200
		physics dragX = 50
	}
	
	update: func (dt:Double) {
		if (collide("solid", x, y+2)) {
			mask = detector
			if (collide("player")) {
				physics velX = Random randInt(-50, 50)
				physics velY = Random randInt(-80, -110)
			}
			mask = box
		} else {
			sprite frame = Random randInt(0, 1)
		}
	}
	
}



NonGrapple: class extends Entity {
	init: func (data:XmlNode) {
		Hitbox new(data getAttr("width") toDouble(), data getAttr("height") toDouble()) assign(this)
		type = "non_grapple"
	}
}

FallEnd: class extends Entity {
	init: func (data:XmlNode) {
		Hitbox new(20, 20) center() .assign(this)
		type = "fall_end"
	}
}

FlowerDetached: class extends Entity {
	
	image: Image
	
	init: func {
		image = Image new("flower_detached.png") .center() .assign(this)
		type = "flower_detached"
	}
	update: func (dt:Double) {
		image angle -= dt*45
	}
}
