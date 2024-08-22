using System;
using Godot;
using Godot.Collections;

namespace AndroidInAppPurchasesWithCSharp.GodotGooglePlayBilling
{
    public partial class SkuDetails
    {
        public SkuDetails() { }

        public SkuDetails(Dictionary skuDetails)
        {
            foreach (var key in skuDetails.Keys)
            {
                try
                {
                    switch (key.AsString())
                    {
                        case "sku":
                            Sku = (string)skuDetails[key];
                            break;
                        case "title":
                            Title = (string)skuDetails[key];
                            break;
                        case "description":
                            Description = (string)skuDetails[key];
                            break;
                        case "price":
                            Price = (string)skuDetails[key];
                            break;
                        case "price_currency_code":
                            PriceCurrencyCode = (string)skuDetails[key];
                            break;
                        case "price_amount_micros":
                            PriceAmountMicros = Convert.ToInt64(skuDetails[key]);
                            break;
                        case "free_trial_period":
                            FreeTrialPeriod = (string)skuDetails[key];
                            break;
                        case "icon_url":
                            IconUrl = (string)skuDetails[key];
                            break;
                        case "introductory_price":
                            IntroductoryPrice = (string)skuDetails[key];
                            break;
                        case "introductory_price_amount_micros":
                            IntroductoryPriceAmountMicros = Convert.ToInt64(skuDetails[key]);
                            break;
                        case "introductory_price_cycles":
                            IntroductoryPriceCycles = (int)skuDetails[key];
                            break;
                        case "introductory_price_period":
                            IntroductoryPricePeriod = (string)skuDetails[key];
                            break;
                        case "original_price":
                            OriginalPrice = (string)skuDetails[key];
                            break;
                        case "original_price_amount_micros":
                            OriginalPriceAmountMicros = Convert.ToInt64(skuDetails[key]);
                            break;
                        case "subscription_period":
                            SubscriptionPeriod = (string)skuDetails[key];
                            break;
                        case "type":
                            switch(skuDetails[key].AsString())
                            {
                                case "inapp":
                                    Type = PurchaseType.InApp;
                                    break;
                                case "subs":
                                    Type = PurchaseType.Subs;
                                    break;
                            }
                            break;
                    }
                }
                catch (System.Exception ex)
                {
                    GD.Print("Error: ", skuDetails[key], " -> ", ex.ToString());
                }
            }
        }

        public string Sku { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Price { get; set; }
        public string PriceCurrencyCode { get; set; }
        public long PriceAmountMicros { get; set; }
        public string FreeTrialPeriod { get; set; }
        public string IconUrl { get; set; }
        public string IntroductoryPrice { get; set; }
        public long IntroductoryPriceAmountMicros { get; set; }
        public int IntroductoryPriceCycles { get; set; }
        public string IntroductoryPricePeriod { get; set; }
        public string OriginalPrice { get; set; }
        public long OriginalPriceAmountMicros { get; set; }
        public string SubscriptionPeriod { get; set; }
        public PurchaseType Type { get; set; }
    }
}
