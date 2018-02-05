//
//  ZPhotoMutilPickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/30.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoMutilPickerController: UINavigationController {
    
    private var imagesPickedHandler: ((_ image: [UIImage]) -> Void)?
    private var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(maxCount: Int, imagesPickedHandler: ((_ image: [UIImage]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil) {
        let vc = ZPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        self.init(rootViewController: vc)
        self.imagesPickedHandler = imagesPickedHandler
        self.cancelledHandler = cancelledHandler
        vc.delegate = self
        vc.maxCount = maxCount
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoMutilPickerController {
    
    class func pickPhotoes(onPresentingViewController controller: UIViewController, maxCount: Int, imagesPickedHandler: @escaping (_ image: [UIImage]) -> Void, cancelledHandler: (() -> Void)? = nil) {

        let vc = ZPhotoMutilPickerController(maxCount: maxCount, imagesPickedHandler: imagesPickedHandler, cancelledHandler: cancelledHandler)
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZPhotoMutilPickerController: ZPhotoMutilPickerHostControllerDelegate {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage]) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.imagesPickedHandler?(images)
        })
    }
    
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
}
