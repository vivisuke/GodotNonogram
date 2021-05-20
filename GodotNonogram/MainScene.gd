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
const BITS_MASK = (1<<N_ANS_HORZ) - 1
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
const TILE_NUM_0 = 1
const ColorClues = Color("#dff9fb")

var dialog_opened = false;
var mouse_pushed = false
var last_xy = Vector2()
var cell_val = 0
var g_map = {}		# 水平・垂直方向手がかり数字配列 → 候補数値マップ
#var h_map = {}		# 水平方向手がかり数字 → 数値マップ
#var v_map = {}		# 垂直方向手がかり数字 → 数値マップ
var h_clues = []		# 水平方向手がかり数字リスト
var v_clues = []		# 垂直方向手がかり数字リスト
var h_candidates = []	# 水平方向候補リスト
var v_candidates = []	# 垂直方向候補リスト
var h_fixed_bits_1 = []
var h_fixed_bits_0 = []
var v_fixed_bits_1 = []
var v_fixed_bits_0 = []

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
	#var t = data_to_clues(0xd0e)
	#print(t)
	#var map = {}
	#map[[1, 2]] = [12, 3]
	#print(map)
	#print(map[[1, 2]])
	build_map()
	#print("h_map.size() = ", h_map.size())
	#print(h_map)
	#for i in range(h_map.size()):
	#	print(h_map.keys()[i], ": ", h_map.values()[i])
	h_clues.resize(N_ANS_VERT)
	v_clues.resize(N_ANS_HORZ)
	pass
func init_arrays():
	h_candidates.resize(N_ANS_VERT)
	v_candidates.resize(N_ANS_HORZ)
	h_fixed_bits_1.resize(N_ANS_VERT)
	h_fixed_bits_0.resize(N_ANS_VERT)
	v_fixed_bits_1.resize(N_ANS_HORZ)
	v_fixed_bits_0.resize(N_ANS_HORZ)
	#print(h_candidates)
func _draw():
	#draw_rect(Rect2(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), Color(0.5, 0.75, 0.5))
	pass
# 101101110 → [3, 2, 1]	下位ビットの方が配列先頭とする
func data_to_clues(data : int) -> Array:
	var lst = []
	while data != 0:
		var b = data & -data
		data ^= b
		var n = 1
		b <<= 1
		while (data & b) != 0:
			data ^= b
			b <<= 1
			n += 1
		lst.push_back(n)
	return lst
# key は連配列、下位ビットの方が配列先頭
func build_map():
	g_map.clear()
	for data in range(1<<N_ANS_HORZ):
		var key = data_to_clues(data)
		if g_map.has(key):
			g_map[key].push_back(data)
		else:
			g_map[key] = [data]
func to_binText(d : int) -> String:
	var txt = ""
	var mask = 1 << (N_ANS_HORZ - 1)
	while mask != 0:
		txt += '1' if (d&mask) != 0 else '0'
		mask >>= 1
	return txt
func to_hexText(lst : Array) -> String:
	var txt = "["
	for i in range(lst.size()):
		txt += to_binText(lst[i])
		txt += ", "
	txt += "]"
	return txt
func init_candidates():
	#print("\n*** init_candidates():")
	#print("g_map[[4]] = ", g_map[[4]])
	for y in range(N_ANS_VERT):
		#print("h_clues[", y, "] = ", h_clues[y])
		if h_clues[y] == null:
			h_candidates[y] = [0]
		else:
			h_candidates[y] = g_map[h_clues[y]].duplicate()
		#print( "h_cand[", y, "] = ", to_hexText(h_candidates[y]) )
	for x in range(N_ANS_HORZ):
		#print("v_clues[", x, "] = ", v_clues[x])
		if v_clues[x] == null:
			v_candidates[x] = [0]
		else:
			v_candidates[x] = g_map[v_clues[x]].duplicate()
		#print( "v_cand[", x, "] = ", to_hexText(v_candidates[x]) )
	#print("g_map[[4]] = ", g_map[[4]])
func num_candidates():
	var sum = 0
	for y in range(N_ANS_VERT):
		sum += h_candidates[y].size()
	for x in range(N_ANS_HORZ):
		sum += v_candidates[x].size()
	return sum
# h_candidates[] を元に h_fixed_bits_1, 0 を計算
func update_h_fixedbits():
	#print("\n*** update_h_fixedbits():")
	for y in range(N_ANS_VERT):
		var lst = h_candidates[y]
		if lst.size() == 1:
			h_fixed_bits_1[y] = lst[0]
			h_fixed_bits_0[y] = ~lst[0] & BITS_MASK
		else:
			var bits1 = BITS_MASK
			var bits0 = BITS_MASK
			for i in range(lst.size()):
				bits1 &= lst[i]
				bits0 &= ~lst[i]
			h_fixed_bits_1[y] = bits1
			h_fixed_bits_0[y] = bits0
		#print("h_fixed[", y , "] = ", to_binText(h_fixed_bits_1[y]), ", ", to_binText(h_fixed_bits_0[y]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# v_candidates[] を元に v_fixed_bits_1, 0 を計算
func update_v_fixedbits():
	#print("\n*** update_v_fixedbits():")
	for x in range(N_ANS_HORZ):
		var lst = v_candidates[x]
		if lst.size() == 1:
			v_fixed_bits_1[x] = lst[0]
			v_fixed_bits_0[x] = ~lst[0] & BITS_MASK
		else:
			var bits1 = BITS_MASK
			var bits0 = BITS_MASK
			for i in range(lst.size()):
				bits1 &= lst[i]
				bits0 &= ~lst[i]
			v_fixed_bits_1[x] = bits1
			v_fixed_bits_0[x] = bits0
		#print("v_fixed[", x , "] = ", to_binText(v_fixed_bits_1[x]), ", ", to_binText(v_fixed_bits_0[x]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func hFixed_to_vFixed():
	#print("\n*** hFixed_to_vFixed():")
	for x in range(N_ANS_HORZ):
		v_fixed_bits_1[x] = 0
		v_fixed_bits_0[x] = 0
	var hmask = 1 << N_ANS_HORZ;
	for x in range(N_ANS_HORZ):
		hmask >>= 1
		var vmask = 1 << N_ANS_VERT;
		for y in range(N_ANS_VERT):
			vmask >>= 1
			if( (h_fixed_bits_1[y] & hmask) != 0 ):
				v_fixed_bits_1[x] |= vmask;
			if( (h_fixed_bits_0[y] & hmask) != 0 ):
				v_fixed_bits_0[x] |= vmask;
		#print("v_fixed[", x , "] = ", to_binText(v_fixed_bits_1[x]), ", ", to_binText(v_fixed_bits_0[x]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func vFixed_to_hFixed():
	#print("\n*** vFixed_to_hFixed():")
	for y in range(N_ANS_VERT):
		h_fixed_bits_1[y] = 0
		h_fixed_bits_0[y] = 0
	var vmask = 1 << N_ANS_VERT;
	for y in range(N_ANS_VERT):
		vmask >>= 1
		var hmask = 1 << N_ANS_HORZ;
		for x in range(N_ANS_HORZ):
			hmask >>= 1
			if( (v_fixed_bits_1[x] & vmask) != 0 ):
				h_fixed_bits_1[y] |= hmask;
			if( (v_fixed_bits_0[x] & vmask) != 0 ):
				h_fixed_bits_0[y] |= hmask;
		#print("h_fixed[", y , "] = ", to_binText(h_fixed_bits_1[y]), ", ", to_binText(h_fixed_bits_0[y]))
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# v_fixed_bits_1, 0 を元に v_candidates[] から不可能なパターンを削除
func update_v_candidates():
	#print("\n*** update_v_candidates():")
	for x in range(N_ANS_HORZ):
		for i in range(v_candidates[x].size()-1, -1, -1):
			if( (v_candidates[x][i] & v_fixed_bits_1[x]) != v_fixed_bits_1[x] ||
					(~v_candidates[x][i] & v_fixed_bits_0[x]) != v_fixed_bits_0[x] ):
				v_candidates[x].remove(i)
		#print( "v_cand[", x, "] = ", to_hexText(v_candidates[x]) )
	#print("g_map[[4]] = ", g_map[[4]])
	pass
# h_fixed_bits_1, 0 を元に h_candidates[] から不可能なパターンを削除
func update_h_candidates():
	#print("\n*** update_h_candidates():")
	for y in range(N_ANS_VERT):
		for i in range(h_candidates[y].size()-1, -1, -1):
			if( (h_candidates[y][i] & h_fixed_bits_1[y]) != h_fixed_bits_1[y] ||
					(~h_candidates[y][i] & h_fixed_bits_0[y]) != h_fixed_bits_0[y] ):
				h_candidates[y].remove(i)
		#print( "h_cand[", y, "] = ", to_hexText(h_candidates[y]) )
	#print("g_map[[4]] = ", g_map[[4]])
	pass
func update_clues(x0, y0):
	# 水平方向手がかり数字
	var data = 0
	for x in range(N_ANS_HORZ):
		data = data * 2 + (1 if $TileMap.get_cell(x, y0) == 1 else 0)
	var lst = data_to_clues(data)
	h_clues[y0] = lst;
	var x = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x, y0, lst[i] + TILE_NUM_0)
		x -= 1
	while x >= -5:
		$TileMap.set_cell(x, y0, -1)
		x -= 1
	# 垂直方向手がかり数字
	data = 0
	for y in range(N_ANS_VERT):
		data = data * 2 + (1 if $TileMap.get_cell(x0, y) == 1 else 0)
	lst = data_to_clues(data)
	v_clues[x0] = lst;
	var y = -1
	for i in range(lst.size()):
		$TileMap.set_cell(x0, y, lst[i] + TILE_NUM_0)
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
	if dialog_opened:
		return;
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


func _on_OpenButton_pressed():
	pass # Replace with function body.


func _on_SaveButton_pressed():
	var dlg = FileDialog.new()
	add_child(dlg)
	dlg.mode = FileDialog.MODE_SAVE_FILE 
	#dlg.window_title = "GDNonogram - Save File -"
	dlg.resizable = true
	dlg.current_dir = "user://"
	dlg.current_path = "user://notitle.txt"
	dlg.rect_size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	dlg.popup_centered()
	dialog_opened = true;
	pass # Replace with function body.


func _on_CheckButton_pressed():
	init_arrays()
	init_candidates()
	var nc0 = 0
	var solved = false
	while true:
		update_h_fixedbits()
		#print("num candidates = ", num_candidates())
		var nc = num_candidates()
		if nc == N_ANS_HORZ + N_ANS_VERT:	# solved
			solved = true
			break
		if nc == nc0:	# CAN't be solved
			break;
		nc0 = nc
		hFixed_to_vFixed()
		update_v_candidates()
		update_v_fixedbits()
		vFixed_to_hFixed()
		update_h_candidates()
	print(solved)
	if solved:
		$MessLabel.text = "Propper Quest"
	else:
		$MessLabel.text = "Impropper Quest"
	var txt = ""
	for y in range(N_ANS_VERT):
		#print(to_binText(h_fixed_bits_1[y]), " ", to_binText(h_fixed_bits_0[y]))
		var mask = 1<<(N_ANS_HORZ-1)
		while mask != 0:
			if (h_fixed_bits_1[y] & mask) != 0:
				txt += "#"
			elif (h_fixed_bits_0[y] & mask) != 0:
				txt += "."
			else:
				txt += "?"
			mask >>= 1
		txt += "\n"
	print(txt)
	pass # Replace with function body.
