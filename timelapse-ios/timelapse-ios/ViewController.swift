//
//  ViewController.swift
//  timelapse-ios
//
//  Created by Daniel on 10/23/18.
//
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	var _picker = UIImagePickerController()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		UIApplication.shared.isIdleTimerDisabled = true
		_picker.sourceType = UIImagePickerControllerSourceType.camera
		_picker.cameraFlashMode = .off
		_picker.showsCameraControls = false
		_picker.delegate = self
		Timer.scheduledTimer(
			timeInterval: 900,
			target: self,
			selector: #selector(ViewController.presentPicker),
			userInfo: nil,
			repeats: true
		)
		Timer.scheduledTimer(
			timeInterval: 5,
			target: self,
			selector: #selector(ViewController.presentPicker),
			userInfo: nil,
			repeats: false
		)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func presentPicker() {
		NSLog("presenting picker")
		self.present(_picker, animated: false, completion: nil)
		Timer.scheduledTimer(
			timeInterval: 5,
			target: self,
			selector: #selector(ViewController.takePicture),
			userInfo: nil,
			repeats: false
		)
		NSLog("presented picker")
	}

	func takePicture() {
		NSLog("taking picture")
		self._picker.takePicture()
		NSLog("took picture")
	}

	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [String : Any]
	) {
		NSLog("saving image");
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			dismiss(animated: false, completion: nil)
			NSLog("saved image");
		}
		else { NSLog("couldn't save image"); }
	}

}

