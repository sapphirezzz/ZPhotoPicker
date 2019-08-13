//
//  ViewController.swift
//  ZPhotoPicker
//
//  Created by public@mooyoo.com.cn on 02/02/2018.
//  Copyright (c) 2018 public@mooyoo.com.cn. All rights reserved.
//

import UIKit
import ZPhotoPicker
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    private var images: [UIImage] = []
    private var currentImagesIndex: Int = 0
    
    @IBAction func clickAddButton(_ sender: Any) {

        let imagePickedHandler: ((UIImage) -> Void) = { [weak self] image in
            self?.images = []
            self?.currentImagesIndex = 0
            self?.imageView.image = image
        }
        let imagesPickedHandler: (([UIImage]) -> Void) = { [weak self] images in
            self?.images = images
            self?.currentImagesIndex = 0
            self?.imageView.image = images.first
        }
        let cancelledHandler: (() -> Void) = {
            print("Cancelled.")
        }

        let alertVC = UIAlertController(title: nil, message: "请选择类型", preferredStyle: UIDevice.current.model == "iPad" ? .alert : .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照不裁剪", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .camera(allowsEditing: false), imagePickedHandler: imagePickedHandler, cancelledHandler: cancelledHandler)
        }
        let cameraEditableAction = UIAlertAction(title: "拍照需裁剪", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .camera(allowsEditing: true), imagePickedHandler: imagePickedHandler, cancelledHandler: cancelledHandler)
        }
        let photoAction = UIAlertAction(title: "选取照片不裁剪", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .singlePhoto(allowsEditing: false), imagePickedHandler: imagePickedHandler, cancelledHandler: cancelledHandler)
        }
        let photoEditableAction = UIAlertAction(title: "选取照片需裁剪", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .singlePhoto(allowsEditing: true), imagePickedHandler: imagePickedHandler, cancelledHandler: cancelledHandler)
        }
        let photoesAction = UIAlertAction(title: "选取多张照片", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .multiPhotoes(maxCount: 4), imagesPickedHandler: imagesPickedHandler, cancelledHandler: cancelledHandler)
        }
        let multiVideoPhotoesAction = UIAlertAction(title: "选取多个视频/图片", style: .default) { (_) in
            
            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .multiVideoOrPhotoes(maxCount: 4, canMultiSelectVideo: true), imagesPickedHandler: imagesPickedHandler, videosPickedHandler: { (videos) in
                print("videos = ", videos)
            }, cancelledHandler: cancelledHandler)
        }
        let singleVideoPhotoesAction = UIAlertAction(title: "选取一个视频/多个图片", style: .default) { (_) in

            ZPhotoPicker.pickVideoOrPhoto(onViewController: self, type: .multiVideoOrPhotoes(maxCount: 4, canMultiSelectVideo: false), imagesPickedHandler: imagesPickedHandler, videosPickedHandler: { [weak self] (videos) in
                print("videos = ", videos)                
            }, cancelledHandler: cancelledHandler)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertVC.addAction(cameraAction)
        alertVC.addAction(cameraEditableAction)
        alertVC.addAction(photoAction)
        alertVC.addAction(photoEditableAction)
        alertVC.addAction(photoesAction)
        alertVC.addAction(cancelAction)
        alertVC.addAction(multiVideoPhotoesAction)
        alertVC.addAction(singleVideoPhotoesAction)
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
