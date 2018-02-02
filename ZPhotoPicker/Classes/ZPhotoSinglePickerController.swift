//
//  ZPhotoSinglePickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/31.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoSinglePickerController: UIImagePickerController {
    
    var imageSelectedHandler: ((_ image: UIImage?) -> Void)?
    var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
}

extension ZPhotoSinglePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage
        let image = info[key] as? UIImage
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
