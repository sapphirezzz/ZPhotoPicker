//
//  ZPhotoMutilPickerHostController.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/2/1.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit
import Photos

protocol ZPhotoMutilPickerHostControllerDelegate: class {
    
    func photoMutilPickerHostController(_ controller: ZPhotoMutilPickerHostController, didFinishPickingImages images: [UIImage])
    func photoMutilPickerHostControllerDidCancel(_ controller: ZPhotoMutilPickerHostController)
}

class ZPhotoMutilPickerHostController: UICollectionViewController {
    
    weak var delegate: ZPhotoMutilPickerHostControllerDelegate?

    var maxCount: Int = 1
    private var selectedIndexs: [Int] = [] // 使用collectionView?.indexPathsForSelectedItems的话没有保证顺序

    private var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    private var imageManager: PHCachingImageManager? // 如果未授权访问相册，此时直接 = PHCachingImageManager()会导致页面deinit时崩溃

    private var bottomView: PhotoPickerSelectedCountView = PhotoPickerSelectedCountView()
    lazy private var insufficientPermissionsLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.backgroundColor = UIColor.white
        view.textColor = UIColor(red: 51.0 / 255, green: 51.0 / 255, blue: 51.0 / 255, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 15.0)
        view.numberOfLines = 0
        view.text = """
请在iPhone的“设置-隐私-照片”选项中,
允许该应用访问你的手机相册。
"""
        return view
    }()

    deinit {
        print("\(self) \(#function)")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationItem.title = "所有照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(ZPhotoMutilPickerHostController.clickCancelButton))
        
        collectionView?.allowsMultipleSelection = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(PhotoPickerImageCell.self, forCellWithReuseIdentifier: "PhotoPickerImageCell")
        collectionView?.register(PhotoPickerImageCountView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoPickerImageCountView.reuseIdentifier)

        bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: bottomLayoutGuide.length + 50)
        bottomView.maxCount = maxCount
        bottomView.selectedCount = 0
        bottomView.delegate = self
        view.addSubview(bottomView)

        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let `self` = self else {return}
            switch status {
            case .authorized:
                self.getPhotoes()
            default:
                self.showInsufficientPermissionsWarning()
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateItemSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        updateItemSize()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}

private extension ZPhotoMutilPickerHostController {
    
    @objc func clickCancelButton() {
        delegate?.photoMutilPickerHostControllerDidCancel(self)
    }
    
    func getPhotoes() {
        
        imageManager = PHCachingImageManager()
        imageManager!.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)

        DispatchQueue.main.sync {
            self.collectionView?.reloadData()
        }
    }

    func showInsufficientPermissionsWarning() {

        DispatchQueue.main.sync {

            insufficientPermissionsLabel.frame = view.bounds
            view.addSubview(insufficientPermissionsLabel)
        }
    }
    
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
    
    func updateItemSize() {
        
        let itemSpacing: CGFloat = 1
        let itemSize: CGSize = {
            let viewWidth = view.bounds.size.width
            let columns: CGFloat = 4
            let itemWidth = floor((viewWidth - (columns - 1) * itemSpacing) / columns)
            return CGSize(width: itemWidth, height: itemWidth)
        }()
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = itemSpacing
        }
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager?.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager?.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

extension ZPhotoMutilPickerHostController: PhotoPickerSelectedCountViewDelegate {
    func photoPickerSelectedCountViewDidCompletePicking() {

        let selectedAssets: [PHAsset] = selectedIndexs.flatMap({ fetchResult.object(at: $0) })
        guard selectedAssets.count > 0 else {return}
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        var selectedImages: [UIImage] = []
        
        // 同步获取图片
        selectedAssets.forEach { asset in
            imageManager?.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { (image, _) in
                if let image = image {
                    selectedImages.append(image)
                }
            })
        }
        delegate?.photoMutilPickerHostController(self, didFinishPickingImages: selectedImages)
    }
}

extension ZPhotoMutilPickerHostController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset = fetchResult.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPickerImageCell", for: indexPath) as! PhotoPickerImageCell
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager?.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.image = image
            }
        }
        
        return cell
    }
    
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoPickerImageCountView.reuseIdentifier, for: indexPath) as! PhotoPickerImageCountView
            view.count = fetchResult.count
            return view
        }
        return UICollectionReusableView()
    }
}

extension ZPhotoMutilPickerHostController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
}

private extension UICollectionView {

    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.flatMap({ attribute in
            attribute.representedElementKind == nil ? attribute.indexPath : nil
        })
    }
}
