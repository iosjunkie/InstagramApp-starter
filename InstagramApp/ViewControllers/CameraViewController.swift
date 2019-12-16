//
//  CameraViewController.swift
//  InstagramApp
//
//  Created by Jules Lee on 14/12/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var simpleCameraView: SimpleCameraView!
    var simpleCamera: SimpleCamera!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        simpleCamera = SimpleCamera(cameraView: simpleCameraView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        simpleCamera.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        simpleCamera.stopSession()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func startCapture(_ sender: UIButton) {
        if simpleCamera.currentCaptureMode == .photo {
            simpleCamera.takePhoto { (image, success) in
                if success {
                    
                }
            }
        }
    }
}
