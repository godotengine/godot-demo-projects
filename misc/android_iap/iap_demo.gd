
extends Control

onready var alert = get_node("alert")

func _ready():
	iap.set_auto_consume(false)
	iap.connect("purchase_success", self, "on_purchase_success")
	iap.connect("purchase_fail", self, "on_purchase_fail")
	iap.connect("purchase_cancel", self, "on_purchase_cancel")
	iap.connect("purchase_owned", self, "on_purchase_owned")
	iap.connect("has_purchased", self, "on_has_purchased")
	iap.connect("consume_success", self, "on_consume_success")
	iap.connect("consume_fail", self, "on_consume_fail")
	iap.connect("sku_details_complete", self, "on_sku_details_complete")
	
	get_node("purchase").connect("pressed", self, "button_purchase")
	get_node("consume").connect("pressed", self, "button_consume")
	get_node("request").connect("pressed", self, "button_request")
	get_node("query").connect("pressed", self, "button_query")


func on_purchase_success(item_name):
	alert.set_text("Purchase success : " + item_name)
	alert.popup()

func on_purchase_fail():
	alert.set_text("Purchase fail")
	alert.popup()

func on_purchase_cancel():
	alert.set_text("Purchase cancel")
	alert.popup()

func on_purchase_owned(item_name):
	alert.set_text("Purchase owned : " + item_name)
	alert.popup()

func on_has_purchased(item_name):
	if item_name == null:
		alert.set_text("Don't have purchased item")
	else:
		alert.set_text("Has purchased : " + item_name)
	alert.popup()

func on_consume_success(item_name):
	alert.set_text("Consume success : " + item_name)
	alert.popup()

func on_consume_fail():
	alert.set_text("Try to request purchased first")
	alert.popup()

func on_sku_details_complete():
	alert.set_text("Got detail info : " + to_json(iap.sku_details["item_test_a"]))
	alert.popup()


func button_purchase():
	iap.purchase("item_tess")

func button_consume():
	iap.consume("item_tess")

func button_request():
	iap.request_purchased()

func button_query():
	iap.sku_details_query(["item_test_a", "item_test_b"])

