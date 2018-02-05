//
//  ZPhotoTakingController.swift
//  ZPhotoPicker
//
//  Created by Zack･Zheng on 2018/2/5.
//

import UIKit

class ZPhotoTakingController: UIImagePickerController {

    private var allowsCropping: Bool = false
    private var imageTookHandler: ((_ image: UIImage) -> Void)?
    private var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
}

extension ZPhotoTakingController {
    
    class func takePhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imageTookHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoTakingController()
        vc.allowsCropping = allowsCropping
        vc.allowsEditing = false
        vc.sourceType = .camera
        vc.imageTookHandler = imageTookHandler
        vc.cancelledHandler = cancelledHandler
        vc.delegate = vc
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoTakingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        if allowsCropping {

            let vc = ZPhotoCropperController()
            vc.image = image
            vc.imageCroppedHandler = { [weak vc] image in
                
                vc?.dismiss(animated: false) { [weak self] in

                    self?.dismiss(animated: true) { [weak self] in
                        self?.imageTookHandler?(image)
                    }
                }
            }
            vc.cancelledHandler = { [weak vc] in

                vc?.dismiss(animated: false) { [weak self] in
                    
                    self?.dismiss(animated: true) { [weak self] in
                        self?.cancelledHandler?()
                    }
                }
            }
            vc.transitioningDelegate = vc
            present(vc, animated: true)

        } else {

            dismiss(animated: true) { [weak self] in
                self?.imageTookHandler?(image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
}
