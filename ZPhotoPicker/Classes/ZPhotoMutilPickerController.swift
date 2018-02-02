//
//  ZPhotoMutilPickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/30.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoMutilPickerController: UINavigationController {
    
    var imagesSelectedHandler: ((_ image: [UIImage]) -> Void)?
    var cancelledHandler: (() -> Void)?

    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(imagesSelectedHandler: ((_ image: [UIImage]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil, maxCount: Int) {
        let vc = ZPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        self.init(rootViewController: vc)
        self.imagesSelectedHandler = imagesSelectedHandler
        self.cancelledHandler = cancelledHandler
        vc.delegate = self
        vc.maxCount = maxCount
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoMutilPickerController: ZPhotoMutilPickerHostControllerDelegate {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage]) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.imagesSelectedHandler?(images)
        })
    }
    
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.cancelledHandler?()
        })
    }
}
