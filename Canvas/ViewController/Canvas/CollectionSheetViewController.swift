//
//  CollectionSheetViewController.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit
import SDWebImage
import SnapKit

// MARK: - Protocol
protocol CollectionSheetViewControllerDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}

class CollectionSheetViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    private var items: [AnyItem] = []
    private var collectionView: UICollectionView!
    private var dataType: DataType
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    
    private var currentPage = 1
    private var isLoading = false
    private let itemsPerPage = 40
    
    weak var delegate: CollectionSheetViewControllerDelegate?

    // MARK: - Initialization
    init(dataType: DataType, title: String) {
        self.dataType = dataType
        self.titleLabel.text = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clrGray
        setupUI()
        setupCollectionView()
        fetchData(page: currentPage)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Close Button
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .clrFont
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Setup CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.size.width / 4) - 20, height: (view.frame.size.width / 4) - 20)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 15
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clrGray
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Fetch Data
    private func fetchData(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        switch dataType {
        case .photo, .overlay:
            PexelsAPIService.shared.fetchCuratedPhotos(perPage: itemsPerPage, page: page) { [weak self] result in
                switch result {
                case .success(let photos):
                    if page == 1 {
                        self?.items = photos.map { AnyItem.photo($0) }
                    } else {
                        self?.items.append(contentsOf: photos.map { AnyItem.photo($0) })
                    }
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch photos: \(error)")
                }
                self?.isLoading = false
            }
            
        case .video:
            PexelsAPIService.shared.fetchPopularVideos(perPage: itemsPerPage, page: page) { [weak self] result in
                switch result {
                case .success(let videos):
                    if page == 1 {
                        self?.items = videos.map { AnyItem.video($0) }
                    } else {
                        self?.items.append(contentsOf: videos.map { AnyItem.video($0) })
                    }
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch videos: \(error)")
                }
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let item = items[indexPath.item]
        
        switch item {
        case .photo(let photo):
            if let url = URL(string: photo.src.medium ?? "") {
                cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            }
        case .video(let video):
            if let url = URL(string: video.image) {
                cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        switch item {
        case .photo(let photo):
            if let url = URL(string: photo.src.medium ?? "") {
                SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] image, _, _, _, _,_  in
                    guard let image = image else { return }
                    self?.delegate?.didSelectImage(image)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        case .video(let video):
            if let url = URL(string: video.image) {
                print("Selected video URL: \(url)")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if contentOffsetY + frameHeight > contentHeight - 100 {
            // Near the bottom, load more data
            currentPage += 1
            fetchData(page: currentPage)
        }
    }
}
