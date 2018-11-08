using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FreeCam : MonoBehaviour {

	[Header("Input")]
	[SerializeField] KeyCode keyForward;
	[SerializeField] KeyCode keyBack;
	[SerializeField] KeyCode keyLeft;
	[SerializeField] KeyCode keyRight;
	[SerializeField] KeyCode keyUp;
	[SerializeField] KeyCode keyDown;
	[SerializeField] KeyCode keyFast;
	[SerializeField] KeyCode keySlow;

	[Header("Params")]
	[SerializeField] float normalSpeed;
	[SerializeField] float fastSpeed;
	[SerializeField] float slowSpeed;
	[SerializeField] float mouseSensitivity;

	float pan, tilt;

	void Start () {
		Cursor.lockState = CursorLockMode.Locked;
	}

	void Reset () {
		keyForward = KeyCode.W;
		keyBack = KeyCode.S;
		keyLeft = KeyCode.A;
		keyRight = KeyCode.D;
		keyUp = KeyCode.E;
		keyDown = KeyCode.Q;
		keyFast = KeyCode.LeftShift;
		keySlow = KeyCode.LeftControl;
		normalSpeed = 2f;
		fastSpeed = 8f;
		slowSpeed = 0.5f;
		mouseSensitivity = 3f;
	}
	
	void Update () {
		MouseLook(GetMouseMovement() * mouseSensitivity);
		Move(GetInputVector() * GetMoveSpeed());
		if(Input.GetKeyDown(KeyCode.Escape)) Cursor.lockState = CursorLockMode.None;
		if(Input.GetKeyDown(KeyCode.Mouse0)) Cursor.lockState = CursorLockMode.Locked;
	}

	void MouseLook (Vector2 mouseDelta) {
		if(Cursor.lockState == CursorLockMode.Locked){
			pan = Mathf.Repeat(pan + mouseDelta.x, 360f);
			tilt = Mathf.Clamp(tilt + mouseDelta.y, -90, 90);
			transform.rotation = Quaternion.identity;
			transform.Rotate(Vector3.up * pan);
			transform.Rotate(Vector3.left * tilt);
		}
	}

	void Move (Vector3 inputVector) {
		Vector3 moveVector = transform.TransformDirection(inputVector);
		transform.position += moveVector * Time.deltaTime;
	}

	Vector2 GetMouseMovement () {
		float mouseX = Input.GetAxisRaw("Mouse X");
		float mouseY = Input.GetAxisRaw("Mouse Y");
		return new Vector2(mouseX, mouseY);
	}

	Vector3 GetInputVector () {
		Vector3 output = Vector3.zero;
		if(Input.GetKey(keyForward)) output += Vector3.forward;
		if(Input.GetKey(keyBack)) output += Vector3.back;
		if(Input.GetKey(keyLeft)) output += Vector3.left;
		if(Input.GetKey(keyRight)) output += Vector3.right;
		if(Input.GetKey(keyUp)) output += Vector3.up;
		if(Input.GetKey(keyDown)) output += Vector3.down;
		if(output.sqrMagnitude > 1f) output = output.normalized;
		return output;
	}

	float GetMoveSpeed () {
		if(Input.GetKey(keyFast)) return fastSpeed;
		if(Input.GetKey(keySlow)) return slowSpeed;
		return normalSpeed;
	}

}
