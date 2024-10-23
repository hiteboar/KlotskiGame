using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

public class ScoreController : MonoBehaviour
{
    public TMPro.TextMeshProUGUI BestScoreTextValue;
    public TMPro.TextMeshProUGUI CurrentScoreTextValue;

    private int mCurrentScore = 0;
    private int mBestScore = 0;
    private GameData mGameData;

    private const string SAVE_PATH = "/Saves/";

    public void Awake()
    {
        LoadGamedata();
    }

    public void IncrementScore(int aIncrement)
    {
        mCurrentScore += aIncrement;
        CurrentScoreTextValue.text = mCurrentScore.ToString();
    }

    public void LoadScore(int aGameSize)
    {
        if (mGameData == null)
            LoadGamedata();

        mCurrentScore = 0;

        UpdateScoreText(aGameSize);
    }

    public void SaveScore(int aGameSize)
    {
        mGameData.UpdateScore(mCurrentScore, aGameSize);
        string lSavePath = Application.persistentDataPath + SAVE_PATH + "GameData.dat";

        FileStream dataStream = new FileStream(lSavePath, FileMode.Create);
        BinaryFormatter converter = new BinaryFormatter();
        converter.Serialize(dataStream, mGameData);
        dataStream.Close();

        mCurrentScore = 0;
        UpdateScoreText(aGameSize);
    }

    private void UpdateScoreText(int aGameSize)
    {
     
        CurrentScoreTextValue.text = (mCurrentScore == 0) ? "--" : mCurrentScore.ToString();

        string lBestScoreValue = "";
        if (mGameData.GetScoreForSize(aGameSize) == 0) {
            lBestScoreValue = "--";
        }
        else {
            lBestScoreValue = mGameData.GetScoreForSize(aGameSize).ToString();
        }
        BestScoreTextValue.text = lBestScoreValue;

    }

    private void LoadGamedata()
    {
        string lSavePath = Application.persistentDataPath + SAVE_PATH + "GameData.dat";

        if (!Directory.Exists(Application.persistentDataPath + SAVE_PATH)) {
            Directory.CreateDirectory(Application.persistentDataPath + SAVE_PATH);
        }

        FileStream dataStream = new FileStream(lSavePath, FileMode.OpenOrCreate);
        try {
            BinaryFormatter converter = new BinaryFormatter();
            mGameData = (GameData)converter.Deserialize(dataStream);
        }
        catch (SerializationException ex) {
            // If someting went wrong when load, simply create a new score object
            mGameData = new GameData();
        }
        dataStream.Close();
    }

    /// <summary>
    /// Object used to save the game data
    /// </summary>
    [System.Serializable]
    private class GameData
    {
        private Dictionary<int, int> mScoreTable = null;

        public int GetScoreForSize(int aSize)
        {
            EnsureScoreTableSize(aSize);
            return mScoreTable[aSize];
        }

        public void ResetScore()
        {
            mScoreTable = new Dictionary<int, int>();
        }

        public void UpdateScore(int aNewScore, int aSize)
        {
            EnsureScoreTableSize(aSize);
            if (mScoreTable[aSize] == 0 || mScoreTable[aSize] > aNewScore) mScoreTable[aSize] = aNewScore;
        }

        /// <summary>
        /// Ensure that an specific size exists in scoretables
        /// </summary>
        /// <param name="aSize"></param>
        private void EnsureScoreTableSize(int aSize)
        {
            if (mScoreTable == null) {
                mScoreTable = new Dictionary<int, int>();
            }

            if (!mScoreTable.ContainsKey(aSize)) {
                mScoreTable.Add(aSize, 0);
            }
        }
    }
}
