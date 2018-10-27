//
//  ViewController.swift
//  timelapse-ios
//
//  Created by Daniel on 10/23/18.
//
//

import UIKit

let OAUTH2_TOKEN = "put your google photos oauth2 token here"

class ViewController:
	UIViewController,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate
{
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
		Timer.scheduledTimer(
			timeInterval: 10,
			target: self,
			selector: #selector(ViewController.takePicture),
			userInfo: nil,
			repeats: true
		)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func presentPicker() {
		NSLog("presenting picker")
		self.present(_picker, animated: false)
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
		NSLog("getting image")
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			dismiss(animated: false)
			NSLog("got image")
			self.upload(image: image)
		}
		else { NSLog("couldn't get image") }
	}

	func fileName() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "timelapse-ios_" + UIDevice().name + "_yyyy-MM-dd_HH-mm-ss"
		return formatter.string(from: Date())
	}

	func upload(image: UIImage) {
		NSLog("upload starting")
		let fileName = self.fileName()
		var request = URLRequest(url: URL(string: "https://photoslibrary.googleapis.com/v1/uploads")!)
		request.httpMethod = "POST"
		request.addValue("Bearer " + OAUTH2_TOKEN,
			forHTTPHeaderField: "Authorization")
		request.addValue("application/octet-stream",
			forHTTPHeaderField: "Content-type")
		request.addValue(fileName,
			forHTTPHeaderField: "X-Goog-Upload-File-Name")
		request.addValue("raw",
			forHTTPHeaderField: "X-Goog-Upload-Protocol:")
		request.httpBody = UIImagePNGRepresentation(image)
		URLSession.shared.dataTask(
			with: request,
			completionHandler: { (data, response, error) in
				if error != nil {
					NSLog("upload failed")
					return
				}
				NSLog("upload succeeded")
				self.createMediaItem(
					uploadToken: String(data: data!, encoding: .utf8)!,
					fileName: fileName
				)
			}
		)
		NSLog("upload started")
	}

	func createMediaItem(uploadToken: String, fileName: String) {
		NSLog("create media item starting")
		var request = URLRequest(url: URL(string: "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate")!)
		request.httpMethod = "POST"
		request.addValue("Bearer " + OAUTH2_TOKEN,
			forHTTPHeaderField: "Authorization")
		request.addValue("application/json",
			forHTTPHeaderField: "Content-type")
		request.httpBody = ("{" +
			"\"newMediaItems\": [{" +
			  "\"description\": \"" + fileName + "\"," +
			  "\"simpleMediaItem\": {\"uploadToken\": \"" + uploadToken + "\"}" +
			"}]" +
		"}").data(using: .utf8)
		URLSession.shared.dataTask(
			with: request,
			completionHandler: { (data, response, error) in
				if error != nil {
					NSLog("create media item failed")
					return
				}
				NSLog("create media item succeeded")
			}
		)
		NSLog("create media item started")
	}
}
