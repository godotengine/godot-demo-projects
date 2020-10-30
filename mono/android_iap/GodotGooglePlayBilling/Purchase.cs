using System;
using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    // https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState
    public enum PurchaseState
    {
        UnspecifiedState = 0,
        Purchased = 1,
        Pending = 2,
    }

    public class Purchase
    {
        public Purchase() { }

        public Purchase(Dictionary purchase)
        {
            foreach (var key in purchase.Keys)
            {
                try
                {
                    switch (key)
                    {
                        case "order_id":
                            OrderId = (string)purchase[key];
                            break;
                        case "package_name":
                            PackageName = (string)purchase[key];
                            break;
                        case "purchase_state":
                            PurchaseState = (PurchaseState)purchase[key];
                            break;
                        case "purchase_time":
                            PurchaseTime = Convert.ToInt64(purchase[key]);
                            break;
                        case "purchase_token":
                            PurchaseToken = (string)purchase[key];
                            break;
                        case "signature":
                            Signature = (string)purchase[key];
                            break;
                        case "sku":
                            Sku = (string)purchase[key];
                            break;
                        case "is_acknowledged":
                            IsAcknowledged = (bool)purchase[key];
                            break;
                        case "is_auto_renewing":
                            IsAutoRenewing = (bool)purchase[key];
                            break;
                    }
                }
                catch (System.Exception ex)
                {
                    GD.Print("Error: ", purchase[key], " -> ", ex.ToString());
                }

            }
        }

        public string OrderId { get; set; }
        public string PackageName { get; set; }
        public PurchaseState PurchaseState { get; set; }
        public long PurchaseTime { get; set; }
        public string PurchaseToken { get; set; }
        public string Signature { get; set; }
        public string Sku { get; set; }
        public bool IsAcknowledged { get; set; }
        public bool IsAutoRenewing { get; set; }
    }
}
