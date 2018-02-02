//
//  ZPhotoPicker.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/30.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

public protocol ZPhotoPickerDelegate: class {

    func zPhotoPickerDidFinishPickingImage(_ image: UIImage?)
    func zPhotoPickerDidFinishPickingImages(_ images: [UIImage])
    func zPhotoPickerDidCancelPickingImage()
}

extension ZPhotoPickerDelegate {

    func zPhotoPickerDidFinishPickingImage(_ image: UIImage?) {}
    func zPhotoPickerDidFinishPickingImages(_ image: [UIImage]) {}
}

public class ZPhotoPicker {

    public enum PhotoPickType {
        case camera(allowsEditing: Bool)
        case singlePhoto(allowsEditing: Bool)
        case multiPhotoes(maxCount: Int)
    }

    public class func pickPhoto(onViewController controller: UIViewController, type: PhotoPickType, delegate: ZPhotoPickerDelegate) {

        switch type {
        case let .camera(allowsEditing):

            ZPhotoPicker.pickWithZPhotoPicker(onViewController: controller, allowsEditing: allowsEditing, sourceType: .camera, delegate: delegate)
        case let .singlePhoto(allowsEditing):

            ZPhotoPicker.pickWithZPhotoPicker(onViewController: controller, allowsEditing: allowsEditing, sourceType: .photoLibrary, delegate: delegate)
        case let .multiPhotoes(maxCount):
            
            let vc = ZPhotoMutilPickerController(delegate: delegate, maxCount: maxCount)
            controller.present(vc, animated: true, completion: nil)
            break
        }
    }
    
    private class func pickWithZPhotoPicker(onViewController controller: UIViewController, allowsEditing: Bool, sourceType: UIImagePickerControllerSourceType, delegate: ZPhotoPickerDelegate) {

        let pickerVC = ZPhotoSinglePickerController()
        pickerVC.allowsEditing = allowsEditing
        pickerVC.sourceType = sourceType
        pickerVC.delegate = pickerVC
        pickerVC.photoPickerDelegate = delegate
        controller.present(pickerVC, animated: true, completion: nil)
    }
}
