using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    public class PurchasesResult : BillingResult
    {
        public PurchasesResult() { }
        public PurchasesResult(Dictionary purchasesResult)
            : base(purchasesResult)
        {
            try
            {
                Purchases = (purchasesResult.Contains("purchases") ? GooglePlayBillingUtils.ConvertPurchaseDictionaryArray((Array)purchasesResult["purchases"]) : null);
            }
            catch (System.Exception ex)
            {
                GD.Print("PurchasesResult: ", ex.ToString());
            }
        }

        public Purchase[] Purchases { get; set; }
    }
}
