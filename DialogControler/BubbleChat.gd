extends CanvasLayer

@export var lebar_maksimal: float = 256.0

@onready var control_utama: Control = $Control
@onready var wadah_utama: PanelContainer = $Control/Panel
@onready var dialogue_label: DialogueLabel = $Control/Panel/MarginContainer/DialogueLabel
@onready var ekor_balon: TextureRect = $Control/TextureRect

var tween_animasi: Tween
var sedang_pop_up: bool = false

func siapkan_ukuran_teks(baris: DialogueLine) -> void:
	show()
	# Penting: Kembalikan scale ke (1, 1) dulu saat mengukur, cukup sembunyikan pakai alpha = 0
	control_utama.modulate.a = 0.0
	control_utama.scale = Vector2.ONE
	
	# 1. Reset ukuran minimum kotak & matikan autowrap
	wadah_utama.custom_minimum_size = Vector2.ZERO
	dialogue_label.custom_minimum_size = Vector2.ZERO
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	wadah_utama.size = Vector2.ZERO
	
	# 2. Masukkan baris dialog & tampilkan semua huruf sementara untuk diukur
	dialogue_label.dialogue_line = baris
	dialogue_label.visible_characters = -1
	
	await get_tree().process_frame
	
	# 3. Kalau teks melebihi lebar maksimal, aktifkan autowrap
	if dialogue_label.size.x > lebar_maksimal:
		dialogue_label.custom_minimum_size.x = lebar_maksimal
		dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		await get_tree().process_frame
		wadah_utama.size = Vector2.ZERO
		await get_tree().process_frame
	
	# 4. Kunci ukuran kotak yang sudah diukur
	var measured_size: Vector2 = wadah_utama.size
	wadah_utama.custom_minimum_size = measured_size
	
	# 5. Posisikan ekor balon tepat di tengah bawah kotak
	ekor_balon.position.x = (measured_size.x / 2.0) - (ekor_balon.size.x / 2.0)
	ekor_balon.position.y = measured_size.y - 2
	
	# 6. KUNCI UTAMA: Berikan ukuran total ke control_utama & pasang pivot tepat di tengahnya!
	var ukuran_total = ambil_ukuran_balon()
	control_utama.size = ukuran_total
	control_utama.pivot_offset = ukuran_total / 2.0

func tampilkan_dan_ketik() -> void:
	dialogue_label.visible_characters = 0
	
	# Pastikan pivot berada di tengah sebelum scale di-nol-kan
	var ukuran_total = ambil_ukuran_balon()
	control_utama.size = ukuran_total
	control_utama.pivot_offset = ukuran_total / 2.0
	
	# Mulai dari skala 0 di tengah
	control_utama.scale = Vector2.ZERO
	control_utama.modulate.a = 1.0
	
	if tween_animasi and tween_animasi.is_running():
		tween_animasi.kill()
		
	sedang_pop_up = true
	tween_animasi = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_animasi.tween_property(control_utama, "scale", Vector2.ONE, 0.2)
	
	await tween_animasi.finished
	sedang_pop_up = false
	
	dialogue_label.type_out()

func tutup_balon() -> void:
	var ukuran_total = ambil_ukuran_balon()
	control_utama.size = ukuran_total
	control_utama.pivot_offset = ukuran_total / 2.0
	
	if tween_animasi and tween_animasi.is_running():
		tween_animasi.kill()
		
	tween_animasi = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_animasi.tween_property(control_utama, "scale", Vector2.ZERO, 0.15)
	await tween_animasi.finished
	hide()

func ambil_ukuran_balon() -> Vector2:
	var total_lebar = wadah_utama.size.x
	var total_tinggi = wadah_utama.size.y + ekor_balon.size.y
	return Vector2(total_lebar, total_tinggi)

# PERBAIKAN PENTING: Gunakan .position (BUKAN .global_position) agar tidak merusak pivot saat scale berubah!
func atur_posisi_balon(posisi_baru: Vector2) -> void:
	control_utama.position = posisi_baru
