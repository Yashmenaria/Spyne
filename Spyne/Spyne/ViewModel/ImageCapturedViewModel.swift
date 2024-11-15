//
//  ImageCapturedViewModel.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//


import Combine
import Realm
import RealmSwift
import Foundation

class ImageCapturedViewModel {
    private var realm: Realm
    var images: Results<ModelImageCaptured>

    init() {
        self.realm = try! Realm()
        self.images = realm.objects(ModelImageCaptured.self).sorted(byKeyPath: "captureDate", ascending: false)
    }

    func addImage(_ imagePath: String) {
        let newImage = ModelImageCaptured()
        newImage.url = imagePath
        newImage.uploadStatus = "Pending"
        newImage.captureDate = Date()
        newImage.id = UUID().uuidString
        print("Image is adding")

        try! realm.write {
            realm.add(newImage)
        }
        
        uploadImage(image: newImage)
    }

//    func updateProgress(for image: ModelImageCaptured, progress: Float) {
//        try! realm.write {
//            image.progress = progress
//            if progress == 1.0 {
//                image.uploadStatus = "Completed"
//            } else {
//                image.uploadStatus = "Uploading"
//            }
//        }
//    }

    func updateUploadStatus(for image: ModelImageCaptured, status: String) {
        try! realm.write {
            image.uploadStatus = status
            ImageListVC.shared.tblImages?.reloadData()
        }
    }

    func retryUpload(for image: ModelImageCaptured) {
        uploadImage(image: image)
    }

    func uploadImage(image: ModelImageCaptured) {
        guard image.uploadStatus != "Completed" else { return }
        
        self.updateUploadStatus(for: image, status: "Uploading")

        let uploadURL = URL(string: "https://www.clippr.ai/api/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = try? Data(contentsOf: URL(fileURLWithPath: image.url))
        guard let data = imageData else {
            DispatchQueue.main.async {
                self.updateUploadStatus(for: image, status: "Failed")
            }
            return
        }
        
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(UUID().uuidString).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let task = URLSession.shared.uploadTask(with: request, from: body as Data) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.updateUploadStatus(for: image, status: "Failed")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.updateUploadStatus(for: image, status: "Failed")
                }
                return
            }

            // Assuming the response contains the uploaded image URL
            if let data = data,
               let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let uploadedURL = jsonResponse["uploadedImageUrl"] as? String {
                
                DispatchQueue.main.async {
                    do {
                        let realm = try Realm()
                        try realm.write {
                            image.url = uploadedURL
                            image.uploadStatus = "Completed"
                            ImageListVC.shared.tblImages.reloadData()
                        }
                    } catch {
                        print("Error updating image URL in Realm: \(error.localizedDescription)")
                    }
                }
            }
        }

        task.resume()
    }
}

