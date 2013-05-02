import structs/[ArrayList, HashMap]
import vamos/audio/Music
import Level

SCREEN_W := const 400
SCREEN_H := const 240
TILE_W := const 10
TILE_H := const 10

TYPES_SOLID := ["solid", "dirt_block", "big_plant"] as ArrayList<String>

Scenes: class {
	introLevel := static IntroLevel new()
	level1 := static Level1 new()
}

Layers: class {
	fx          := static 3
	walls       := static 2
	player      := static 1
	bgParticles := static 0
}


Audio: class {
	
	currentSong: static Music
	
	songs := static HashMap<String, Music> new()
	
	init: static func {
		songs put("song1", Music new("assets/song1.ogg"))
		songs put("song2", Music new("assets/song2.ogg"))
		songs put("song3", Music new("assets/song3.ogg"))
		songs put("song4", Music new("assets/song4.ogg"))
		songs put("song5", Music new("assets/song5.ogg"))
	}
	
	play: static func (key:String) {
		"playing song: %s" printfln(key)
		
		if (currentSong) 
			currentSong volumeChange = -0.000002
		
		if (songs[key]) {
			currentSong = songs[key]
			currentSong play()
			currentSong volumeChange = 0.000005
		}
	}
}