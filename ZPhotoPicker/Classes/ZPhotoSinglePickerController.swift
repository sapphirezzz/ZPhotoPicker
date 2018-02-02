//
//  ZPhotoSinglePickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/31.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoSinglePickerController: UIImagePickerController {
    
    var imageSelectedHandler: ((_ image: UIImage) -> Void)?
    var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
}

private extension ZPhotoSinglePickerController {
    
    func alertPickingImageError() {

        let alertVC = UIAlertController(title: "获取图片失败", message: "图片获取失败，请重新选择~", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .default, handler: { [weak self] _ in

            guard let `self` = self else {return}
            if self.allowsEditing {
                self.popViewController(animated: true)
            }
        }))
        present(alertVC, animated: true, completion: nil)
    }
}

extension ZPhotoSinglePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage
        guard let image = info[key] as? UIImage else {
            self.alertPickingImageError()
            return
        }
        self.dismiss(animated: true, completion: { [weak self] in
            self?.imageSelectedHandler?(image)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
}
