using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    public partial class PurchasesResult : BillingResult
    {
        public PurchasesResult() { }
        public PurchasesResult(Dictionary purchasesResult)
            : base(purchasesResult)
        {
            try
            {
                Purchases = (purchasesResult.ContainsKey("purchases") ? GooglePlayBillingUtils.ConvertPurchaseDictionaryArray(purchasesResult["purchases"].AsGodotArray()) : null);
            }
            catch (System.Exception ex)
            {
                GD.Print("PurchasesResult: ", ex.ToString());
            }
        }

        public Purchase[] Purchases { get; set; }
    }
}
