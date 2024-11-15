//
//  ImageCapturedVC.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//

import UIKit
import AVFoundation
import Realm
import RealmSwift

class ImageCaptureVC: UIViewController {
    @IBOutlet var btnCapture: UIButton!
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Camera not available")
            return
        }

        captureSession.addInput(input)

        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
        
    }

    @objc func captureImage() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        if let photoPreviewType = photoSettings.__availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    
    @IBAction func btnBackTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCapturedClicked(_ sender: UIButton) {
        self.captureImage()
    }
}

extension ImageCaptureVC: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        let imageName = UUID().uuidString + ".jpg"
        let fileURL = self.saveImageToDocumentsDirectory(image)
        
        // Save metadata to Realm
        let capturedImage = ModelImageCaptured()
        capturedImage.url = fileURL
        capturedImage.name = imageName
        
        ImageListVC.shared.viewModel.addImage(fileURL)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func saveImageToDocumentsDirectory(_ image: UIImage) -> String {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let filePath = documentsDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: filePath)
        }
        return filePath.path
    }
}

extension Notification.Name {
    static let didCaptureImage = Notification.Name("didCaptureImage")
}
