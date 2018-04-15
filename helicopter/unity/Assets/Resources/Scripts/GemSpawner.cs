using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemSpawner : MonoBehaviour {
  public GameObject[] prefabs;

	// Use this for initialization
	void Start () {
    StartCoroutine(SpawnGems());
	}
	
	// Update is called once per frame
	void Update () {
		
	}

  IEnumerator SpawnGems() {
    while (true) {
      yield return new WaitForSeconds(Random.Range(15, 25));
      Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
    }
  }
}
