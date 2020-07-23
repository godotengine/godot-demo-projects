using Android_Iap.GodotGooglePlayBilling;
using Godot;
using CoreGeneric = System.Collections.Generic;
using System.Linq;
using System;

namespace Android_Iap
{
    /*
    test skus
    android.test.purchased
    android.test.canceled
    android.test.refunded
    android.test.item_unavailable
    */
    public class Main : Node2D
    {
        private readonly string[] ArrInAppProductsSKUs = new string[]
        {
            "android.test.purchased",
            "android.test.canceled",
            "android.test.refunded",
            "android.test.item_unavailable"
        };


        private Button _buyPotionButton;
        private Label _totalPotionsLabel;

        private Panel _panel;
        private Label _processLabel;
        private Label _thanksLabel;

        private ProgressBar _playerLife;
        private StyleBoxFlat _playerLifeStyleBoxFlat;

        private GooglePlayBilling _googlePlayBilling;
        private int _totalPotion = 5;

        CoreGeneric.Dictionary<string, string> _purchases = new CoreGeneric.Dictionary<string, string>();

        public override void _Ready()
        {
            _googlePlayBilling = GetNode<GooglePlayBilling>("GooglePlayBilling");

            _buyPotionButton = GetNode<Button>("VBoxContainer2/BuyPotionButton");
            _totalPotionsLabel = GetNode<Label>("VBoxContainer/Label");

            _panel = GetNode<Panel>("Panel");
            _processLabel = GetNode<Label>("Panel/ProcessLabel");
            _thanksLabel = GetNode<Label>("Panel/ThanksLabel");

            _playerLife = GetNode<ProgressBar>("Sprite/ProgressBar");

            _playerLifeStyleBoxFlat = _playerLife.Get("custom_styles/fg") as StyleBoxFlat;
            _playerLifeStyleBoxFlat.BgColor = Colors.Red.LinearInterpolate(Colors.Green, 1);

            _playerLife.Value = 1;

            _panel.Hide();
            _processLabel.Hide();
            _thanksLabel.Hide();
            _buyPotionButton.Hide();
            _totalPotionsLabel.Text = $"{_totalPotion} Potions";
        }

        public override void _Process(float delta)
        {
            if (_playerLife.Value > 0.5)
            {
                _playerLife.Value -= delta;
            }
            else if (_playerLife.Value > 0.2)
            {
                _playerLife.Value -= delta / 2;
            }
            else if (_playerLife.Value > 0.1)
            {
                _playerLife.Value -= delta / 4;
            }

            _playerLifeStyleBoxFlat.BgColor = Colors.Red.LinearInterpolate(Colors.Green, Convert.ToSingle(_playerLife.Value));
        }

        private void OnUsePotionButton_pressed()
        {
            if (_totalPotion > 0)
            {
                _totalPotion -= 1;
                _totalPotionsLabel.Text = $"{_totalPotion} Potions";
                _playerLifeStyleBoxFlat.BgColor = Colors.Red.LinearInterpolate(Colors.Green, Convert.ToSingle(_playerLife.Value));

                _playerLife.Value += 20;
            }
        }

        private void OnBuyPotionButton_pressed()
        {
            var result = _googlePlayBilling.Purchase("android.test.purchased");
            if (result != null && result.Status == (int)Error.Ok)
            {
                GD.Print("Bought");
            }
            else
            {
                GD.Print("Failed");
            }
        }

        private void OnButton1_pressed()
        {
            var result = _googlePlayBilling.Purchase("android.test.canceled");
            if (result != null && result.Status == (int)Error.Ok)
            {
                GD.Print("Bought");
            }
            else
            {
                GD.Print("Failed");
            }
        }
        private void OnButton2_pressed()
        {
            var result = _googlePlayBilling.Purchase("android.test.refunded");
            if (result != null && result.Status == (int)Error.Ok)
            {
                GD.Print("Bought");
            }
            else
            {
                GD.Print("Failed");
            }
        }
        private void OnButton3_pressed()
        {
            var result = _googlePlayBilling.Purchase("android.test.item_unavailable");
            if (result != null && result.Status == (int)Error.Ok)
            {
                GD.Print("Bought");
            }
            else
            {
                GD.Print("Failed");
            }
        }

        private void OnOkButton_pressed()
        {
            _panel.Hide();
            _processLabel.Hide();
            _thanksLabel.Hide();
        }

        private void OnGooglePlayBilling_Connected()
        {
            _googlePlayBilling.QuerySkuDetails(ArrInAppProductsSKUs, PurchaseType.InApp);

            var purchasesResult = _googlePlayBilling.QueryPurchases(PurchaseType.InApp);
            if (purchasesResult.Status == (int)Error.Ok)
            {
                foreach (var purchase in purchasesResult.Purchases)
                {
                    _purchases.Add(purchase.PurchaseToken, purchase.Sku);
                    // We only expect this SKU
                    if (purchase.Sku == "android.test.purchased")
                    {
                        _googlePlayBilling.AcknowledgePurchase(purchase.PurchaseToken);
                    }
                }
            }
            else
            {
                GD.Print($"Purchase query failed: {purchasesResult.ResponseCode} - {purchasesResult.DebugMessage}");
            }
        }

        private void OnGooglePlayBilling_SkuDetailsQueryCompleted(Godot.Collections.Array arrSkuDetails)
        {
            var skuDetails = GooglePlayBillingUtils.ConvertSkuDetailsDictionaryArray(arrSkuDetails);
            foreach (var sku in skuDetails)
            {
                switch (sku.Sku)
                {
                    // our fake potion
                    case "android.test.purchased":
                        _buyPotionButton.Text = $"Buy {sku.Price}";
                        _buyPotionButton.Show();
                        break;
                }
            }
        }

        private void OnGooglePlayBilling_PurchasesUpdated(Godot.Collections.Array arrPurchases)
        {
            _panel.Show();
            _processLabel.Show();
            _thanksLabel.Hide();

            var purchases = GooglePlayBillingUtils.ConvertPurchaseDictionaryArray(arrPurchases);

            foreach (var purchase in purchases)
            {
                _purchases.Add(purchase.PurchaseToken, purchase.Sku);
                // We only expect this SKU
                if (purchase.Sku == "android.test.purchased")
                {
                    _googlePlayBilling.AcknowledgePurchase(purchase.PurchaseToken);
                }
            }
        }

        private void OnGooglePlayBilling_PurchaseAcknowledged(string purchaseToken)
        {
            _googlePlayBilling.ConsumePurchase(purchaseToken);
        }

        private void OnGooglePlayBilling_PurchaseConsumed(string purchaseToken)
        {
            if (_purchases[purchaseToken] == "android.test.purchased")
            {
                _totalPotion += 5;
                _totalPotionsLabel.Text = $"{_totalPotion} Potions";
                _purchases.Remove(purchaseToken);

                _processLabel.Hide();
                _thanksLabel.Show();

            }
            GD.Print("OnGooglePlayBilling_PurchaseConsumed ", purchaseToken);
        }
    }
}
