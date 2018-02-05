//
//  ZPhotoSinglePickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/31.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoSinglePickerController: UINavigationController {
    
    private var imagePickedHandler: ((_ image: UIImage) -> Void)?
    private var cancelledHandler: (() -> Void)?
    private var allowsCropping: Bool = false

    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(allowsCropping: Bool = false, imagePickedHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoSinglePickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        self.init(rootViewController: vc)
        self.allowsCropping = allowsCropping
        self.imagePickedHandler = imagePickedHandler
        self.cancelledHandler = cancelledHandler
        vc.delegate = self
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoSinglePickerController {
    
    class func pickPhoto(onPresentingViewController controller: UIViewController, allowsCropping: Bool = false, imageTookHandler: @escaping (_ image: UIImage) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoSinglePickerController(allowsCropping: allowsCropping, imagePickedHandler: imageTookHandler, cancelledHandler: cancelledHandler)
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoSinglePickerController: ZPhotoSinglePickerHostControllerDelegate {

    func photoSinglePickerHostController(_ controller: ZPhotoSinglePickerHostController, didFinishPickingImage image: UIImage) {

        if allowsCropping {
            
            let vc = ZPhotoCropperController()
            vc.cancelledHandler = { [weak vc] in
                vc?.dismiss(animated: true)
            }
            vc.image = image
            vc.imageCroppedHandler = { [weak vc] image in

                vc?.dismiss(animated: false) { [weak self] in

                    self?.dismiss(animated: true) { [weak self] in
                        self?.imagePickedHandler?(image)
                    }
                }
            }
            vc.transitioningDelegate = vc
            present(vc, animated: true)

        } else {

            dismiss(animated: true) { [weak self] in
                self?.imagePickedHandler?(image)
            }
        }
    }
    
    func photoSinglePickerHostControllerDidCancel(_ controller: ZPhotoSinglePickerHostController) {
        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}
