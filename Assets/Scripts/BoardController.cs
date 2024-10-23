using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class BoardController : MonoBehaviour
{
    #region PUBLIC

    [Header("Object References")]
    /// <summary>
    /// PuzzlePiece object reference used to instantiate all the pieces on the games
    /// </summary>
    public PuzzlePiece PuzzlePiece = null;

    /// <summary>
    /// Shows a preview of the puzzle on top of the board
    /// </summary>
    public Image Preview;

    [Header("Audio")]
    
    ///<summary>
    ///Audio played when a piece moves
    /// </summary>
    public AudioClip MovementAudio;

    /// <summary>
    /// Starting time on the audio clip
    /// </summary>
    public float audioTimeStart;

    /// <summary>
    /// ENd time on the audio clip
    /// </summary>
    public float audioTimeEnd;

    /// <summary>
    /// Volume
    /// </summary>
    [Range(0f, 1f)]
    public float audioVolume;

    [Header("Shake Params")]

    ///<summary>
    ///Moves the game makes when shake the puzzle
    /// </summary>
    public int ShakeMoves = 20;

    /// <summary>
    /// Delay beetween each move when shake
    /// </summary>
    public float ShakeDelay = 0.3f;

    /// <summary>
    /// If true, shake the puzzle instantly
    /// </summary>
    public bool InstantShake = false;


    [Header("Board Params")]
    /// <summary>
    /// Number of pieces per side on the game board
    /// </summary>
    public int Size = 3;

    /// <summary>
    /// Margin on the game board
    /// </summary>
    public float Margin = 0f;

    [Header("Events")]
    ///<summary>
    /// Event called on every piece move
    /// </summary>
    public UnityEvent OnPieceMove;

    /// <summary>
    /// Event called when game ends
    /// </summary>
    public UnityEvent OnEndGame;

    /// <summary>
    /// Event called when shake coroutine ends
    /// </summary>
    public UnityEvent OnShakeFinishes;

    /// <summary>
    /// RectTransform reference of the object
    /// </summary>
    public RectTransform RectTransform {
        get {
            if (mGameRectTransform == null) {
                mGameRectTransform = GetComponent<RectTransform>();
            }
            return mGameRectTransform;
        }
    }

    #endregion

    #region PRIVATE

    /// <summary>
    /// List of pieces in the games
    /// </summary>
    private PuzzlePiece[] pieces;

    /// <summary>
    /// Position of the empty space in the list
    /// </summary>
    private int mEmptyPlace;

    /// <summary>
    /// Position of the fist piece on the boards
    /// </summary>
    private Vector2 mBoardInitialPosition;

    /// <summary>
    /// GameBoard area whithout the margins
    /// </summary>
    private Vector2 mRealGameArea;

    /// <summary>
    /// Preloaded RectTransform reference
    /// </summary>
    private RectTransform mGameRectTransform;

    #endregion

    public void UpdatePuzzleSize(int aNewSize)
    {
        Size = aNewSize;
        DisposePieces();
        CreateNewPuzzle();
    }

    public void CreateNewPuzzle()
    {
        //If already exist one puzzle, dipose it
        if (pieces != null)
            DisposePieces();


        // Init Pieces list
        pieces = new PuzzlePiece[Size * Size];

        mRealGameArea = RectTransform.sizeDelta - new Vector2(2 * Margin, 2 * Margin);

        // Init Pieces Size
        Vector2 lPieceSize = mRealGameArea / Size;
        PuzzlePiece.GetComponent<RectTransform>().sizeDelta = lPieceSize;
        PuzzlePiece.GetComponent<BoxCollider2D>().size = lPieceSize;
        //Init Pieces Position
        float lInitialPositionX = -(mRealGameArea.x / 2f) + (lPieceSize.x / 2f);
        float lInitialPositionY = (mRealGameArea.y / 2f) - (lPieceSize.y / 2f);
        mBoardInitialPosition = new Vector2(lInitialPositionX, lInitialPositionY);

        float lXIncrement = mRealGameArea.x / Size;
        float lYIncrement = mRealGameArea.y / Size;
        //float lPieceUvIncrement = lPieceSize.x / lRealGameArea;

        for (int i = 0; i < Size; ++i) {
            for (int j = 0; j < Size; ++j) {
                if (i == Size - 1 && j == Size - 1) continue;
                // Instantiate a new piece
                PuzzlePiece lPiece = Instantiate(PuzzlePiece);
                lPiece.transform.SetParent(RectTransform);
                lPiece.transform.SetSiblingIndex(0);
                lPiece.transform.localScale = Vector3.one;

                //Set the piece into the position
                RectTransform lRTransform = lPiece.GetComponent<RectTransform>();
                Vector2 lPiecePosition = new Vector2(j * lXIncrement, -i * lYIncrement);
                lRTransform.localPosition = mBoardInitialPosition + lPiecePosition;
                lPiece.gameObject.SetActive(true);

                /* from now on, if the index of a piece is the same as his position in the list, 
                 * we will assume that the piece is in the correct positoin
                */
                lPiece.CorrectPosition = i * Size + j; // Init piece index
                lPiece.CurrentBoardPosition = lPiece.CorrectPosition;
                pieces[lPiece.CorrectPosition] = lPiece; // Save piece in the list

            }
        }

        mEmptyPlace = Size * Size - 1;

        for (int i = 0; i < pieces.Length - 1; i++) {
            pieces[i].Init(Size);
        }

        PuzzlePiece.gameObject.SetActive(false);// to ensure that the reference piece is not visible in the game 

        InstantShake = false;
    }

    private void DisposePieces()
    {
        for (int i = 0; i < pieces.Length; ++i) {
            if (pieces[i] == null) continue; // skip the emply space
            Destroy(pieces[i].gameObject);
            pieces[i] = null;
        }
    }

    /// <summary>
    /// Shake the pizzle
    /// </summary>
    public void StartShake()
    {
        StartCoroutine(Shake(ShakeMoves, ShakeDelay));
    }

    /// <summary>
    /// Skip the shake and show the final result instantly
    /// </summary>
    public void SkipShake()
    {
        InstantShake = true;
    }

    /// <summary>
    /// Moves a piece to the empty space.
    /// </summary>
    /// <param name="aPieceIndex">Position of the piece that sould be moved</param>
    public void MovePiece(int aPieceIndex)
    {
        OnPieceMove.Invoke();
        MovePiece(aPieceIndex, true);
    }

    /// <summary>
    /// Move a piece of the puzzle to the empty space. (Internal use)
    /// </summary>
    /// <param name="aPieceIndex"></param>
    private void MovePiece(int aPieceIndex, bool aCheckEndGame)
    {
        //Block the pieces
        UpdateSurroundingPieces(false);

        PuzzlePiece lSelectedPiece = pieces[aPieceIndex];

        //Move the piece
        float lXIncrement = mRealGameArea.x / Size;
        float lYIncrement = mRealGameArea.y / Size;
        float lYPosition = Mathf.Floor((float)mEmptyPlace / Size);
        float lXPosition = mEmptyPlace % Size;

        lSelectedPiece.MoveTo(mBoardInitialPosition + new Vector2(lXPosition * lXIncrement, -lYPosition * lYIncrement));

        //Change piece positions
        ChangePositions(aPieceIndex, mEmptyPlace);
        mEmptyPlace = aPieceIndex;

        if (aCheckEndGame && CheckEndGame()) {
            OnEndGame.Invoke();
        }
        else {
            UpdateSurroundingPieces(true);
        }

        StartCoroutine(PlayAudio());
    }

    private bool CheckEndGame()
    {
        for (int i = 0; i < pieces.Length - 1; ++i) {
            if (pieces[i] == null || pieces[i].CorrectPosition != i) return false;
        }
        return true;
    }

    /// <summary>
    /// Change pieces beetween two positions in the puzzle
    /// </summary>
    /// <param name="aBoardPosition1">Fisrt position in the puzzle</param>
    /// <param name="aBoardPosition2">Second position in the puzzle</param>
    private void ChangePositions(int aBoardPosition1, int aBoardPosition2)
    {
        PuzzlePiece temp = pieces[aBoardPosition1];
        pieces[aBoardPosition1] = pieces[aBoardPosition2];
        pieces[aBoardPosition2] = temp;

        if (pieces[aBoardPosition1] != null)
            pieces[aBoardPosition1].CurrentBoardPosition = aBoardPosition1;

        if (pieces[aBoardPosition2] != null)
            pieces[aBoardPosition2].CurrentBoardPosition = aBoardPosition2;

    }

    /// <summary>
    /// Enable or Disable the sourroundings of the empty space
    /// </summary>
    /// <param name="aActivate">If true, the surrounding pieces can be selected</param>
    private void UpdateSurroundingPieces(bool aActivate)
    {
        int p1 = mEmptyPlace - 1;
        int p2 = mEmptyPlace + 1;
        int p3 = mEmptyPlace - Size;
        int p4 = mEmptyPlace + Size;

        if (p1 >= 0 && (p1 % Size) < (mEmptyPlace % Size))
            pieces[p1].EnableTouch(aActivate);

        if (p2 < pieces.Length && (p2 % Size) > (mEmptyPlace % Size))
            pieces[p2].EnableTouch(aActivate);

        if (p3 >= 0)
            pieces[p3].EnableTouch(aActivate);

        if (p4 < pieces.Length)
            pieces[p4].EnableTouch(aActivate);

    }

    /// <summary>
    /// Returns a list of positions the player can select to move
    /// </summary>
    /// <returns></returns>
    private int[] GetPossibleMoves()
    {
        List<int> moves = new List<int>();
        int p1 = mEmptyPlace - 1;
        int p2 = mEmptyPlace + 1;
        int p3 = mEmptyPlace - Size;
        int p4 = mEmptyPlace + Size;

        if (p1 >= 0 && (p1 % Size) < (mEmptyPlace % Size))
            moves.Add(p1);

        if (p2 < pieces.Length && (p2 % Size) > (mEmptyPlace % Size))
            moves.Add(p2);

        if (p3 >= 0)
            moves.Add(p3);

        if (p4 < pieces.Length)
            moves.Add(p4);

        return moves.ToArray();
    }

    /// <summary>
    /// Randomly moves the puzzle
    /// </summary>
    /// <param name="aMoves"></param>
    private IEnumerator Shake(int aMoves, float delay = 0f)
    {
        int lPrevEmptyPosition = -1;
        for (int i = 0; i < aMoves; i++) {
            int[] lMoves = GetPossibleMoves();
            int lSelectedMove = -1;
            do {
                lSelectedMove = Random.Range(0, lMoves.Length);
            } while (lMoves[lSelectedMove] == lPrevEmptyPosition);
            lPrevEmptyPosition = mEmptyPlace;
            MovePiece(lMoves[lSelectedMove], false);
            if (!InstantShake) {
                yield return new WaitForSeconds(delay);
            }
        }
        OnShakeFinishes.Invoke();
    }

    /// <summary>
    /// Coroutine used to play an audio when a piece moves
    /// </summary>
    /// <param name="aAudio"></param>
    /// <returns></returns>
    private IEnumerator PlayAudio()
    {
        AudioSource lASource = gameObject.AddComponent<AudioSource>();
        lASource.clip = MovementAudio;
        float lAudioTime = audioTimeEnd - audioTimeStart;

        lASource.loop = false;
        lASource.volume = audioVolume;
        lASource.time = audioTimeStart;
        lASource.Play();

        yield return new WaitForSeconds(lAudioTime);

        lASource.Stop();
        Destroy(lASource);
    }
}
