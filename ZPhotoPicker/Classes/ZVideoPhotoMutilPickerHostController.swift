//
//  ZVideoPhotoMutilPickerHostController.swift
//
//  Created by zackzheng on 2019/8/9.
//

import UIKit
import Photos

class ZVideoPhotoMutilPickerHostController: ZPhotoesListController {
    
    weak var dataSource: ZVideoPhotoMutilPickerHostControllerDataSource?
    weak var delegate: ZVideoPhotoMutilPickerHostControllerDelegate?

    var maxVideoDurationInSecond: Int?
    var minVideoDurationInSecond: Int?
    private var bottomView: PhotoPickerSelectedCountView = PhotoPickerSelectedCountView()
    
    deinit {
        print("\(self) \(#function)")
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

private extension ZVideoPhotoMutilPickerHostController {
    
    func configBottomView(selectOrDeselect isSelect: Bool) {
        
        let wantSelectCount = dataSource?.numberOfItemsSelected(self) ?? 0
        let preSelectCount = isSelect ? (wantSelectCount - 1) : (wantSelectCount + 1)
        if (isSelect) {
            bottomView.maxCount = dataSource?.maxSelectedCount(self) ?? 0
        }
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

extension ZVideoPhotoMutilPickerHostController: PhotoPickerSelectedCountViewDelegate {
    
    func photoPickerSelectedCountViewDidCompletePicking() {
        
        guard let selectedAssets = dataSource?.selectedItems(self), selectedAssets.count > 0 else {
            return
        }
        
        if let type = dataSource?.assetsTypeSelecting(self), type == .video {
            
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true // 默认为false，会导致iCloud的照片无法下载
            options.version = .original
            options.deliveryMode = .automatic
            var selectedVideos: [AVURLAsset] = []
            showIndicatorView()
            DispatchQueue.global().async { [weak self] in

                selectedAssets.forEach { asset in

                    self?.imageManager?.requestAVAsset(forVideo: asset, options: options, resultHandler: { [weak self] (avasset, _, info) in

                        guard let `self` = self else { return }
                        guard let avURLAsset = avasset as? AVURLAsset else {
                            return
                        }
                        
                        DispatchQueue.main.async(execute: { [weak self] in

                            guard let `self` = self else { return }
                            selectedVideos.append(avURLAsset)
                            guard selectedAssets.count == selectedVideos.count else {
                                return
                            }
                            self.hideIndicatorView()
                            self.delegate?.photoMutilPickerHostController(self, didFinishPickingVideos: selectedVideos)
                        })
                    })
                }
            }
        } else {
        
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
}

extension ZVideoPhotoMutilPickerHostController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let selectedCount = dataSource?.numberOfItemsSelected(self) ?? 0
        let maxSelectedCount = dataSource?.maxSelectedCount(self) ?? 0

        guard selectedCount < maxSelectedCount else {
            return false
        }

        let asset = assets[indexPath.item]
        if let type = dataSource?.assetsTypeSelecting(self), type != asset.mediaType {
            return false
        }
        
        if let maxVideoDurationInSecond = maxVideoDurationInSecond, asset.mediaType == .video, asset.duration > TimeInterval(maxVideoDurationInSecond) {
            delegate?.photoMutilPickerHostController(self, didForbidSelectionDuration: asset.duration)
            return false
        }

        if let minVideoDurationInSecond = minVideoDurationInSecond, asset.mediaType == .video, asset.duration < TimeInterval(minVideoDurationInSecond) {
            delegate?.photoMutilPickerHostController(self, didForbidSelectionDuration: asset.duration)
            return false
        }
        imageManager?.startCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        delegate?.photoMutilPickerHostController(self, didSelectAsset: asset)
        configBottomView(selectOrDeselect: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedCount = dataSource?.numberOfItemsSelected(self) ?? 0
        let maxSelectedCount = dataSource?.maxSelectedCount(self) ?? 0
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! PhotoPickerImageCell
        cell.canSelected = true

        let asset = assets[indexPath.item]
        if let assets = dataSource?.selectedItems(self), let index = assets.firstIndex(of: asset) {
            cell.isSelected = true
            cell.index = index + 1
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            cell.isSelected = false
            if (selectedCount == maxSelectedCount) {
                cell.canSelected = false
            }
            if let type = dataSource?.assetsTypeSelecting(self), type != asset.mediaType {
                cell.canSelected = false
            }
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        let asset = assets[indexPath.item]
        imageManager?.stopCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        delegate?.photoMutilPickerHostController(self, didDeselectAsset: asset)
        configBottomView(selectOrDeselect: false)
    }
}

protocol ZVideoPhotoMutilPickerHostControllerDelegate: class {
    
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didFinishPickingVideos videos: [AVURLAsset])
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage])
    func photoMutilPickerHostControllerDidCancel(_ controller: ZVideoPhotoMutilPickerHostController)
    func photoMutilPickerHostControllerDidFetchFailed(_ controller: ZVideoPhotoMutilPickerHostController)

    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didSelectAsset asset: PHAsset)
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didDeselectAsset asset: PHAsset)
    
    func photoMutilPickerHostController(_ controller: ZVideoPhotoMutilPickerHostController, didForbidSelectionDuration videoDuration: TimeInterval)
}

protocol ZVideoPhotoMutilPickerHostControllerDataSource: class {
    
    func numberOfItemsSelected(_ controller: ZVideoPhotoMutilPickerHostController) -> Int
    func selectedItems(_ controller: ZVideoPhotoMutilPickerHostController) -> [PHAsset]
    func maxSelectedCount(_ controller: ZVideoPhotoMutilPickerHostController) -> Int
    func assetsTypeSelecting(_ controller: ZVideoPhotoMutilPickerHostController) -> PHAssetMediaType?
}
