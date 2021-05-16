extends Node2D

const SCREEN_WIDTH = 460.0
const SCREEN_HEIGHT = 800.0
const TICK_WIDTH = 2
const THIN_WIDTH = 1
const CELL_WIDTH = 30.0
const N_CELL_HORZ = 15
const N_CELL_VERT = 15
const N_ANS_HORZ = 10
const N_ANS_VERT = 10
const BOARD_WIDTH = CELL_WIDTH * N_CELL_HORZ		# 手かがり領域を含めた盤面全体幅
const BOARD_HEIGHT = CELL_WIDTH * N_CELL_VERT
const ANS_WIDTH = CELL_WIDTH * N_ANS_HORZ
const ANS_HEIGHT = CELL_WIDTH * N_ANS_VERT
const BOARD_Y0 = 100								# 手がかり領域上端座標
const ANS_Y0 = BOARD_Y0 + CELL_WIDTH * 5			# 解答領域上端座標
const BOARD_X0 = (SCREEN_WIDTH - BOARD_WIDTH) / 2	# 手がかり領域左端座標
const ANS_X0 = BOARD_X0 + CELL_WIDTH * 5			# 解答領域左端座標
const ColorClues = Color("#dff9fb")

func _ready():
	#print("BD WD = ", BOARD_WIDTH)
	$TileMap.set_cell(0, 0, 0)
	$TileMap.set_cell(1, 1, 1)
	pass
func _draw():
	draw_rect(Rect2(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), Color(0.5, 0.75, 0.5))
	"""
	#draw_rect(Rect2(BOARD_X0, BOARD_Y0, BOARD_WIDTH, BOARD_HEIGHT), Color(1, 1, 1))
	draw_rect(Rect2(ANS_X0, ANS_Y0, ANS_WIDTH, ANS_HEIGHT), Color(1, 1, 1))		# 解答エリア
	draw_rect(Rect2(ANS_X0, BOARD_Y0, ANS_WIDTH, CELL_WIDTH*5), ColorClues)		# 手がかりエリア
	draw_rect(Rect2(BOARD_X0, ANS_Y0, CELL_WIDTH*5, ANS_HEIGHT), ColorClues)		# 手がかりエリア
	
	var y = BOARD_Y0 + CELL_WIDTH * 5
	var y2 = BOARD_Y0 + BOARD_HEIGHT
	for k in range(N_CELL_HORZ+1):		# 縦線
		var y1 = y if k < 5 else BOARD_Y0
		var wd = 1 if k % 5 != 0 else 2
		draw_line(Vector2(BOARD_X0+k*CELL_WIDTH, y1), Vector2(BOARD_X0+k*CELL_WIDTH, y2), Color("#000000"), wd)
	var x = BOARD_X0 + CELL_WIDTH * 5
	var x2 = BOARD_X0 + BOARD_WIDTH
	for k in range(N_CELL_VERT+1):		# 横線
		var x1 = x if k < 5 else BOARD_X0
		var wd = 1 if k % 5 != 0 else 2
		draw_line(Vector2(x1, BOARD_Y0+k*CELL_WIDTH), Vector2(x2, BOARD_Y0+k*CELL_WIDTH), Color("#000000"), wd)
	"""
	pass
