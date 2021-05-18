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
const N_CLUES_HORZ = 5
const N_CLUES_VERT = 5
const BOARD_WIDTH = CELL_WIDTH * N_CELL_HORZ		# 手かがり領域を含めた盤面全体幅
const BOARD_HEIGHT = CELL_WIDTH * N_CELL_VERT
const ANS_WIDTH = CELL_WIDTH * N_ANS_HORZ
const ANS_HEIGHT = CELL_WIDTH * N_ANS_VERT
const BOARD_Y0 = 100								# 手がかり領域上端座標
const ANS_Y0 = BOARD_Y0 + CELL_WIDTH * 5			# 解答領域上端座標
const BOARD_X0 = (SCREEN_WIDTH - BOARD_WIDTH) / 2	# 手がかり領域左端座標
const ANS_X0 = BOARD_X0 + CELL_WIDTH * 5			# 解答領域左端座標
const ColorClues = Color("#dff9fb")

var mouse_pushed = false
var last_xy = Vector2()
var cell_val = 0

func _ready():
	#print("BD WD = ", BOARD_WIDTH)
	#$TileMap.set_cell(0, 0, 0)
	#$TileMap.set_cell(1, 1, 1)
	#$TileMap.set_cell(1, -1, 2)
	#$TileMap.set_cell(1, -2, 3)
	#$TileMap.set_cell(1, -3, 4)
	#$TileMap.set_cell(1, -4, 5)
	#$TileMap.set_cell(1, -5, 6)
	#$TileMap.set_cell(2, -1, 6+1)
	#$TileMap.set_cell(2, -2, 7+1)
	#$TileMap.set_cell(2, -3, 8+1)
	#$TileMap.set_cell(2, -4, 9+1)
	#$TileMap.set_cell(2, -5, 10+1)
	pass
func _draw():
	draw_rect(Rect2(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), Color(0.5, 0.75, 0.5))
	pass
func update_clues(x0, y0):
	# 水平方向手がかり数字
	var lst = []
	var x = N_ANS_HORZ - 1
	while x >= 0:
		while x >= 0 && $TileMap.get_cell(x, y0) != 1:
			x -= 1
		if x < 0:
			break
		var n = 0
		while x >= 0 && $TileMap.get_cell(x, y0) == 1:
			x -= 1
			n += 1
		lst.push_back(n)
	print(lst)
	x = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x, y0, lst[i] + 1)
		x -= 1
	while x >= -5:
		$TileMap.set_cell(x, y0, -1)
		x -= 1
	# 垂直方向手がかり数字
	lst = []
	var y = N_ANS_VERT - 1
	while y >= 0:
		while y >= 0 && $TileMap.get_cell(x0, y) != 1:
			y -= 1
		if y < 0:
			break
		var n = 0
		while y >= 0 && $TileMap.get_cell(x0, y) == 1:
			y -= 1
			n += 1
		lst.push_back(n)
	print(lst)
	y = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x0, y, lst[i] + 1)
		y -= 1
	while y >= -5:
		$TileMap.set_cell(x0, y, -1)
		y -= 1
	pass
func posToXY(pos):
	var xy = Vector2(-1, -1)
	var X0 = $TileMap.position.x
	var Y0 = $TileMap.position.y
	if pos.x >= X0 && pos.x < X0 + CELL_WIDTH*N_ANS_HORZ:
		if pos.y >= Y0 && pos.y < Y0 + CELL_WIDTH*N_ANS_VERT:
			xy.x = floor((pos.x - X0) / CELL_WIDTH)
			xy.y = floor((pos.y - Y0) / CELL_WIDTH)
	return xy
func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			#print(event.position)
			var xy = posToXY(event.position)
			print(xy)
			if xy.x >= 0:
				mouse_pushed = true;
				last_xy = xy
				var v = $TileMap.get_cell(xy.x, xy.y)
				#v = 1 if v < 0 else v - 1
				v = -v;
				cell_val = v
				$TileMap.set_cell(xy.x, xy.y, v)
				update_clues(xy.x, xy.y)
				var img = 0 if v == 1 else -1
				$ImageTileMap.set_cell(xy.x, xy.y, img)
		elif event.is_action_released("click"):
			mouse_pushed = false;
			print("click released")
	elif event is InputEventMouseMotion && mouse_pushed:
		var xy = posToXY(event.position)
		if xy.x >= 0 && xy != last_xy:
			print(xy)
			last_xy = xy
			$TileMap.set_cell(xy.x, xy.y, cell_val)
			update_clues(xy.x, xy.y)
			var img = 0 if cell_val == 1 else -1
			$ImageTileMap.set_cell(xy.x, xy.y, img)
	pass
#func _process(delta):
#	if Input.is_action_just_released("click"):
#		print("click released")
		
func clear_all():
	for y in range(N_CELL_VERT):
		for x in range(N_CELL_HORZ):
			$TileMap.set_cell(x, y, -1)
			$ImageTileMap.set_cell(x, y, -1)
		for x in range(N_CLUES_HORZ):
			$TileMap.set_cell(-x-1, y, -1)
	for x in range(N_CELL_HORZ):
		for y in range(N_CLUES_VERT):
			$TileMap.set_cell(x, -y-1, -1)
	pass
func _on_ClearButton_pressed():
	clear_all()
	pass # Replace with function body.
