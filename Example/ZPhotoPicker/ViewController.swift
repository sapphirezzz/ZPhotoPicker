//
//  ViewController.swift
//  ZPhotoPicker
//
//  Created by public@mooyoo.com.cn on 02/02/2018.
//  Copyright (c) 2018 public@mooyoo.com.cn. All rights reserved.
//

import UIKit
import ZPhotoPicker

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    private var images: [UIImage] = []
    private var currentImagesIndex: Int = 0
    
    @IBAction func clickAddButton(_ sender: Any) {
        
        let alertVC = UIAlertController(title: nil, message: "请选择类型", preferredStyle: UIDevice.current.model == "iPad" ? .alert : .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { (_) in
            ZPhotoPicker.pickPhoto(onViewController: self, type: .camera(allowsEditing: false), delegate: self)
        }
        let photoAction = UIAlertAction(title: "选取照片", style: .default) { (_) in
            ZPhotoPicker.pickPhoto(onViewController: self, type: .singlePhoto(allowsEditing: false), delegate: self)
        }
        let photoesAction = UIAlertAction(title: "选取多张照片", style: .default) { (_) in
            ZPhotoPicker.pickPhoto(onViewController: self, type: .multiPhotoes(maxCount: 4), delegate: self)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoAction)
        alertVC.addAction(photoesAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func clickChangeButton(_ sender: Any) {
        guard images.count > 0 else {return}
        if currentImagesIndex >= images.count - 1 {
            currentImagesIndex = 0
        } else {
            currentImagesIndex += 1
        }
        imageView.image = images[currentImagesIndex]
    }
}

extension ViewController: ZPhotoPickerDelegate {
    
    func zPhotoPickerDidFinishPickingImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func zPhotoPickerDidCancelPickingImage() {
        print("\(self) cancelled.")
    }
    
    func zPhotoPickerDidFinishPickingImages(_ images: [UIImage]) {
        self.images = images
        self.currentImagesIndex = 0
        imageView.image = images.first
    }
}
