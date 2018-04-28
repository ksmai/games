using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class RestartOnFall : MonoBehaviour {

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
    Debug.Log(transform.position.y);
    if (transform.position.y < -10) {
      SceneManager.LoadScene("MainScene");
    }
	}
}
