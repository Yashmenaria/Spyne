//
//  ImageListVC.swift
//  Spyne assignment
//
//  Created by Yashish on 13/11/24.
//

import UIKit
import AVKit
import Realm
import RealmSwift
import Combine

class ImageListVC: UIViewController {
    
    @IBOutlet weak var tblImages: UITableView!
    
    static let shared: ImageListVC = ImageListVC()
    
    var viewModel = ImageCapturedViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tblImages.reloadData()
    }
    
    private func setupUI() {
        self.tblImages.delegate = self
        self.tblImages.dataSource = self
    }
    
    @IBAction func btnAddImagewasTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ImageCaptureVC") as? ImageCaptureVC {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}


extension ImageListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objData = viewModel.images[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CapturedImageCell", for: indexPath) as? CapturedImageCell
        cell?.imageView?.loadImage(from: objData.url)
        cell?.configure(with: objData)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let image = viewModel.images[indexPath.row]
        if image.uploadStatus == "Failed" {
            viewModel.retryUpload(for: image)
        }
        
        self.tblImages.deselectRow(at: indexPath, animated: true)
    }
    
}
