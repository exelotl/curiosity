use mxml
import io/File
import math/Random
import vamos/[Engine, Entity, Scene]
import vamos/display/[Screen, Color]
import vamos/comps/Timer
import Factory, Particles, Fx, Map, Global

Level: class extends Scene {
	
	xml := XmlNode new()
	
	width, height: Double
	
	init: func (path:String) {
		file := File new(path)
		xml loadString(file read(), MXML_OPAQUE_CALLBACK)
		xml = xml findElement("level")
	}
	
	create: func {
		
		vamos screen color set(xml getAttr("bgcolor"))
		width = xml getAttr("width") toDouble()
		height = xml getAttr("height") toDouble()
		
		entities := xml findElement("entities")
		
		entities eachChildElement(|node|
			e := Factory create(node)
			if (e) {
				add(e)
				e class name println()
			}
		)
		
		add(Map new(this, xml))
	}
	
	update: func (dt:Double) {
		super(dt)
		player := getFirst("player")
		if (player) {
			vamos screen camX = player x - vamos screen width / 2
			vamos screen camY = player y - vamos screen height / 2
		}
	}
	
	end: func {
		
	}
	
}

IntroLevel: class extends Level {
	
	init: func {
		super("assets/introlevel.oel")
	}
	
	create: func {
		super()
		for (i in 0..20)
			add(RectParticle new(
				Random randInt(0, vamos screen width),
				Random randInt(0, vamos screen height),
				"particle1.png", 0.5,
				Random randInt(10, 20),
				Random randInt(265, 275)))
		add(CameraOverlay new("overlay1.png", 40))
		Audio play("song2")
	}
	
	update: func (dt:Double) {
		super(dt)
	}
	
	ending := false
	
	end: func {
		if (!ending) {
			ending = true
			add(ScreenFade new("overlay2.png", 2, 0, 255))
		}
	}
}

Level1: class extends Level {
	
	init: func {
		super("assets/level1.oel")
	}
	
	create: func {
		super()
		for (i in 0..20)
			add(RectParticle new(
				Random randInt(0, vamos screen width),
				Random randInt(0, vamos screen height),
				"particle1.png", 0.5,
				Random randInt(10, 20),
				Random randInt(85, 95)))
		add(CameraOverlay new("overlay1.png", 40))
		add(ScreenFade new("overlay2.png", 5, 255, 0))
	}
	
	update: func (dt:Double) {
		super(dt)
	}
	
	ending := false
	
	end: func {
		if (!ending) {
			ending = true
			add(ScreenFade new("overlay2.png", 5, 0, 255))
		}
	}
	
}