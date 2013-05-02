use mxml
import vamos/Entity
import vamos/graphics/[TileMap, FilledRect]
import vamos/masks/[Grid, Hitbox]
import Global, Level

Map: class extends Entity {
	tiles: TileMap
	grid: Grid
	
	init: func (level:Level, xml:XmlNode) {
		
		w := level width / TILE_W
		h := level height / TILE_H
		gridData := xml findElement("grid")
		tileData := xml findElement("tiles")
		
		grid := Grid new(w, h, TILE_W, TILE_H) .assign(this)
		grid load(gridData getOpaque(), "", "\n")
		
		tiles := TileMap new("tiles.png", w, h, TILE_W, TILE_H) .assign(this)
		tiles firstValue = 0
		tiles load(tileData getOpaque(), ",", "\n")
		
		type = "solid"
		layer = Layers walls
	}
}


Floor: class extends Entity {
	init: func (=y) {
		mask = Hitbox new(SCREEN_W, SCREEN_H)
		graphic = FilledRect new(SCREEN_W, SCREEN_H, 0,0,0)
		graphic scrollX = 0
		type = "solid"
	}
}
