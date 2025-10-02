using AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling;
using Godot;
using System.Linq;
using System;
using Array = Godot.Collections.Array;

namespace AndroidInAppPurchasesWithCSharp
{
    public partial class Main : Control
    {
        const string TestItemSku = "my_in_app_purchase_sku";

        private AcceptDialog _alertDialog;
        private Label _label;

        private GooglePlayBilling _payment;

        private string _testItemPurchaseToken;

        public override void _Ready()
        {
            _payment = GetNode<GooglePlayBilling>("GooglePlayBilling");
            _alertDialog = GetNode<AcceptDialog>("AlertDialog");
            _label = GetNode<Label>("Label");

            if (_payment.IsAvailable)
            {
                _label.Text += $"\n\n\nTest item SKU: {TestItemSku}";

                // No params.
                _payment.Connect(GooglePlayBilling.SignalName.Connected,
                    Callable.From(OnConnected));
                // No params.
                _payment.Connect(GooglePlayBilling.SignalName.Disconnected,
                    Callable.From(OnDisconnected));
                // Response ID (int), Debug message (string).
                _payment.Connect(GooglePlayBilling.SignalName.ConnectError,
                    Callable.From<int,string>(OnConnectError));
                // Purchases (Dictionary[]).
                _payment.Connect(GooglePlayBilling.SignalName.PurchasesUpdated,
                    Callable.From<Array>(OnPurchasesUpdated));
                // Response ID (int), Debug message (string).
                _payment.Connect(GooglePlayBilling.SignalName.PurchaseError,
                    Callable.From<int,string>(OnPurchaseError));
                // SKUs (Dictionary[]).
                _payment.Connect(GooglePlayBilling.SignalName.SkuDetailsQueryCompleted,
                    Callable.From<Array>(OnSkuDetailsQueryCompleted));
                // Response ID (int), Debug message (string), Queried SKUs (string[]).
                _payment.Connect(GooglePlayBilling.SignalName.SkuDetailsQueryError,
                    Callable.From<int,string, string[]>(OnSkuDetailsQueryError));
                // Purchase token (string).
                _payment.Connect(GooglePlayBilling.SignalName.PurchaseAcknowledged,
                    Callable.From<string>(OnPurchaseAcknowledged));
                // Response ID (int), Debug message (string).
                _payment.Connect(GooglePlayBilling.SignalName.PurchaseAcknowledgementError,
                    Callable.From<int,string>(OnPurchaseAcknowledgementError));
                // Purchase token (string).
                _payment.Connect(GooglePlayBilling.SignalName.PurchaseConsumed,
                    Callable.From<string>(OnPurchaseConsumed));
                // Response ID (int), Debug message (string), Purchase token (string).
                _payment.Connect(GooglePlayBilling.SignalName.PurchaseConsumptionError,
                    Callable.From<int,string,string>(OnPurchaseConsumptionError));
                _payment.StartConnection();
            }
            else
            {
                ShowAlert("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.");
            }
        }

        private void ShowAlert(string text)
        {
            _alertDialog.DialogText = text;
            _alertDialog.PopupCentered();
        }

        private void OnConnected()
        {
            GD.Print("PurchaseManager connected");

            // We must acknowledge all puchases.
            // See https://developer.android.com/google/play/billing/integrate#process for more information
            var purchasesResult = _payment.QueryPurchases(PurchaseType.InApp);
            if (purchasesResult.Status == (int)Error.Ok)
            {
                foreach (var purchase in purchasesResult.Purchases)
                {
                    if (!purchase.IsAcknowledged)
                    {
                        GD.Print($"Purchase {purchase.Sku} has not been acknowledged. Acknowledging...");
                        _payment.AcknowledgePurchase(purchase.PurchaseToken);
                    }
                }
            }
            else
            {
                GD.Print($"Purchase query failed: {purchasesResult.ResponseCode} - {purchasesResult.DebugMessage}");
            }
        }

        private async void OnDisconnected()
        {
            ShowAlert("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...");
            await ToSignal(GetTree().CreateTimer(10), "timeout");
            _payment.StartConnection();
        }

        private void OnConnectError(int code, string message)
        {
            ShowAlert("PurchaseManager connect error");
        }

        private void OnPurchasesUpdated(Godot.Collections.Array arrPurchases)
        {
            GD.Print($"Purchases updated: {Json.Stringify(arrPurchases)}");

            // See OnConnected
            var purchases = GooglePlayBillingUtils.ConvertPurchaseDictionaryArray(arrPurchases);

            foreach (var purchase in purchases)
            {
                if (!purchase.IsAcknowledged)
                {
                    GD.Print($"Purchase {purchase.Sku} has not been acknowledged. Acknowledging...");
                    _payment.AcknowledgePurchase(purchase.PurchaseToken);
                }
            }

            if (purchases.Length > 0)
            {
                _testItemPurchaseToken = purchases.Last().PurchaseToken;
            }
        }

        private void OnPurchaseError(int code, string message)
        {
            ShowAlert($"Purchase error {code}: {message}");
        }

        private void OnSkuDetailsQueryCompleted(Godot.Collections.Array arrSkuDetails)
        {
            ShowAlert(Json.Stringify(arrSkuDetails));

            var skuDetails = GooglePlayBillingUtils.ConvertSkuDetailsDictionaryArray(arrSkuDetails);
            foreach (var skuDetail in skuDetails)
            {
                GD.Print($"Sku {skuDetail.Sku}");
            }
        }

        private void OnSkuDetailsQueryError(int code, string message, string[] querySkuDetails)
        {
            ShowAlert($"SKU details query error {code}: {message}");
        }

        private void OnPurchaseAcknowledged(string purchaseToken)
        {
            ShowAlert($"Purchase acknowledged: {purchaseToken}");
        }

        private void OnPurchaseAcknowledgementError(int code, string message)
        {
            ShowAlert($"Purchase acknowledgement error {code}: {message}");
        }

        private void OnPurchaseConsumed(string purchaseToken)
        {
            ShowAlert($"Purchase consumed successfully: {purchaseToken}");
        }

        private void OnPurchaseConsumptionError(int code, string message, string purchaseToken)
        {
            ShowAlert($"Purchase acknowledgement error {code}: {message}");
        }

        // GUI
        private void OnQuerySkuDetailsButton_pressed()
        {
            _payment.QuerySkuDetails(new string[] { TestItemSku }, PurchaseType.InApp); // Use "subs" for subscriptions.
        }

        private void OnPurchaseButton_pressed()
        {
            var response = _payment.Purchase(TestItemSku);
            if (response != null && response.Status != (int)Error.Ok)
            {
                ShowAlert($"Purchase error {response.ResponseCode} {response.DebugMessage}");
            }
        }

        private void OnConsumeButton_pressed()
        {
            if (string.IsNullOrEmpty(_testItemPurchaseToken))
            {
                ShowAlert("You need to set 'test_item_purchase_token' first! (either by hand or in code)");
                return;
            }

            _payment.ConsumePurchase(_testItemPurchaseToken);
        }
    }
}
