using Godot.Collections;
using Godot;

namespace Android_Iap.GodotGooglePlayBilling
{
    public enum PurchaseType
    {
        InApp,
        Subs
    }

    public class GooglePlayBilling : Node
    {
        [Signal] public delegate void Connected();
        [Signal] public delegate void Disconnected();
        [Signal] public delegate void ConnectError(int code, string message);
        [Signal] public delegate void SkuDetailsQueryCompleted(Array skuDetails);
        [Signal] public delegate void SkuDetailsQueryError(int code, string message);
        [Signal] public delegate void PurchasesUpdated(Array purchases);
        [Signal] public delegate void PurchaseError(int code, string message);
        [Signal] public delegate void PurchaseAcknowledged(string purchaseToken);
        [Signal] public delegate void PurchaseAcknowledgementError(int code, string message);
        [Signal] public delegate void PurchaseConsumed(string purchaseToken);
        [Signal] public delegate void PurchaseConsumption_error(int code, string message, string purchaseToken);

        [Export] public bool AutoReconnect { get; set; }
        [Export] public bool AutoConnect { get; set; }

        private Object _payment;

        public override void _Ready()
        {
            if (Engine.HasSingleton("GodotGooglePlayBilling"))
            {
                GD.Print("GodotGooglePlayBilling HasSingleton");
                _payment = Engine.GetSingleton("GodotGooglePlayBilling");
                // These are all signals supported by the API
                // You can drop some of these based on your needs
                _payment.Connect("connected", this, nameof(OnGodotGooglePlayBilling_connected)); // No params
                _payment.Connect("disconnected", this, nameof(OnGodotGooglePlayBilling_disconnected)); // No params
                _payment.Connect("connect_error", this, nameof(OnGodotGooglePlayBilling_connect_error)); // Response ID (int), Debug message (string)
                _payment.Connect("sku_details_query_completed", this, nameof(OnGodotGooglePlayBilling_sku_details_query_completed)); // SKUs (Array of Dictionary)
                _payment.Connect("sku_details_query_error", this, nameof(OnGodotGooglePlayBilling_sku_details_query_error)); // Response ID (int), Debug message (string), Queried SKUs (string[])
                _payment.Connect("purchases_updated", this, nameof(OnGodotGooglePlayBilling_purchases_updated)); // Purchases (Array of Dictionary)
                _payment.Connect("purchase_error", this, nameof(OnGodotGooglePlayBilling_purchase_error)); // Response ID (int), Debug message (string)
                _payment.Connect("purchase_acknowledged", this, nameof(OnGodotGooglePlayBilling_purchase_acknowledged)); // Purchase token (string)
                _payment.Connect("purchase_acknowledgement_error", this, nameof(OnGodotGooglePlayBilling_purchase_acknowledgement_error)); // Response ID (int), Debug message (string), Purchase token (string)
                _payment.Connect("purchase_consumed", this, nameof(OnGodotGooglePlayBilling_purchase_consumed)); // Purchase token (string)
                _payment.Connect("purchase_consumption_error", this, nameof(OnGodotGooglePlayBilling_purchase_consumption_error)); // Response ID (int), Debug message (string), Purchase token (string)

                if (AutoConnect) StartConnection();
            }
            else
            {
                GD.Print("GPB: Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.");
            }
        }

        #region GooglePlayBilling Methods

        public void StartConnection() => _payment?.Call("startConnection");

        public void EndConnection() => _payment?.Call("endConnection");

        public BillingResult Purchase(string sku)
        {
            if (_payment == null) return null;
            var result = (Dictionary)_payment.Call("purchase", sku);
            return new BillingResult(result);
        }

        public void QuerySkuDetails(string[] querySkuDetails, PurchaseType type) => _payment?.Call("querySkuDetails", querySkuDetails, $"{type}".ToLower());

        public bool IsReady() => (_payment?.Call("isReady") as bool?) ?? false;

        public PurchasesResult QueryPurchases(PurchaseType purchaseType)
        {
            if (_payment == null) return null;
            var result = (Dictionary)_payment.Call("queryPurchases", $"{purchaseType}".ToLower());
            return new PurchasesResult(result);
        }

        public void AcknowledgePurchase(string purchaseToken) => _payment?.Call("acknowledgePurchase", purchaseToken);

        public void ConsumePurchase(string purchaseToken) => _payment?.Call("consumePurchase", purchaseToken);

        #endregion

        #region GodotGooglePlayBilling Signals

        private void OnGodotGooglePlayBilling_connected()
        {
            GD.Print("GodotGooglePlayBilling Connected");
            EmitSignal(nameof(Connected));
        }

        private async void OnGodotGooglePlayBilling_disconnected()
        {
            GD.Print("GodotGooglePlayBilling Disconnected");
            EmitSignal(nameof(Disconnected));

            if (AutoReconnect)
            {
                await ToSignal(GetTree().CreateTimer(10), "timeout");
                StartConnection();
            }
        }

        private void OnGodotGooglePlayBilling_connect_error(int code, string message)
        {
            GD.Print($"GodotGooglePlayBilling ConnectError {code}: {message}");
            EmitSignal(nameof(ConnectError), code, message);
        }

        private void OnGodotGooglePlayBilling_sku_details_query_completed(Array skuDetails)
        {
            GD.Print($"GodotGooglePlayBilling SkuDetailsQueryCompleted {skuDetails}");
            EmitSignal(nameof(SkuDetailsQueryCompleted), skuDetails);
        }

        private void OnGodotGooglePlayBilling_sku_details_query_error(int code, string message)
        {
            GD.Print($"SkuDetailsQueryError error {code}: {message}");
            EmitSignal(nameof(SkuDetailsQueryError), code, message);
        }

        private void OnGodotGooglePlayBilling_purchases_updated(Array purchases)
        {
            GD.Print($"GodotGooglePlayBilling PurchasesUpdated {purchases}");
            EmitSignal(nameof(PurchasesUpdated), purchases);
        }

        private void OnGodotGooglePlayBilling_purchase_error(int code, string message)
        {
            GD.Print($"GodotGooglePlayBilling PurchaseError {code}: {message}");
            EmitSignal(nameof(PurchaseError), code, message);
        }

        private void OnGodotGooglePlayBilling_purchase_acknowledged(string purchaseToken)
        {
            GD.Print($"GodotGooglePlayBilling PurchaseAcknowledged {purchaseToken}");
            EmitSignal(nameof(PurchaseAcknowledged), purchaseToken);
        }

        private void OnGodotGooglePlayBilling_purchase_acknowledgement_error(int code, string message)
        {
            GD.Print($"GodotGooglePlayBilling PurchaseAcknowledgementError error {code}: {message}");
            EmitSignal(nameof(PurchaseAcknowledgementError), code, message);
        }

        private void OnGodotGooglePlayBilling_purchase_consumed(string purchaseToken)
        {
            GD.Print($"GodotGooglePlayBilling PurchaseConsumed successfully: {purchaseToken}");
            EmitSignal(nameof(PurchaseConsumed), purchaseToken);
        }

        private void OnGodotGooglePlayBilling_purchase_consumption_error(int code, string message, string purchaseToken)
        {
            GD.Print($"GodotGooglePlayBilling PurchaseConsumption_error error {code}: {message}, purchase token: {purchaseToken}");
            EmitSignal(nameof(PurchaseConsumption_error), code, message, purchaseToken);
        }

        #endregion
    }
}
