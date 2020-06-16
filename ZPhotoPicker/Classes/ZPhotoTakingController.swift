//
//  ZPhotoTakingController.swift
//
//  Created by Zack･Zheng on 2018/2/5.
//

import UIKit

class ZPhotoTakingController: UIImagePickerController {

    private var allowsCropping: Bool = false
    private var imagePickedHandler: ((_ image: UIImage) -> Void)?
    private var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
}

extension ZPhotoTakingController {
    
    class func takePhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imagePickedHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoTakingController()
        vc.allowsCropping = allowsCropping
        vc.sourceType = .camera
        vc.imagePickedHandler = imagePickedHandler
        vc.cancelledHandler = cancelledHandler
        vc.delegate = vc
        controller.present(vc, animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    class func takePhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imagePickedHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil, userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {

        let vc = ZPhotoTakingController()
        if #available(iOS 13.0, *) {
            vc.overrideUserInterfaceStyle = userInterfaceStyle
        }
        vc.allowsCropping = allowsCropping
        vc.sourceType = .camera
        vc.imagePickedHandler = imagePickedHandler
        vc.cancelledHandler = cancelledHandler
        vc.delegate = vc
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoTakingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)


        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage

        if allowsCropping {

            let vc = ZPhotoCropperController()
            vc.image = image
            vc.imageCroppedHandler = { [weak vc] image in
                
                vc?.dismiss(animated: false) { [weak self] in

                    self?.dismiss(animated: true) { [weak self] in
                        self?.imagePickedHandler?(image)
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
            vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            vc.transitioningDelegate = vc
            present(vc, animated: true)

        } else {

            dismiss(animated: true) { [weak self] in
                self?.imagePickedHandler?(image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
