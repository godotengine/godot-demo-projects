extends PanelContainer

signal buy_pressed(product_id: String)
signal consume_pressed(product_id: String)

@onready var image: TextureRect = $VBoxContainer/Control/image
@onready var name_label: Label = $VBoxContainer/name
@onready var price_label: Label = $VBoxContainer/price
@onready var buy: Button = $VBoxContainer/buy
@onready var consume: Button = $VBoxContainer/consume

var product_id: String = ""

func _ready():
	buy.pressed.connect(_on_buy_pressed)
	consume.pressed.connect(_on_consume_pressed)
	consume.hide()

func configure(_product_id: String, _name: String, _price: String, _texture: Texture, owned: bool=false) -> void:
	product_id = _product_id
	name_label.text = _name
	price_label.text = _price
	image.texture = _texture
	buy.visible = not owned
	consume.visible = owned

func _on_buy_pressed():
	emit_signal("buy_pressed", product_id)

func _on_consume_pressed():
	emit_signal("consume_pressed", product_id)
