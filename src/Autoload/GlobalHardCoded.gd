extends Node

var texts_root: String = "./"
var basic_lessons_location: String = "{0}Texts/Lessons/Basic"
var intermediate_lessons_location: String = "{0}Texts/Lessons/Intermediate"
var advanced_lessons_location: String = "{0}Texts/Lessons/Advanced"
var extra_lessons_location: String = "{0}Texts/Lessons/Extra"

var eng_chars = "`1234567890-=qwertyuiop[]\\asdfghjkl;'zxcvbnm,./ "

var eng_shift_chars = '~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?'
var mm_chars = "`၁၂၃၄၅၆၇၈၉၀-=ဆတနမအပကငသစဟဩ၏ေျိ်ါ့ြုူး'ဖထခလဘညာ,./ "
var mm_shift_chars = 'ဎဍၒဋ$%^ရ*()_+ဈဝဣ၎ဤ၌ဥ၍ဿဏဧဪ\\ဗှီ္ွံဲဒဓဂ"ဇဌဃဠယဉဦ၊။?'
#preload("res://Texts/Lessons/Basic/00000001.cfg")

func _ready() -> void:
	if OS.get_name() == "Web":
		texts_root = "res://"
	
	basic_lessons_location = basic_lessons_location.format([texts_root])
	intermediate_lessons_location = intermediate_lessons_location.format([texts_root])
	advanced_lessons_location = advanced_lessons_location.format([texts_root])
	extra_lessons_location = extra_lessons_location.format([texts_root])
	
	print(basic_lessons_location)
