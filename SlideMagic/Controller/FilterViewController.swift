//
//  FilterViewController.swift
//  SlideMagic
//
//  Created by RX on 4/5/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit
import AVFoundation

class FilterViewController: UIViewController {

    var videoThumbnail: UIImage?
    var videoURL: URL?
    var finalURL: URL!
    var videoPlayer: AVPlayer!
    var selectedIndex: Int = 0

    @IBOutlet weak var filterCollection: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if videoPlayer != nil {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
        }
        videoPlayer.pause()
        videoPlayer = nil
    }
    
    private func playVideo() {
        let avAsset = AVAsset(url: videoURL!)
        let playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: videoPlayer?.currentItem)
        
        let avPlayerLayer = AVPlayerLayer(player: videoPlayer)
        avPlayerLayer.frame = CGRect(x: 0, y: 0, width: self.videoView.frame.size.width
            , height: self.videoView.frame.size.height)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        videoPlayer.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            
            videoPlayer.play()
        }
    }
    
    private func replaceVideoPlayerItem(newURL: URL) {
        finalURL = newURL
        
        let avAsset = AVAsset(url: newURL)
        let playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer.replaceCurrentItem(with: playerItem)
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: videoPlayer?.currentItem)
    }
    
    public func setVideo(_video : URL, _thumbnail: UIImage) {
        videoURL = _video
        finalURL = _video
        videoThumbnail = _thumbnail
        finalURL = _video
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func filterVideo() {
        videoPlayer.pause()
        
        let filter = filterFromIndex(index: selectedIndex)
        VideoGenerator.current.filterVideo(withVideoURL: videoURL!, filter: filter, success: { (url) in
            DispatchQueue.main.async {
                self.replaceVideoPlayerItem(newURL: url)
            }
        }) { (error) in
            self.videoPlayer.play()
            print(error)
        }
    }
    
    private func filterFromIndex(index: Int) -> FilterType {
        switch index {
        case 1:
            return .CIPhotoEffectNoir
        case 2:
            return .CIBloom
        case 3:
            return .CIPhotoEffectProcess
        case 4:
            return .CIPixellate
        case 5:
            return .CIPhotoEffectInstant
        case 6:
            return .CILinearToSRGBToneCurve
        case 7:
            return .CIVibrance
        case 8:
            return .CIPhotoEffectFade
        case 9:
            return .CIPhotoEffectTransfer
        case 10:
            return .CIPhotoEffectMono
        case 11:
            return .CIVignette
        default:
            return .FilterTypeNone
        }
    }
    
    @IBAction func actionShare(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [finalURL] as [AnyObject], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as? FilterCVCell
            else { fatalError("unexpected cell in collection view") }
        
        if var thumbnail = CIImage(image: videoThumbnail!) {
            switch indexPath.row {
            case 1:
                cell.labelFilter.text = NSLocalizedString("Noir", comment: "Noir")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectNoir)
                break;
            case 2:
                cell.labelFilter.text = NSLocalizedString("Bloom", comment: "Bloom")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIBloom)
                break;
            case 3:
                cell.labelFilter.text = NSLocalizedString("Process", comment: "Process")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectProcess)
                break;
            case 4:
                cell.labelFilter.text = NSLocalizedString("Pixellate", comment: "Pixellate")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPixellate)
                break;
            case 5:
                cell.labelFilter.text = NSLocalizedString("Instant", comment: "Instant")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectInstant)
                break;
            case 6:
                cell.labelFilter.text = NSLocalizedString("ToneCurve", comment: "ToneCurve")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CILinearToSRGBToneCurve)
                break;
            case 7:
                cell.labelFilter.text = NSLocalizedString("Vibrance", comment: "Vibrance")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIVibrance)
                break;
            case 8:
                cell.labelFilter.text = NSLocalizedString("Fade", comment: "Fade")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectFade)
                break;
            case 9:
                cell.labelFilter.text = NSLocalizedString("Transfer", comment: "Transfer")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectTransfer)
                break;
            case 10:
                cell.labelFilter.text = NSLocalizedString("Mono", comment: "Mono")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIPhotoEffectMono)
            case 11:
                cell.labelFilter.text = NSLocalizedString("Vignette", comment: "Vignette")
                thumbnail = VideoGenerator.current.filterWithImage(ciImage: thumbnail, filter: .CIVignette)
                break;
            default:
                cell.labelFilter.text = NSLocalizedString("None", comment: "None")
                break;
            }
            
            cell.thumbnailView.image = UIImage(ciImage: thumbnail)
            
            if selectedIndex == indexPath.row {
                cell.thumbnailView.borderColor = UIColor.red
            } else {
                cell.thumbnailView.borderColor = UIColor.white
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height * 0.8, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        filterCollection.reloadData()
        filterVideo()
    }
    
}
