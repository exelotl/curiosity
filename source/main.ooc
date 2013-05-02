use vamos
import vamos/[Engine, Scene, Entity]
import Global

main: func (argc:Int, argv:CString*) {
	
	vamos = Engine new(400, 240, 2)
	vamos caption = "Minimalism"
	
	Audio init()
	
	vamos start(Scenes introLevel)
}
