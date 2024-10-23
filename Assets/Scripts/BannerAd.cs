using GoogleMobileAds.Api;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class BannerAd : MonoBehaviour
{

    BannerView _bannerView;

    public AdPosition BannerPosition;

    /// <summary>
    /// Creates a 320x50 banner view at top of the screen.
    /// </summary>
    public void CreateBannerView(string aAdUnitID)
    {
        Debug.Log("Creating banner view");

        // If we already have a banner, destroy the old one.
        if (_bannerView != null) {
            DestroyAd();
        }

        // Create a 320x50 banner at top of the screen
        _bannerView = new BannerView(aAdUnitID, AdSize.Banner, BannerPosition);
    }


    /// <summary>
    /// Creates the banner view and loads a banner ad.
    /// </summary>
    public void LoadAd(string aAdUnitID)
    {
        // create an instance of a banner view first.
        if (_bannerView == null) {
            CreateBannerView(aAdUnitID);
        }

        // create our request used to load the ad.
        var adRequest = new AdRequest();

        // send the request to load the ad.
        Debug.Log("Loading banner ad.");
        _bannerView.LoadAd(adRequest);
    }

    public void Show()
    {
        if (_bannerView != null)
            _bannerView.Show();
    }

    /// <summary>
    /// Destroys the banner view.
    /// </summary>
    public void DestroyAd()
    {
        if (_bannerView != null) {
            Debug.Log("Destroying banner view.");
            _bannerView.Destroy();
            _bannerView = null;
        }
    }

    private void OnDestroy()
    {
        DestroyAd();
    }
}
