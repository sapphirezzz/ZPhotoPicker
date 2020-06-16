//
//  ZPhotoMutilPickerHostController.swift
//
//  Created by Zack･Zheng on 2018/2/1.
//

import UIKit
import Photos

class ZPhotoMutilPickerHostController: ZPhotoesListController {
    
    weak var dataSource: ZPhotoMutilPickerHostControllerDataSource?
    weak var delegate: ZPhotoMutilPickerHostControllerDelegate?

    private var bottomView: PhotoPickerSelectedCountView = PhotoPickerSelectedCountView()

    deinit {
        print("\(self) \(#function)")
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.mediaType = .image
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.mediaType = .image
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = true

        bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: bottomLayoutGuide.length + 50)
        bottomView.maxCount = dataSource?.maxSelectedCount(self) ?? 0
        bottomView.selectedCount = dataSource?.numberOfItemsSelected(self) ?? 0
        bottomView.delegate = self
        view.addSubview(bottomView)
        
        clickedCancelHandler = { [weak self] in
            guard let `self` = self else {return}
            self.delegate?.photoMutilPickerHostControllerDidCancel(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        showBottomViewIfNeed()
    }
}

private extension ZPhotoMutilPickerHostController {
    
    func configBottomView(selectOrDeselect isSelect: Bool) {
        
        let wantSelectCount = dataSource?.numberOfItemsSelected(self) ?? 0
        let preSelectCount = isSelect ? (wantSelectCount - 1) : (wantSelectCount + 1)
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
    
    func showBottomViewIfNeed() {
        
        let preSelectCount = dataSource?.numberOfItemsSelected(self) ?? 0
        if preSelectCount > 0 {

            let height = bottomLayoutGuide.length + 50
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height, width: UIScreen.main.bounds.width, height: height)
            })
        }
    }
}

extension ZPhotoMutilPickerHostController: PhotoPickerSelectedCountViewDelegate {

    func photoPickerSelectedCountViewDidCompletePicking() {

        guard let selectedAssets = dataSource?.selectedItems(self), selectedAssets.count > 0 else{
            return
        }
        
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

        let selectedCount = dataSource?.numberOfItemsSelected(self) ?? 0
        if selectedCount >= dataSource?.maxSelectedCount(self) ?? 0 {
            return false
        } else {
            let asset = fetchResult.object(at: indexPath.item)
            imageManager?.startCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
            return true
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        delegate?.photoMutilPickerHostController(self, didSelectAsset: asset)
        configBottomView(selectOrDeselect: true)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedCount = dataSource?.numberOfItemsSelected(self) ?? 0
        let maxSelectedCount = dataSource?.maxSelectedCount(self) ?? 0
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! PhotoPickerImageCell
        let asset = fetchResult.object(at: indexPath.item)
        if let assets = dataSource?.selectedItems(self), let index = assets.firstIndex(of: asset) {
            cell.canSelected = true
            cell.isSelected = true
            cell.index = index + 1
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            if (selectedCount == maxSelectedCount) {
                cell.canSelected = false
            } else {
                cell.canSelected = true
            }
            cell.isSelected = false
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {

        let asset = fetchResult.object(at: indexPath.item)
        imageManager?.stopCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        delegate?.photoMutilPickerHostController(self, didDeselectAsset: asset)
        configBottomView(selectOrDeselect: false)
    }
}

protocol ZPhotoMutilPickerHostControllerDelegate: class {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage])
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController)
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didSelectAsset asset: PHAsset)
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didDeselectAsset asset: PHAsset)
}

protocol ZPhotoMutilPickerHostControllerDataSource: class {

    func numberOfItemsSelected(_ controller: ZPhotoMutilPickerHostController) -> Int
    func selectedItems(_ controller: ZPhotoMutilPickerHostController) -> [PHAsset]
    func maxSelectedCount(_ controller: ZPhotoMutilPickerHostController) -> Int
}
