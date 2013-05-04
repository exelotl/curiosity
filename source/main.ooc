use vamos
import vamos/[Engine, Scene, Entity, Util]
import Global

main: func (argc:Int, argv:CString*) {
	
	vamos = Engine new(400, 240, 2)
	vamos caption = "Curiosity"

	if (argc == 2) {
		vamos frameRate = argv[1] toString() toInt()
		vamos frameRate clamp(12, 60)
	}
	
	Audio init()
	
	vamos start(Scenes introLevel)
}
