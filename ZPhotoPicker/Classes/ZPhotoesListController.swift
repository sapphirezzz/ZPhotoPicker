//
//  ZPhotoesListController.swift
//  ZPhotoPicker
//
//  Created by Zack･Zheng on 2018/2/5.
//

import UIKit
import Photos

class ZPhotoesListController: UICollectionViewController {

    var clickedCancelHandler: (()->Void)?
    var selectedAlbum: AlbumItem?
    
    private(set) var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    private(set) var imageManager: PHCachingImageManager? // 如果未授权访问相册，此时直接 = PHCachingImageManager()会导致页面deinit时崩溃
    
    private var previousPreheatRect = CGRect.zero
    private var thumbnailSize: CGSize!
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

    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationItem.title = selectedAlbum?.title ?? "所有照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(ZPhotoesListController.clickCancelButton))

        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(PhotoPickerImageCell.self, forCellWithReuseIdentifier: "PhotoPickerImageCell")
        collectionView?.register(PhotoPickerImageCountView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PhotoPickerImageCountView.reuseIdentifier)
        
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

internal extension ZPhotoesListController {
    
    func showIndicatorView() {

        hideIndicatorView()
        let indicatorView = UINib(nibName: "IndicatorView", bundle: Bundle(for: ZPhotoPicker.self)).instantiate(withOwner: nil, options: nil)[0] as! IndicatorView
        indicatorView.frame = view.bounds
        indicatorView.tag = 123212
        view.addSubview(indicatorView)
        indicatorView.indicatorView.startAnimating()
    }

    func hideIndicatorView() {
        let indicatorView = view.subviews.filter { $0.tag == 123212 }.first as? IndicatorView
        indicatorView?.indicatorView.stopAnimating()
        indicatorView?.removeFromSuperview()
    }
    
    func alertGetImageError() {

        let alertVC = UIAlertController(title: "获取照片失败", message: "从iCloud获取照片失败，请重新尝试~", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

private extension ZPhotoesListController {

    func getPhotoes() {
        
        imageManager = PHCachingImageManager()
        imageManager!.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero

        if let result = selectedAlbum?.fetchResult {
            fetchResult = result
        } else {

            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
        }

        DispatchQueue.main.sync {
            self.collectionView?.reloadData()
        }
    }

    @objc func clickCancelButton() {
        clickedCancelHandler?()
    }
    
    func showInsufficientPermissionsWarning() {
        
        DispatchQueue.main.sync {
            
            insufficientPermissionsLabel.frame = view.bounds
            view.addSubview(insufficientPermissionsLabel)
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

extension ZPhotoesListController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if #available(iOS 10.0, *) {
            return fetchResult.count // iOS 9.0在未授权时，fetchResult未开始获取图片，调用该属性会导致崩溃
        } else {
            return fetchResult.countOfAssets(with: .image)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = fetchResult.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPickerImageCell", for: indexPath) as! PhotoPickerImageCell
        cell.representedAssetIdentifier = asset.localIdentifier
        
        self.imageManager?.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.image = image
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoPickerImageCountView.reuseIdentifier, for: indexPath) as! PhotoPickerImageCountView
            if #available(iOS 10.0, *) {
                view.count = fetchResult.count
            } else {
                view.count = fetchResult.countOfAssets(with: .image)
            }
            return view
        }
        return UICollectionReusableView()
    }
}

extension ZPhotoesListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
}

private extension UICollectionView {

    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.compactMap({ attribute in
            attribute.representedElementKind == nil ? attribute.indexPath : nil
        })
    }
}
