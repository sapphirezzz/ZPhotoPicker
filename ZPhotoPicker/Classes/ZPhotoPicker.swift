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

    public class func pickPhoto(onViewController controller: UIViewController, type: PhotoPickType, imagePickedHandler: ((_ image: UIImage) -> Void)? = nil, imagesPickedHandler: ((_ image: [UIImage]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {

        switch type {
        case let .camera(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoTakingController.takePhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler)
        case let .singlePhoto(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoSinglePickerController.pickPhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler)
            
        case let .multiPhotoes(maxCount):
            
            ZPhotoMutilPickerController.pickPhotoes(onPresentingViewController: controller, maxCount: maxCount, imagesPickedHandler: imagesPickedHandler ?? {_ in}, cancelledHandler: cancelledHandler)
            break
        }
    }

    private class func alertUnsupportTypeError(onViewController controller: UIViewController) {

        let alertVC = UIAlertController(title: "不支持的方式", message: "该设备不支持以该方式选取图片~", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
}
