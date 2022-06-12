using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    public static class GooglePlayBillingUtils
    {
        public static Purchase[] ConvertPurchaseDictionaryArray(Array arrPurchases)
        {
            if (arrPurchases == null) return null;
            var purchases = new Purchase[arrPurchases.Count];
            for (int i = 0; i < arrPurchases.Count; i++)
            {
                purchases[i] = new Purchase((Dictionary)arrPurchases[i]);
            }

            return purchases;
        }

        public static SkuDetails[] ConvertSkuDetailsDictionaryArray(Array arrSkuDetails)
        {
            if (arrSkuDetails == null) return null;
            var skusDetails = new SkuDetails[arrSkuDetails.Count];
            for (int i = 0; i < arrSkuDetails.Count; i++)
            {
                skusDetails[i] = new SkuDetails((Dictionary)arrSkuDetails[i]);
            }

            return skusDetails;
        }
    }
}
