//
//  ZPhotoSinglePickerHostController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/2/1.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit
import Photos

class ZPhotoSinglePickerHostController: ZPhotoesListController {
    
    weak var delegate: ZPhotoSinglePickerHostControllerDelegate?

    deinit {
        print("\(self) \(#function)")
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = false
        clickedCancelHandler = { [weak self] in
            guard let `self` = self else {return}
            self.delegate?.photoSinglePickerHostControllerDidCancel(self)
        }
    }
}

extension ZPhotoSinglePickerHostController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset: PHAsset = fetchResult.object(at: indexPath.item)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true // 默认为false，会导致iCloud的照片无法下载
        // 同步获取图片
        self.imageManager?.requestImage(for: selectedAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { [weak self] (image, _) in

            guard let `self` = self else {return}
            if let image = image {
                self.delegate?.photoSinglePickerHostController(self, didFinishPickingImage: image)
            }
        })
    }
}

protocol ZPhotoSinglePickerHostControllerDelegate: class {
    
    func photoSinglePickerHostController(_ controller: ZPhotoSinglePickerHostController, didFinishPickingImage image: UIImage)
    func photoSinglePickerHostControllerDidCancel(_ controller: ZPhotoSinglePickerHostController)
}
