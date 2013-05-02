import vamos/[Engine, Entity, Component]
import vamos/display/Screen
import vamos/masks/Hitbox

Wrapping: class extends Component {
	w, h: UInt
	scroll: Double
	init: func (=w, =h, =scroll)
	update: func (dt:Double) {
		left := vamos screen camX * scroll
		top := vamos screen camY * scroll
		right := left + vamos screen width
		bottom := top + vamos screen height
		
		if (entity x < left-w) entity x += vamos screen width+w
		else if (entity x > right+w) entity x -= vamos screen width+w
		
		if (entity y < top-h) entity y += vamos screen height + h
		else if (entity y > bottom+h) entity y -= vamos screen height+h
	}
}