extends Node

const SCENE_BUBBLE = preload("res://BubbleChat.tscn")

var bubble_ui: CanvasLayer
var resource_dialog: DialogueResource
var baris_sekarang: DialogueLine

var daftar_pembicara: Dictionary = {}
var target_aktif: Marker2D = null
var sedang_aktif: bool = false
var sedang_mengukur: bool = false

func _ready() -> void:
	bubble_ui = SCENE_BUBBLE.instantiate()
	add_child(bubble_ui)
	bubble_ui.hide()

func mulai(dialog: DialogueResource, judul_awal: String, pembicara: Dictionary) -> void:
	if sedang_aktif:
		return
		
	sedang_aktif = true
	resource_dialog = dialog
	daftar_pembicara = pembicara
	
	baris_sekarang = await DialogueManager.get_next_dialogue_line(resource_dialog, judul_awal)
	_proses_baris()

func _proses_baris() -> void:
	if baris_sekarang == null:
		_akhiri_dialog()
		return
	
	sedang_mengukur = true
	
	# 1. Ukur kotak di balik layar
	await bubble_ui.siapkan_ukuran_teks(baris_sekarang)
	
	# 2. Pindahkan ke kepala pembicara aktif
	target_aktif = daftar_pembicara.get(baris_sekarang.character, null)
	_perbarui_posisi_balon()
	
	# 3. Buka kunci posisi & jalankan efek Pop-Up disusul ketikan teks
	sedang_mengukur = false
	await bubble_ui.tampilkan_dan_ketik()

func _process(_delta: float) -> void:
	if sedang_aktif and not sedang_mengukur and bubble_ui.visible:
		_perbarui_posisi_balon()

func _perbarui_posisi_balon() -> void:
	if is_instance_valid(target_aktif):
		var posisi_kepala_di_layar = target_aktif.get_global_transform_with_canvas().origin
		var ukuran = bubble_ui.ambil_ukuran_balon()
		
		var posisi_pas = Vector2(
			posisi_kepala_di_layar.x - (ukuran.x / 2.0),
			posisi_kepala_di_layar.y - ukuran.y
		)
		bubble_ui.atur_posisi_balon(posisi_pas)

func _unhandled_input(event: InputEvent) -> void:
	# Cegah input saat masih mengukur kotak atau saat balon masih animasi pop-up
	if not sedang_aktif or sedang_mengukur or bubble_ui.sedang_pop_up or not bubble_ui.visible:
		return
		
	var tekan_lanjut = event.is_action_pressed("ui_accept") or (
		event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	)
	
	if tekan_lanjut:
		get_viewport().set_input_as_handled()
		
		if bubble_ui.dialogue_label.is_typing:
			bubble_ui.dialogue_label.skip_typing()
		else:
			_ke_baris_berikutnya()

func _ke_baris_berikutnya() -> void:
	baris_sekarang = await DialogueManager.get_next_dialogue_line(resource_dialog, baris_sekarang.next_id)
	_proses_baris()

func _akhiri_dialog() -> void:
	sedang_mengukur = true
	# Mainkan animasi mengecil (pop-out) sebelum benar-benar ditutup
	await bubble_ui.tutup_balon()
	sedang_aktif = false
	sedang_mengukur = false
	target_aktif = null
	daftar_pembicara.clear()
