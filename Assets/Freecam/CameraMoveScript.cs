using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using UnityEditor;

public class CameraMoveScript : MonoBehaviour {

	[Header("Input")]
	public KeyCode keyForwards;
	public KeyCode keyBackwards;
	public KeyCode keyLeft;
	public KeyCode keyRight;
	public KeyCode keyUp;
	public KeyCode keyDown;
	public KeyCode keyFast;
	public KeyCode keySlow;
	public KeyCode keyLightToggle;
	public KeyCode keyReset;
	[Header("Params")]
	public Camera cam;
	public Light torch;
	public float normalSpeed;
	public float fastSpeed;
	public float slowSpeed;
	public float mouseSensitivity;

	private bool mouseLookEnabled;

	private Vector3 startPos;
	private Quaternion startRot;
	private Vector3 camStartRot;

	void Start () {
		Cursor.lockState = CursorLockMode.Locked;
		mouseLookEnabled = true;
		if(torch != null) torch.gameObject.SetActive(false);
		startPos = transform.position;
		startRot = transform.rotation;
		camStartRot = cam.transform.localEulerAngles;
	}
	
	void Update () {
		if(mouseLookEnabled) MouseLook();
		Movement();
		if(Input.GetKeyDown(keyLightToggle) && (torch != null)) torch.gameObject.SetActive(!torch.gameObject.activeSelf);
		if(Input.GetKeyDown(KeyCode.Escape)){
			//if(!mouseLookEnabled) UnityEditor.EditorApplication.isPlaying = false;
			//else mouseLookEnabled = false;
			Cursor.lockState = CursorLockMode.None;
			mouseLookEnabled = false;
		}
		if(Input.GetKeyDown(KeyCode.Mouse0)){
			Cursor.lockState = CursorLockMode.Locked;
			mouseLookEnabled = true;
		}
		if(Input.GetKeyDown(keyReset)){
			transform.position = startPos;
			transform.rotation = startRot;
			cam.transform.localEulerAngles = camStartRot;
		}
	}

	private void MouseLook(){
		Vector2 mouse = GetMouseMovement() * mouseSensitivity;
		transform.Rotate(new Vector3(0f, mouse.x, 0f));
		cam.transform.Rotate(new Vector3(mouse.y, 0f, 0f) * (-1f));
	}

	private Vector2 GetMouseMovement(){
		float mouseX = Input.GetAxisRaw("Mouse X");
		float mouseY = Input.GetAxisRaw("Mouse Y");
		return new Vector2(mouseX, mouseY);
	}

	private void Movement(){
		float moveSpeed = GetMoveSpeed();
		Vector3 inputVector = GetInputVector();
		Vector3 moveVector = cam.transform.TransformDirection(inputVector) * moveSpeed;
		transform.position += moveVector * Time.deltaTime;
	}

	private float GetMoveSpeed(){
		if(Input.GetKey(keyFast)) return fastSpeed;
		if(Input.GetKey(keySlow)) return slowSpeed;
		return normalSpeed;
	}

	private Vector3 GetInputVector(){
		Vector3 output = Vector3.zero;
		if(Input.GetKey(keyForwards)) output += Vector3.forward;
		if(Input.GetKey(keyBackwards)) output += Vector3.back;
		if(Input.GetKey(keyLeft)) output += Vector3.left;
		if(Input.GetKey(keyRight)) output += Vector3.right;
		if(Input.GetKey(keyUp)) output += Vector3.up;
		if(Input.GetKey(keyDown)) output += Vector3.down;
		return output;
	}
}
