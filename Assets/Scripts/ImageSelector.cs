using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Events;

public class ImageSelector : MonoBehaviour
{

    public Material PiecesMaterial;
    public TMPro.TextMeshProUGUI ImageName;
    public Texture[] Images;

    public UnityEvent OnImageChanged;

    private int mSelectedIndex = 0;

    private void Awake()
    {
        LoadSelectedImage();
    }

    public void SelectNextImage()
    {
        mSelectedIndex++;
        if (mSelectedIndex >= Images.Length)
            mSelectedIndex = 0;
        LoadSelectedImage();
    }

    public void SelectPrevImage()
    {
        mSelectedIndex--;
        if (mSelectedIndex < 0)
            mSelectedIndex = Images.Length;
        LoadSelectedImage();
    }

    private void LoadSelectedImage()
    {
        PiecesMaterial.SetTexture("_MainTex", Images[mSelectedIndex]);
        ImageName.text = Images[mSelectedIndex].name.ToString();
        OnImageChanged.Invoke();
    }


}
