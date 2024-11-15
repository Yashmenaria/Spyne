//
//  CapturedImageCell.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//

import UIKit

class CapturedImageCell: UITableViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    static let identifier = "CapturedImageCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }

    func configure(with image: ModelImageCaptured) {
        thumbnailImageView.image = UIImage(contentsOfFile: image.url)
        statusLabel.text = image.uploadStatus
        // Adjust progress view (mock data for now)
        if image.uploadStatus == "Uploading" {
            progressView.progress = 0.5
        } else if image.uploadStatus == "Completed" {
            progressView.progress = 1.0
        } else {
            progressView.progress = 0.0
        }
    }
}
