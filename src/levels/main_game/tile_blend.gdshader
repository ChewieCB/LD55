shader_type canvas_item;

// This shader requires you to set it's size to
// width = cellSize * mapData.width-2
// height = cellSize * mapData.width-2
// Also tilesWidth / height needs to be mapData.axis - 2
// This is because we need a border on all sides for edge calculations
// Keep this in mind when positioning the image in your scene


// Size of our grid, please scale texture accordingly from outside
uniform float cellSize = 64.0;

// The cell size divided by 2 as a negative number
uniform float halfCellNegative = -32.0;

// Size of textures in the atlas, assumed it is rectangular
uniform float taTextureSize = 1024;
// Amount of textures per row (max) in the texture atlas
uniform float taTexturesWidth = 16;

// The width / height of the texture in tiles. Set from outside
// Set it to 2 less in both width / height than the mapData texture
uniform float tilesWidth = 298;
uniform float tilesHeight = 298;

// The texture atlas
uniform sampler2D textureAtlas;

// The map data
uniform sampler2D mapData;

// Tile blend texture containing strength for blend
// R = horizontal, G = Vertical, B = Corner, A = Self
uniform sampler2D blendTexture;

uniform bool blend = true;

//
// Get the current tile position
//
vec2 getTilePos(vec2 uv) {
	// Find the tile we are on (we got a border of 1 so +1)
	return vec2(floor(uv.x * tilesWidth)+1.0, floor(uv.y * tilesHeight)+1.0);
}

//
// Get our relative pixel pos in the tile
// Should be a number from 0 to 63
//
vec2 getPixelPosInTile(vec2 uv) {
	float exactPosX = floor(((uv.x * tilesWidth)+1.0) * cellSize);
	float exactPosY = floor(((uv.y * tilesHeight)+1.0) * cellSize);
	float relativePosX = mod(exactPosX, cellSize);
	float relativePosY = mod(exactPosY, cellSize);
	return vec2(relativePosX, relativePosY);
}

//
// Get your pixel position in the tile map
//
vec2 getAtlasPixelPos(vec2 pixelPosInTile, float tileId, vec2 tile) {
	float row = floor(tileId / taTexturesWidth);
	float col = tileId - (row * taTexturesWidth);
	vec2 textureStartPos = vec2(taTextureSize * col, taTextureSize * row);

	// TODO: We need to somehow adjust this based on starting cell from the outside
	float tileRepeat = taTextureSize / cellSize;
	float xAdd = mod(tile.x, tileRepeat) * cellSize;
	float yAdd = mod(tile.y, tileRepeat) * cellSize;
	textureStartPos += vec2(xAdd, yAdd);
	
	return textureStartPos + pixelPosInTile;
}

//
// Get the id of the tile given the current position
//
float getTileId(vec2 pos) {
	float tileRed = texelFetch(mapData, ivec2(pos), 0).r;
	return tileRed * 255.;
}

//
// Get the color of the tile relative to the original tile
//
vec4 getColorForTile(vec2 tile, float tileId, vec2 pixelPosInTile) {
	vec2 pixelPosAtlas = getAtlasPixelPos(pixelPosInTile, tileId, tile);
	return (texture( textureAtlas, pixelPosAtlas / vec2(textureSize(textureAtlas,0)), -10));
}

void fragment() {
	// Get our tile position
	vec2 tile = getTilePos(UV);
	vec2 pixelPosInTile = getPixelPosInTile(UV);
	
	// Grab colors for this tile
	float tileIdC = getTileId(tile);
	vec4 colorSelf = getColorForTile(tile, tileIdC, pixelPosInTile);
	COLOR = colorSelf;
	
	// Blend if needed
	if (blend) {
		// If these numbers are negative they are left / up
		// Could be 0 at center of tile but does not matter as we will just sample ourselves
		// and corner / sides should have no effect at center
		float horizontal = clamp(halfCellNegative + pixelPosInTile.x, -1.0, 1.0);
		float vertical = clamp(halfCellNegative + pixelPosInTile.y, -1.0, 1.0);
		
		
		float tileIdHorizontal = getTileId(tile+vec2(horizontal,0));
		float tileIdVertical = getTileId(tile+vec2(0,vertical));
		float tileIdCorner = getTileId(tile+vec2(horizontal,vertical));
		
		vec4 colorHorizontal = getColorForTile(tile, tileIdHorizontal, pixelPosInTile);
		vec4 colorVertical = getColorForTile(tile, tileIdVertical, pixelPosInTile);
		vec4 colorCorner = getColorForTile(tile, tileIdCorner, pixelPosInTile);
		
		// Extract blend strength as a number from 0 to 1
		vec4 blendStrength = texelFetch(blendTexture, ivec2(pixelPosInTile), 0);
		float strHorizontal = (blendStrength.r * 255.);
		float strVertical = (blendStrength.g * 255.);
		float strCorner = (blendStrength.b * 255.);
		float strSelf = (blendStrength.a * 255.);
		
		// Attempt to blend based on percentage
		vec4 colorBase = vec4(1);
		colorSelf = mix(colorBase, colorSelf, strSelf / 100.0);
		colorHorizontal = mix(colorBase, colorHorizontal, strHorizontal / 100.0);
		colorVertical = mix(colorBase, colorVertical, strVertical / 100.0);
		colorCorner = mix(colorBase, colorCorner, strCorner / 100.0);
		
		// Mix in the colors at the given strength (?may need work)
		COLOR = colorSelf * colorHorizontal * colorVertical * colorCorner;
		
		// For debug to see blend visiualized
		//COLOR = vec4(strHorizontal, strVertical, strCorner, 1f);

	}
}