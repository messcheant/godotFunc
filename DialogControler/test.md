```
func mulai_testing() -> void:
	# Nama kunci ("serigala" & "kucing") harus sama persis dengan nama di file .dialogue
	var list = {
		"serigala": marker_serigala,
		"kucing": marker_kucing
	}
```

  Panggil Singleton DialogueController
```
	DialogueController.mulai(naskah_tes, "mulai_tes", list)
```
  naskah tes = .dialogue
  mulai_tes = label percakapan di .dialogue
  list = marker pada player
  
  
