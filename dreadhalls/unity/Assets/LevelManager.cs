using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LevelManager : MonoBehaviour {
  public static int level = 0;
  public Text levelText;

	// Use this for initialization
	void Start () {
    level += 1;
    levelText.text = "Level " + level.ToString();
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
