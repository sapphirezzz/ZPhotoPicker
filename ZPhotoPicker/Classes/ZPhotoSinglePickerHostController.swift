//
//  ZPhotoSinglePickerHostController.swift
//
//  Created by Zack･Zheng on 2018/2/1.
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

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return fetchResult.object(at: indexPath.item).mediaType != .video
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! PhotoPickerImageCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.canSelected = asset.mediaType != .video

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset: PHAsset = fetchResult.object(at: indexPath.item)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true // 默认为false，会导致iCloud的照片无法下载
        
        showIndicatorView()

        var selectedImage: UIImage?
        DispatchQueue.global().async { [weak self] in
            
            // 同步获取图片
            self?.imageManager?.requestImage(for: selectedAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { (image, _) in
                selectedImage = image
            })

            DispatchQueue.main.async(execute: { [weak self] in
                
                guard let `self` = self else { return }
                self.hideIndicatorView()
                guard let image = selectedImage else {
                    self.alertGetImageError()
                    return
                }
                self.delegate?.photoSinglePickerHostController(self, didFinishPickingImage: image)
            })
        }
    }
}

protocol ZPhotoSinglePickerHostControllerDelegate: class {
    
    func photoSinglePickerHostController(_ controller: ZPhotoSinglePickerHostController, didFinishPickingImage image: UIImage)
    func photoSinglePickerHostControllerDidCancel(_ controller: ZPhotoSinglePickerHostController)
}
