using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class PuzzlePiece : MonoBehaviour
{
    [Header("Events")]
    public UnityEvent<int> OnPieceTouched;

    private AudioSource mAudioSource;
    private float mAudioTime;

    private int mCorrentBoardPosition = -1;
    private int mCurrentBoardPosition = -1;

    private bool mActivePiece = false;

    private RectTransform mRectTransform;

    public RectTransform RectTransform {
        get {
            if (mRectTransform == null) {
                mRectTransform = GetComponent<RectTransform>();
            }
            return mRectTransform;
        }
    }

    /// <summary>
    /// Get / Set the correct position of the piece. Only can set the first time
    /// </summary>
    public int CorrectPosition {

        get {
            return mCorrentBoardPosition;
        }

        set {
            if (mCorrentBoardPosition == -1) {
                mCorrentBoardPosition = value;
            }
        }
    }

    public int CurrentBoardPosition {
        get {
            return mCurrentBoardPosition;
        }

        set {
            mCurrentBoardPosition = value;
        }
    }

    public bool IsActive {
        get {
            return mActivePiece;
        }
    }

    public void Init(int aBoardSize)
    {
        // Calculate the image portion for the piece
        float lYPosition = Mathf.Floor((float)CorrectPosition / aBoardSize);
        float lXPosition = CorrectPosition % aBoardSize;
        Material lMaterial = Instantiate(GetComponent<Image>().material);//Create a unique instance of the material so we can modify it without affect the others
        lMaterial.SetInt("_PuzzleSize", aBoardSize);
        lMaterial.SetVector("_PiecePosition", new Vector4(lXPosition, lYPosition, 0f, 0f));
        GetComponent<Image>().material = lMaterial;

        //Show the piece number
        //Text.text = (mCorrentBoardPosition + 1).ToString();
    }

    public void EnableTouch(bool aCanTouch)
    {
        mActivePiece = aCanTouch;
    }

    public void OnMouseUp()
    {
        if (mActivePiece) {
            OnPieceTouched.Invoke(CurrentBoardPosition);
            //StartCoroutine(PlayAudio());
        }
    }

    public void MoveTo(Vector2 aPosition)
    {
        RectTransform.localPosition = aPosition;
    }

    public void OnDestroy()
    {
        OnPieceTouched.RemoveAllListeners();
    }
}
