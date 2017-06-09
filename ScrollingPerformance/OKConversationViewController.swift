//
//  OKConversationViewController.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit

final class OKConversationViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    fileprivate let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    fileprivate var dataSource = [AnyObject]()
    
    fileprivate let messageMeasuringCell = OKMessageCell()
    fileprivate let timestampMeasuringCell = OKTimestampCell()
    
    fileprivate let assetFactory: OKConversationAssetFactory
    fileprivate let sizingFactory: OKConversationSizingFactory
    fileprivate let messageClient: OKConversationMessageClient
    
    //MARK: - Lifecycle
    
    init(assetFactory: OKConversationAssetFactory, sizingFactory: OKConversationSizingFactory, messageClient: OKConversationMessageClient) {
        self.assetFactory = assetFactory
        self.sizingFactory = sizingFactory
        self.messageClient = messageClient
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupMessages()
    }
    
    //MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = view.bounds
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    //MARK: - Animations

    // This animation probably belongs in a flow layout
    fileprivate func animateReloadData() {
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil, completion: nil)
        
        enableMessageCellLabels()
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        
        for (index, indexPath) in visibleIndexPaths.enumerated() {
            let cell = collectionView.cellForItem(at: indexPath)
            let height = cell?.contentView.frame.height ?? 0
            cell?.transform = CGAffineTransform(translationX: 0, y: -height).scaledBy(x: 1.75, y: 1.75)
            cell?.alpha = 0
            
            UIView.animate(withDuration: 0.2, delay: 0.02 * TimeInterval(index), options: .curveEaseOut, animations: {
                cell?.transform = .identity
                cell?.alpha = 1
            }, completion: nil)
        }
    }
    
    //MARK: - Helpers
    
    fileprivate func enableMessageCellLabels() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? OKMessageCell, cell.isMessageImageView {
                cell.isMessageImageView = false
            }
        }
    }
    
    func dequeueMessageCellComponent(with message: OKMessage, collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let component = message.components()[indexPath.item]
        
        switch component {
        case .timestamp:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OKTimestampCell.reuseID, for: indexPath) as! OKTimestampCell
            cell.configure(with: message, assetFactory: assetFactory, sizingFactory: sizingFactory)
            return cell
            
        case .message:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OKMessageCell.reuseID, for: indexPath) as! OKMessageCell
            cell.configure(with: message, assetFactory: assetFactory, sizingFactory: sizingFactory)
            return cell
        }
    }
    
    fileprivate func sizeForMessageCellComponent(with message: OKMessage, at indexPath: IndexPath) -> CGSize {
        let component = message.components()[indexPath.item]
        
        switch component {
        case .timestamp:
            return timestampMeasuringCell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: .infinity),
                                                      message: message,
                                                      assetFactory: assetFactory,
                                                      sizingFactory: sizingFactory)
            
        case .message:
            if !kIsOptimized {
                messageMeasuringCell.configure(with: message, assetFactory: assetFactory, sizingFactory: sizingFactory)
            }
            
            return messageMeasuringCell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: .infinity),
                                                     message: message,
                                                     assetFactory: assetFactory,
                                                     sizingFactory: sizingFactory)
        }
    }
    
    //MARK: - Setup
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.barStyle = .black
    }
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "MoonBackground"))
        collectionView.indicatorStyle = .white
        collectionView.register(OKLoadingCell.self, forCellWithReuseIdentifier: OKLoadingCell.reuseID)
        collectionView.register(OKMessageCell.self, forCellWithReuseIdentifier: OKMessageCell.reuseID)
        collectionView.register(OKTimestampCell.self, forCellWithReuseIdentifier: OKTimestampCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    fileprivate func setupMessages() {
        DispatchQueue.main.async {
            self.dataSource.append(OKLoading())
            self.collectionView.reloadData()
        }
        
        DispatchQueue.global().async {
            let conversation = self.messageClient.createConversation(sideChangeCount: 100)
            
            if kIsOptimized {
                let portraitSize = CGSize(width: self.collectionView.bounds.width, height: .infinity)
                let landscapeSize = CGSize(width: self.collectionView.bounds.height, height: .infinity)
                
                let messages = conversation.filter({ $0 is OKMessage }) as! [OKMessage]
                
                // Cache all sizing and image assets on background thread
                for message in messages {
                    self.messageMeasuringCell.cache(for: portraitSize,
                                                    message: message,
                                                    assetFactory: self.assetFactory,
                                                    sizingFactory: self.sizingFactory)
                    
                    self.messageMeasuringCell.cache(for: landscapeSize,
                                                    message: message,
                                                    assetFactory: self.assetFactory,
                                                    sizingFactory: self.sizingFactory)
                    
                    if !message.isTimestampEnabled {
                        continue
                    }
                    
                    self.timestampMeasuringCell.cache(for: portraitSize,
                                                      message: message,
                                                      assetFactory: self.assetFactory,
                                                      sizingFactory: self.sizingFactory)
                    
                    self.timestampMeasuringCell.cache(for: landscapeSize,
                                                      message: message,
                                                      assetFactory: self.assetFactory,
                                                      sizingFactory: self.sizingFactory)
                }
            }
            
            DispatchQueue.main.async {
                self.dataSource.insert(contentsOf: conversation, at: 0)
                self.animateReloadData()
            }
        }
    }
    
}

//MARK: - UICollectionViewDataSource

extension OKConversationViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let object = dataSource[section]
        
        if let object = object as? OKMessage {
            return object.components().count
            
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = dataSource[indexPath.section]
        
        if let message = object as? OKMessage {
            return dequeueMessageCellComponent(with: message, collectionView: collectionView, at: indexPath)
            
        } else if object is OKLoading {
            let loadingCell = collectionView.dequeueReusableCell(withReuseIdentifier: OKLoadingCell.reuseID, for: indexPath) as! OKLoadingCell
            loadingCell.configure(with: sizingFactory)
            return loadingCell
        }
        
        fatalError("Did not properly dequeue collectionView(_:cellForItemAt:)")
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension OKConversationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let object = dataSource[section]
        
        if object is OKMessage {
            return UIEdgeInsets(top: sizingFactory.messageSpacing, left: 0, bottom: sizingFactory.messageSpacing, right: 0)
            
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let object = dataSource[indexPath.section]
        
        if object is OKLoading {
            return CGSize(width: collectionView.bounds.width, height: sizingFactory.loadingCellHeight)
            
        } else if let message = object as? OKMessage {
            return sizeForMessageCellComponent(with: message, at: indexPath)
        }
        
        fatalError("Did not properly return size collectionView(_:layout:sizeForItemAt:)")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? OKLoadingCell {
            cell.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? OKLoadingCell {
            cell.stopAnimating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            enableMessageCellLabels()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        enableMessageCellLabels()
    }
    
}
