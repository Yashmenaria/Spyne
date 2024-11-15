//
//  ImageUploader.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//

import Foundation
import Combine
import RealmSwift
import UIKit

class ImageUploader {
    static let shared = ImageUploader()

    private var uploadTasks: [URLSessionUploadTask] = []

    func uploadImage(_ image: ModelImageCaptured) -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let url = URL(string: "https://www.clippr.ai/api/upload") else {
                return promise(.failure(URLError(.badURL)))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let fileURL = URL(fileURLWithPath: image.url)
            let uploadTask = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    // Update Realm status
                    let realm = try! Realm()
                    try! realm.write {
                        image.uploadStatus = "Completed"
                    }
                    promise(.success(()))
                }
            }

            self.uploadTasks.append(uploadTask)
            uploadTask.resume()
        }
        .eraseToAnyPublisher()
    }
}


extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        // Set placeholder if provided
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        // Fetch the image data in the background
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Check for errors
            if let error = error {
                print("Failed to fetch image: \(error.localizedDescription)")
                return
            }
            
            // Validate data and create image
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Failed to decode image data.")
                return
            }
            
            // Update the UIImageView on the main thread
            DispatchQueue.main.async {
                self?.image = downloadedImage
            }
        }.resume()
    }
}
