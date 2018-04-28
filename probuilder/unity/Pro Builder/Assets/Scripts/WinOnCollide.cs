using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WinOnCollide : MonoBehaviour {
  public Text text;

	// Use this for initialization
	void Start () {
    text.color = new Color(0, 0, 0, 0);
	}
	
	// Update is called once per frame
	void Update () {
    
	}

  void OnTriggerEnter() {
    text.text = "YOU WIN!";
    text.color = new Color(0, 0, 0, 1);
  }
}
