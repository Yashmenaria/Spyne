//
//  ModelImageCaptured.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//

import RealmSwift
import Foundation

class ModelImageCaptured: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var url: String
    @Persisted var name: String
    @Persisted var captureDate: Date = Date()
//    @Persisted var progress: Float = 0.0
    @Persisted var uploadStatus: String = "Pending" // Pending, Uploading, Completed, Failed
}
