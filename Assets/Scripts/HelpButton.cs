using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HelpButton : MonoBehaviour
{
    public GameObject PreviewImage;

    private void OnMouseOver()
    {
        if (Input.GetMouseButtonDown(0)) {
            PreviewImage.SetActive(true);
        }
    }

    private void OnMouseUp()
    {
        PreviewImage.SetActive(false);
    }
}
