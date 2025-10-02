extends Control

const TEST_ITEM_SKU = "my_in_app_purchase_sku"

@onready var alert_dialog: AcceptDialog = $AlertDialog
@onready var label: Label = $Label

var payment: Object = null
var test_item_purchase_token := ""


func _ready() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		label.text += "\n\n\nTest item SKU: %s" % TEST_ITEM_SKU

		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connected.connect(_on_connected)
		# No params.
		payment.disconnected.connect(_on_disconnected)
		# Response ID (int), Debug message (string).
		payment.connect_error.connect(_on_connect_error)
		# Purchases (Dictionary[]).
		payment.purchases_updated.connect(_on_purchases_updated)
		# Response ID (int), Debug message (string).
		payment.purchase_error.connect(_on_purchase_error)
		# SKUs (Dictionary[]).
		payment.sku_details_query_completed.connect(_on_sku_details_query_completed)
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.sku_details_query_error.connect(_on_sku_details_query_error)
		# Purchase token (string).
		payment.purchase_acknowledged.connect(_on_purchase_acknowledged)
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		# Purchase token (string).
		payment.purchase_consumed.connect(_on_purchase_consumed)
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.purchase_consumption_error.connect(_on_purchase_consumption_error)
		# Purchases (Dictionary[])
		payment.query_purchases_response.connect(_on_query_purchases_response)
		payment.startConnection()
	else:
		show_alert('Android IAP support is not enabled.\n\nMake sure you have enabled "Custom Build" and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings!\nThis application will not work otherwise.')


func show_alert(text: String) -> void:
	alert_dialog.dialog_text = text
	alert_dialog.popup_centered_clamped(Vector2i(600, 0))
	$QuerySkuDetailsButton.disabled = true
	$PurchaseButton.disabled = true
	$ConsumeButton.disabled = true


func _on_connected() -> void:
	print("PurchaseManager connected")
	# Use "subs" for subscriptions.
	payment.queryPurchases("inapp")


func _on_query_purchases_response(query_result: Dictionary) -> void:
	if query_result.status == OK:
		for purchase: Dictionary in query_result.purchases:
			# We must acknowledge all puchases.
			# See https://developer.android.com/google/play/billing/integrate#process for more information
			if not purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.acknowledgePurchase(purchase.purchase_token)
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)


func _on_sku_details_query_completed(sku_details: Array) -> void:
	for available_sku: Dictionary in sku_details:
		show_alert(JSON.stringify(available_sku))


func _on_purchases_updated(purchases: Array) -> void:
	print("Purchases updated: %s" % JSON.stringify(purchases))

	# See `_on_connected()`.
	for purchase: Dictionary in purchases:
		if not purchase.is_acknowledged:
			print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
			payment.acknowledgePurchase(purchase.purchase_token)

	if not purchases.is_empty():
		test_item_purchase_token = purchases[purchases.size() - 1].purchase_token


func _on_purchase_acknowledged(purchase_token: String) -> void:
	print("Purchase acknowledged: %s" % purchase_token)


func _on_purchase_consumed(purchase_token: String) -> void:
	show_alert("Purchase consumed successfully: %s" % purchase_token)


func _on_connect_error(code: int, message: String) -> void:
	show_alert("Connect error %d: %s" % [code, message])


func _on_purchase_error(code: int, message: String) -> void:
	show_alert("Purchase error %d: %s" % [code, message])


func _on_purchase_acknowledgement_error(code: int, message: String) -> void:
	show_alert("Purchase acknowledgement error %d: %s" % [code, message])


func _on_purchase_consumption_error(code: int, message: String, purchase_token: String) -> void:
	show_alert("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


func _on_sku_details_query_error(code: int, message: String) -> void:
	show_alert("SKU details query error %d: %s" % [code, message])


func _on_disconnected() -> void:
	show_alert("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	await get_tree().create_timer(10).timeout
	payment.startConnection()


# GUI
func _on_QuerySkuDetailsButton_pressed() -> void:
	# Use "subs" for subscriptions.
	payment.querySkuDetails([TEST_ITEM_SKU], "inapp")


func _on_PurchaseButton_pressed() -> void:
	var response: Dictionary = payment.purchase(TEST_ITEM_SKU)
	if response.status != OK:
		show_alert("Purchase error %s: %s" % [response.response_code, response.debug_message])


func _on_ConsumeButton_pressed() -> void:
	if test_item_purchase_token == null:
		show_alert("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
		return

	payment.consumePurchase(test_item_purchase_token)
