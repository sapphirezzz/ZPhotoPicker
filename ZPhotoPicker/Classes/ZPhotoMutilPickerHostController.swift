//
//  ZPhotoMutilPickerHostController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/2/1.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit
import Photos

class ZPhotoMutilPickerHostController: ZPhotoesListController {
    
    weak var delegate: ZPhotoMutilPickerHostControllerDelegate?
    var maxCount: Int = 1

    private var selectedIndexs: [Int] = [] // 使用collectionView?.indexPathsForSelectedItems的话没有保证顺序
    private var bottomView: PhotoPickerSelectedCountView = PhotoPickerSelectedCountView()

    deinit {
        print("\(self) \(#function)")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = true

        bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: bottomLayoutGuide.length + 50)
        bottomView.maxCount = maxCount
        bottomView.selectedCount = 0
        bottomView.delegate = self
        view.addSubview(bottomView)
        
        clickedCancelHandler = { [weak self] in
            guard let `self` = self else {return}
            self.delegate?.photoMutilPickerHostControllerDidCancel(self)
        }
    }
}

private extension ZPhotoMutilPickerHostController {
    
    func configBottomView(selectOrDeselect isSelect: Bool) {
        
        let preSelectCount = selectedIndexs.count
        let wantSelectCount = isSelect ? (preSelectCount + 1) : (preSelectCount - 1)
        bottomView.selectedCount = wantSelectCount

        let height = bottomLayoutGuide.length + 50
        if isSelect && preSelectCount == 0 {

            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height, width: UIScreen.main.bounds.width, height: height)
            })
        } else if !isSelect && wantSelectCount == 0 {
      
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: height)
            })
        }
    }
}

extension ZPhotoMutilPickerHostController: PhotoPickerSelectedCountViewDelegate {

    func photoPickerSelectedCountViewDidCompletePicking() {

        let selectedAssets: [PHAsset] = selectedIndexs.flatMap({ fetchResult.object(at: $0) })
        guard selectedAssets.count > 0 else {return}
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true // 默认为false，会导致iCloud的照片无法下载
        var selectedImages: [UIImage] = []
        showIndicatorView()

        DispatchQueue.global().async { [weak self] in

            // 同步获取图片
            selectedAssets.forEach { asset in
                self?.imageManager?.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { (image, _) in
                    
                    if let image = image {
                        selectedImages.append(image)
                    }
                })
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                
                guard let `self` = self else { return }
                self.hideIndicatorView()
                guard selectedAssets.count == selectedImages.count else {
                    self.alertGetImageError()
                    return
                }
                self.delegate?.photoMutilPickerHostController(self, didFinishPickingImages: selectedImages)
            })
        }
    }
}

extension ZPhotoMutilPickerHostController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        if selectedIndexs.count >= maxCount {
            return false
        } else {
            let asset = fetchResult.object(at: indexPath.item)
            imageManager?.startCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
            configBottomView(selectOrDeselect: true)
            selectedIndexs.append(indexPath.item)
            return true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        let asset = fetchResult.object(at: indexPath.item)
        imageManager?.stopCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        configBottomView(selectOrDeselect: false)
        selectedIndexs = selectedIndexs.filter { $0 != indexPath.item }
        return true
    }
}

protocol ZPhotoMutilPickerHostControllerDelegate: class {

    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage])
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController)
}
