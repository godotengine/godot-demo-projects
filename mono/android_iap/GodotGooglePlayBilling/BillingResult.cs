using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    // https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponseCode
    public enum BillingResponseCode
    {
        // The request has reached the maximum timeout before Google Play responds.
        ServiceTimeout = -3,

        // Requested feature is not supported by Play Store on the current device.
        FeatureNotSupported = -2,

        // Play Store service is not connected now - potentially transient state.
        ServiceDisconnected = -1,

        // Success
        Ok = 0,

        // User pressed back or canceled a dialog
        UserCanceled = 1,

        // Network connection is down
        ServiceUnavailable = 2,

        // Billing API version is not supported for the type requested
        BillingUnavailable = 3,

        // Requested product is not available for purchase
        ItemUnavailable = 4,

        // Invalid arguments provided to the API.
        DeveloperError = 5,

        // Fatal error during the API action
        Error = 6,

        // Failure to purchase since item is already owned
        ItemAlreadyOwned = 7,

        // Failure to consume since item is not owned
        ItemNotOwned = 8,
    }

    public partial class BillingResult
    {
        public BillingResult() { }
        public BillingResult(Dictionary billingResult)
        {
            try
            {
                Status = (int)billingResult["status"];
                ResponseCode = billingResult.ContainsKey("response_code") ? billingResult["response_code"].As<BillingResponseCode>() : null;
                DebugMessage = billingResult.ContainsKey("debug_message") ? billingResult["debug_message"].AsString() : null;
            }
            catch (System.Exception ex)
            {
                GD.Print("BillingResult: ", ex.ToString());
            }
        }

        public int Status { get; set; }
        public BillingResponseCode? ResponseCode { get; set; }
        public string DebugMessage { get; set; }
    }
}
