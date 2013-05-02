import math, math/Random
import vamos/[Entity, Util]
import vamos/display/Color
import vamos/graphics/[Image, FilledRect]
import vamos/masks/Hitbox
import vamos/comps/[Physics, Timer]
import Components, Global

RectParticle: class extends Entity {
	
	targetVelX=0: Double
	targetVelY=0: Double
	velX=0, velY=0: Double
	
	speed, angle:Double
	img: Image
	
	color: Color {
		get { img color }
		set (v) { img color = v }
	}
	
	init: func (=x, =y, path:String, scroll, speed, angle:Double) {
		
		img = Image new(path) .assign(this)
		img scrollX = scroll
		img scrollY = scroll
		color = (255, 0, 0, 0) as Color
		
		setMotion(speed, angle)
		
		add(Wrapping new(img width, img height, scroll))
		type = "rect_particle"
		layer = Layers bgParticles
	}
	
	setMotion: func (speed:Double, angle:Double) {
		targetVelX = angle toRadians() cos() * speed
		targetVelY = angle toRadians() sin() * -speed
	}
	
	update: func(dt:Double) {
		x += velX * dt
		y += velY * dt
		if (velX < targetVelX) velX = min(targetVelX, velX + dt * 10)
		else if (velX > targetVelX) velX = max(targetVelX, velX - dt * 10)
		if (velY < targetVelY) velY = min(targetVelY, velY + dt * 10)
		else if (velY > targetVelY) velY = max(targetVelY, velY - dt * 10)
	}
	
}

PlayerDebris: class extends Entity {
	init: func (=x, =y) {
		Hitbox new(4, 4) center().assign(this)
		FilledRect new(4, 4, 0xff000000) center().assign(this)
		p := Physics new(TYPES_SOLID)
		angle := Random randInt(0, 360) as Double toRadians()
		p velX = angle cos() * 200
		p velY = -angle sin() * 200
		p dragX = 200
		p accY = 600
		p bounce = 0.6
		add(p)
		add(Timer new~start(Random randInt(7, 10), || scene remove(this)))
	}
}