use sdl2
import sdl2/Core
import vamos/Entity
import vamos/graphics/[FilledRect, Image]
import vamos/display/[Screen, Color]
import vamos/comps/Tween
import Global
import math/Random

ScreenFade: class extends Entity {
	init: func (path:String, duration:Double, fromAlpha, toAlpha:UInt8) {
		image := Image new(path) .assign(this)
		image scrollX = image scrollY = 0
		image alpha = 0
		layer = Layers fx
		add(Tween new~start(duration, |n|
			image alpha = Tween linear(fromAlpha, toAlpha, n)
		))
	}
}

CameraOverlay: class extends Entity {
	image:Image
	flicker:UInt8
	init: func (path:String, =flicker) {
		image = Image new(path)
		image scrollX = 0
		image scrollY = 0
		graphic = image
		layer = Layers fx
	}
	update: func(dt:Double) {
		image alpha = Random randInt(255-flicker, 255)
	}
}