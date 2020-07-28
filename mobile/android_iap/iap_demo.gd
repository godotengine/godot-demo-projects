extends Control

const TEST_ITEM_SKU = "my_in_app_purchase_sku"

onready var alert_dialog = $AlertDialog
onready var label = $Label

var payment = null
var test_item_purchase_token = null

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		label.text += "\n\n\nTest item SKU: %s" % TEST_ITEM_SKU

		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connect("connected", self, "_on_connected")
		# No params.
		payment.connect("disconnected", self, "_on_disconnected")
		# Response ID (int), Debug message (string).
		payment.connect("connect_error", self, "_on_connect_error")
		# Purchases (Dictionary[]).
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		# Response ID (int), Debug message (string).
		payment.connect("purchase_error", self, "_on_purchase_error")
		# SKUs (Dictionary[]).
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed")
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error")
		# Purchase token (string).
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		# Purchase token (string).
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		payment.startConnection()
	else:
		show_alert("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")


func show_alert(text):
	alert_dialog.dialog_text = text
	alert_dialog.popup_centered()


func _on_connected():
	print("PurchaseManager connected")

	# We must acknowledge all puchases.
	# See https://developer.android.com/google/play/billing/integrate#process for more information
	var query = payment.queryPurchases("inapp") # Use "subs" for subscriptions.
	if query.status == OK:
		for purchase in query.purchases:
			if !purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.acknowledgePurchase(purchase.purchase_token)
	else:
		print("Purchase query failed: %d" % query.status)


func _on_sku_details_query_completed(sku_details):
	for available_sku in sku_details:
		show_alert(to_json(available_sku))


func _on_purchases_updated(purchases):
	print("Purchases updated: %s" % to_json(purchases))

	# See _on_connected
	for purchase in purchases:
		if !purchase.is_acknowledged:
			print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
			payment.acknowledgePurchase(purchase.purchase_token)

	if purchases.size() > 0:
		test_item_purchase_token = purchases[purchases.size() - 1].purchase_token


func _on_purchase_acknowledged(purchase_token):
	print("Purchase acknowledged: %s" % purchase_token)


func _on_purchase_consumed(purchase_token):
	show_alert("Purchase consumed successfully: %s" % purchase_token)


func _on_purchase_error(code, message):
	show_alert("Purchase error %d: %s" % [code, message])


func _on_purchase_acknowledgement_error(code, message):
	show_alert("Purchase acknowledgement error %d: %s" % [code, message])


func _on_purchase_consumption_error(code, message, purchase_token):
	show_alert("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


func _on_sku_details_query_error(code, message):
	show_alert("SKU details query error %d: %s" % [code, message])


func _on_disconnected():
	show_alert("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	yield(get_tree().create_timer(10), "timeout")
	payment.startConnection()


# GUI
func _on_QuerySkuDetailsButton_pressed():
	payment.querySkuDetails([TEST_ITEM_SKU], "inapp") # Use "subs" for subscriptions.


func _on_PurchaseButton_pressed():
	var response = payment.purchase(TEST_ITEM_SKU)
	if response.status != OK:
		show_alert("Purchase error %s: %s" % [response.response_code, response.debug_message])


func _on_ConsumeButton_pressed():
	if test_item_purchase_token == null:
		show_alert("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
		return

	payment.consumePurchase(test_item_purchase_token)
