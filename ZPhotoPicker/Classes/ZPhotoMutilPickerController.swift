//
//  ZPhotoMutilPickerController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/30.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class ZPhotoMutilPickerController: UINavigationController {
    
    private weak var pickerDelegate: ZPhotoPickerDelegate?

    deinit {
        print("\(self) \(#function)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(delegate: ZPhotoPickerDelegate, maxCount: Int) {
        let vc = ZPhotoMutilPickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        self.init(rootViewController: vc)
        vc.delegate = self
        vc.maxCount = maxCount
        self.pickerDelegate = delegate
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
}

extension ZPhotoMutilPickerController: ZPhotoMutilPickerHostControllerDelegate {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage]) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.pickerDelegate?.zPhotoPickerDidFinishPickingImages(images)
        })
    }
    
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.pickerDelegate?.zPhotoPickerDidCancelPickingImage()
        })
    }
}
