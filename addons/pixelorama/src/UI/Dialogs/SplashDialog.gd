tool
extends WindowDialog


var artworks := {
	"Roroto Sic" : [preload("res://addons/pixelorama/assets/graphics/splash_screen/artworks/roroto.png"), "https://www.instagram.com/roroto_sic/"],
	"jess.mpz" : [preload("res://addons/pixelorama/assets/graphics/splash_screen/artworks/jessmpz.png"), "https://www.instagram.com/jess.mpz/"],
	"Wishdream" : [preload("res://addons/pixelorama/assets/graphics/splash_screen/artworks/wishdream.png"), "https://twitter.com/WishdreamStar"]
}

var chosen_artwork = ""

var latin_font = preload("res://addons/pixelorama/assets/fonts/Roboto-Small.tres")
var cjk_font = preload("res://addons/pixelorama/assets/fonts/CJK/DroidSansFallback-Small.tres")

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	global = get_node(Constants.NODE_PATH_GLOBAL)

func _on_SplashDialog_about_to_show() -> void:
	var splash_art_texturerect : TextureRect = global.find_node_by_name(self, "SplashArt")
	var art_by_label : Button = global.find_node_by_name(self, "ArtistName")
	var show_on_startup_button : CheckBox = global.find_node_by_name(self, "ShowOnStartup")
	var copyright_label : Label = global.find_node_by_name(self, "CopyrightLabel")

	if global.config_cache.has_section_key("preferences", "startup"):
		show_on_startup_button.pressed = !global.config_cache.get_value("preferences", "startup")
	window_title = "Pixelorama" + " " + global.current_version

	chosen_artwork = artworks.keys()[randi() % artworks.size()]
	splash_art_texturerect.texture = artworks[chosen_artwork][0]

	art_by_label.text = tr("Art by: %s") % chosen_artwork
	art_by_label.hint_tooltip = artworks[chosen_artwork][1]

	if global.is_cjk(TranslationServer.get_locale()):
		show_on_startup_button.add_font_override("font", cjk_font)
		copyright_label.add_font_override("font", cjk_font)
	else:
		show_on_startup_button.add_font_override("font", latin_font)
		copyright_label.add_font_override("font", latin_font)

	get_stylebox("panel", "WindowDialog").bg_color = global.control.theme.get_stylebox("panel", "WindowDialog").bg_color
	get_stylebox("panel", "WindowDialog").border_color = global.control.theme.get_stylebox("panel", "WindowDialog").border_color
	if OS.get_name() == "HTML5":
		$Contents/ButtonsPatronsLogos/Buttons/OpenLastBtn.visible = false


func _on_ArtCredits_pressed() -> void:
	OS.shell_open(artworks[chosen_artwork][1])


func _on_ShowOnStartup_toggled(pressed : bool) -> void:
	if pressed:
		global.config_cache.set_value("preferences", "startup", false)
	else:
		global.config_cache.set_value("preferences", "startup", true)
	global.config_cache.save("user://cache.ini")


func _on_PatreonButton_pressed() -> void:
	OS.shell_open("https://www.patreon.com/OramaInteractive")


func _on_GithubButton_pressed() -> void:
	OS.shell_open("https://github.com/Orama-Interactive/Pixelorama")


func _on_DiscordButton_pressed() -> void:
	OS.shell_open("https://discord.gg/GTMtr8s")


func _on_NewBtn_pressed() -> void:
	visible = false
	global.top_menu_container.file_menu_id_pressed(0)


func _on_OpenBtn__pressed() -> void:
	visible = false
	global.top_menu_container.file_menu_id_pressed(1)


func _on_OpenLastBtn_pressed() -> void:
	visible = false
	global.top_menu_container.file_menu_id_pressed(2)
