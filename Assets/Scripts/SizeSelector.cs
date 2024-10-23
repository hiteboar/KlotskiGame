using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class SizeSelector : MonoBehaviour
{
    public TMPro.TextMeshProUGUI TextArea;
    public int[] SizeOptions;
    
    private int mSelectedSize = 0;

    public UnityEvent<int> OnSizeChanged;

    public int GetSelectedSize {
        get {
            return SizeOptions[mSelectedSize];
        }
    }

    public void MoveToNextOption()
    {
        mSelectedSize = (mSelectedSize + 1) % SizeOptions.Length;
        SetText(SizeOptions[mSelectedSize]);
        OnSizeChanged.Invoke(SizeOptions[mSelectedSize]);
    }

    public void MoveToPrevOption()
    {
        --mSelectedSize;
        if (mSelectedSize < 0) mSelectedSize = SizeOptions.Length - 1;
        SetText(SizeOptions[mSelectedSize]);
        OnSizeChanged.Invoke(SizeOptions[mSelectedSize]);
    }

    private void SetText(int aSelectedSize)
    {
        TextArea.text = aSelectedSize + "x" + aSelectedSize;
    }
}
