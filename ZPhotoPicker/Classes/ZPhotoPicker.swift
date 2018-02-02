//
//  ZPhotoPicker.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/30.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

public class ZPhotoPicker {

    public enum PhotoPickType {
        case camera(allowsEditing: Bool)
        case singlePhoto(allowsEditing: Bool)
        case multiPhotoes(maxCount: Int)
    }

    public class func pickPhoto(onViewController controller: UIViewController, type: PhotoPickType, imageSelectedHandler: ((_ image: UIImage?) -> Void)? = nil, imagesSelectedHandler: ((_ image: [UIImage]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {

        switch type {
        case let .camera(allowsEditing):

            ZPhotoPicker.pickWithSinglePicker(onViewController: controller, allowsEditing: allowsEditing, sourceType: .camera, imageSelectedHandler: imageSelectedHandler, cancelledHandler: cancelledHandler)
        case let .singlePhoto(allowsEditing):

            ZPhotoPicker.pickWithSinglePicker(onViewController: controller, allowsEditing: allowsEditing, sourceType: .photoLibrary, imageSelectedHandler: imageSelectedHandler, cancelledHandler: cancelledHandler)
        case let .multiPhotoes(maxCount):
            
            let vc = ZPhotoMutilPickerController(imagesSelectedHandler: imagesSelectedHandler, cancelledHandler: cancelledHandler, maxCount: maxCount)
            controller.present(vc, animated: true, completion: nil)
            break
        }
    }
    
    private class func pickWithSinglePicker(onViewController controller: UIViewController, allowsEditing: Bool, sourceType: UIImagePickerControllerSourceType, imageSelectedHandler: ((_ image: UIImage?) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {

        let pickerVC = ZPhotoSinglePickerController()
        pickerVC.allowsEditing = allowsEditing
        pickerVC.sourceType = sourceType
        pickerVC.delegate = pickerVC
        pickerVC.imageSelectedHandler = imageSelectedHandler
        pickerVC.cancelledHandler = cancelledHandler
        controller.present(pickerVC, animated: true, completion: nil)
    }
}
