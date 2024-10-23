using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using Unity.Properties;
using UnityEngine;
using UnityEngine.Events;

public class GameControl : MonoBehaviour
{

    [Header("Object References")]
    /// <summary>
    /// GameBoard transform used to locate all the pieces of the game
    /// </summary>
    public BoardController GameBoard = null;
    public ScoreController ScoreController = null;
    public GameObject CelebrationObject = null;


    public UnityEvent OnEndGame;    

    private void Awake()
    {
        //Init game size according to the screen size
        RectTransform rectTransform = GetComponent<RectTransform>();
        // Scale the board in the screen
        float lGameWidth = Screen.width * 0.8f;// margin of 10 % on each side
        float lGameRes = rectTransform.sizeDelta.y / rectTransform.sizeDelta.x;
        rectTransform.sizeDelta = new Vector2(lGameWidth, lGameRes * lGameWidth); //Scale the game according to the screen
        GameBoard.RectTransform.sizeDelta = new Vector2(lGameWidth, lGameWidth);
    }

    private void Start()
    {
        GameBoard.CreateNewPuzzle();
        ScoreController.LoadScore(GameBoard.Size);
    }

    /// <summary>
    /// Shake the pizzle
    /// </summary>
    public void StartShake()
    {
        GameBoard.StartShake();
    }

    /// <summary>
    /// Skip the shake and show the final result instantly
    /// </summary>
    public void SkipShake()
    {
        GameBoard.SkipShake();
    }    

    public void CelebrateEndGame()
    {
        ScoreController.SaveScore(GameBoard.Size);
        CelebrationObject.SetActive(true);
        OnEndGame.Invoke();
    }

    public void ResetGame()
    {
        GameBoard.CreateNewPuzzle();
        ScoreController.LoadScore(GameBoard.Size);
        OnEndGame.Invoke();
    }

    public void IncrementCurrentScore()
    {
        ScoreController.IncrementScore(1);
    }

    public void UpdatePuzzleSize(int aNewPuzzleSize)
    {
        GameBoard.UpdatePuzzleSize(aNewPuzzleSize);
        ScoreController.LoadScore(aNewPuzzleSize); 
    }
}
