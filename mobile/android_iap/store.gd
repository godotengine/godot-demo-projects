extends SplitContainer

@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var store_items: HFlowContainer = $VBoxContainer/TabContainer/Store/ItemContainer
@onready var purchased_items: HFlowContainer = $VBoxContainer/TabContainer/PurchasedItems/ItemContainer
@onready var debug_message: RichTextLabel = $DebugMessage

var item_scene: PackedScene = preload("res://item.tscn")
var billing_client: BillingClient
var owned_products: Dictionary = {} # { product_id: purchase_token }

## INAPP products to query
@export var inapp_products: Dictionary[String,Texture]


func _init() -> void:
	billing_client = BillingClient.new()

	# Connect signals
	billing_client.connected.connect(_on_connected)
	billing_client.connect_error.connect(_on_connect_error)
	billing_client.query_product_details_response.connect(_on_query_product_details)
	billing_client.query_purchases_response.connect(_on_query_purchases)
	billing_client.on_purchase_updated.connect(_on_purchase_updated)

	billing_client.start_connection()
	var jni_singleton = JNISingleton.new()
	jni_singleton.add_user_signal("connected")
	jni_singleton.connect(&"connected", _on_connected)


func _on_connected() -> void:
	debug_message.text = str("Billing client connected", "\n")
	billing_client.query_purchases(BillingClient.ProductType.INAPP)
	await billing_client.query_purchases_response
	billing_client.query_product_details(inapp_products.keys(), BillingClient.ProductType.INAPP)

func _on_connect_error(code: int, msg: String) -> void:
	_show_error("Connection failed", code, msg)


func _on_query_product_details(result: Dictionary) -> void:
	if result.response_code != BillingClient.BillingResponseCode.OK:
		_show_error("Product details query failed", result.response_code, result.debug_message)
		return

	debug_message.text += str("\nReceived product details:", result.product_details.size())
	for child in store_items.get_children():
		child.queue_free()

	for product in result.product_details:
		_add_product_card(product)


func _add_product_card(product: Dictionary) -> void:
	var product_id: String = product.product_id
	var price_text: String = _get_price_string(product)
	var name_text: String = product.name
	var icon = inapp_products.get(product_id, preload("res://icon.svg"))

	if not owned_products.has(product_id):
		var item = item_scene.instantiate()
		store_items.add_child(item)
		item.configure(product_id, name_text, price_text, icon, false)
		item.buy_pressed.connect(_on_item_buy_pressed)


func _on_item_buy_pressed(product_id: String) -> void:
	debug_message.text += str("Buying:", product_id, "\n")
	var res = billing_client.purchase(product_id)
	if res.response_code != BillingClient.BillingResponseCode.OK:
		_show_error("Purchase failed", res.response_code, res.debug_message)

func _on_item_consume_pressed(product_id: String) -> void:
	var token = owned_products.get(product_id)
	if not token:
		debug_message.text += str("No token found for", product_id, "\n")
		return

	debug_message.text += str("Consuming:", product_id, "\n")
	billing_client.consume_purchase(token)

	var consume_res = await billing_client.consume_purchase_response
	if consume_res.response_code == BillingClient.BillingResponseCode.OK:
		debug_message.text += str("Consume success:", product_id, "\n")
		owned_products.erase(product_id)
		_refresh_owned_items()
	else:
		_show_error("Consume failed", consume_res.response_code, consume_res.debug_message)


func _on_query_purchases(result: Dictionary) -> void:
	if result.response_code != BillingClient.BillingResponseCode.OK:
		_show_error("Query purchases failed", result.response_code, result.debug_message)
		return

	for purchase in result.purchases:
		_process_purchase(purchase, true)


func _on_purchase_updated(result: Dictionary) -> void:
	if result.response_code != BillingClient.BillingResponseCode.OK:
		_show_error("Purchase update failed", result.response_code, result.debug_message)
		return

	for purchase in result.purchases:
		_process_purchase(purchase)

func _process_purchase(purchase: Dictionary, refresh_owned_items := false) -> void:
	if not purchase:
		return

	for product_id in purchase.product_ids:
		debug_message.text += str("Processing purchase:", product_id, "\n")
		if not purchase.is_acknowledged:
			billing_client.acknowledge_purchase(purchase.purchase_token)
			var ack_res = await billing_client.acknowledge_purchase_response
			if ack_res.response_code != BillingClient.BillingResponseCode.OK:
				_show_error("Acknowledge failed", ack_res.response_code, ack_res.debug_message)
				return

		owned_products[product_id] = purchase.purchase_token
		for child in store_items.get_children():
			if child.product_id == product_id:
				child.queue_free()
				break

	if refresh_owned_items:
		_refresh_owned_items()


func _refresh_owned_items() -> void:
	for i in purchased_items.get_children():
		i.queue_free()

	for id in owned_products.keys():
		var tex = inapp_products.get(id, preload("res://icon.svg"))
		var it = item_scene.instantiate()
		purchased_items.add_child(it)
		it.configure(id, id.capitalize(), "Owned", tex, true)
		it.consume_pressed.connect(_on_item_consume_pressed)


func _show_error(ctx: String, code: int, msg: String) -> void:
	var message = "%s\nCode: %d\n%s" % [ctx, code, msg]
	debug_message.text += message
	printerr(message)


func _on_tab_container_tab_changed(tab: int) -> void:
	match tab:
		0:
			billing_client.query_product_details(inapp_products.keys(), BillingClient.ProductType.INAPP)
		1:
			billing_client.query_purchases(BillingClient.ProductType.INAPP)

func _get_price_string(product: Dictionary) -> String:
	# TODO: Add Support for offers.
	var list = product.get("one_time_purchase_offer_details_list", [])
	for i in list:
		if i.get("offer_id", "") == null:
			return i.get("formatted_price", "N/A")
	return "N/A"


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		billing_client.end_connection()

func _on_exit_pressed() -> void:
	billing_client.end_connection()
	get_tree().quit()
