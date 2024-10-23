using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GoogleMobileAds.Api;
using JetBrains.Annotations;

public class GoogleAdsManager : MonoBehaviour
{
    public BannerAd[] banners;

    [SerializeField]
    private string AndroidAdID;
    [SerializeField]
    private string iphoneAdID;
    
    private bool stopTimer;

    public void Awake()
    {
        // Initialize the Google Mobile Ads SDK.
        MobileAds.Initialize((InitializationStatus initStatus) => {
            for(int i = 0; i < banners.Length; i++) {
#if UNITY_ANDROID
                banners[i].LoadAd(AndroidAdID);
#else
                banners[i].LoadAd(iPhoneAdID);
#endif
                banners[i].Show();
            }
        });

        stopTimer = false;
        //StartCoroutine(AdTimer());
    }

    public void ReloadAds()
    {
        for (int i = 0; i < banners.Length; i++) {
            banners[i].DestroyAd();
#if UNITY_ANDROID
            banners[i].LoadAd(AndroidAdID);
#else
            banners[i].LoadAd(iPhoneAdID);
#endif
            banners[i].Show();
        }
    }

    private IEnumerator AdTimer()
    {
        do {
            yield return new WaitForSecondsRealtime(30);
            ReloadAds();
        } while (!stopTimer);
    }
}
