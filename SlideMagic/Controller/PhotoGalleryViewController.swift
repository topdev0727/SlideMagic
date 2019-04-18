//
//  PhotoGalleryViewController.swift
//  SlideMagic
//
//  Created by RX on 4/4/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoGalleryViewController: UIViewController {

    var photoCollectionView: UICollectionView!
    var gallery: GalleryController!
    var selectedPhotos: [UIImage] = []
    var secPerPhoto: Double = 2
    var selectedMusic: MusicItem?

    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var labelLength: UILabel!
    @IBOutlet weak var labelMusic: UILabel!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressRing: UICircularProgressRing!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showImagePicker()
        createCollectionView()
        
        timeSlider.value = 2
        setTimeLabel(2)
        
        progressView.isHidden = true
        progressRing.value = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedMusic == nil {
            labelMusic.text = NSLocalizedString("No Music", comment: "No Music")
        } else {
            labelMusic.text = selectedMusic?.musicTitle
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        photoCollectionView.frame = CGRect(x: 0, y: 0, width: photosView.frame.size.width, height: photosView.frame.size.height)
    }
    
    func createCollectionView() {
        
        photoCollectionView = createPhotoCollectionView(CGRect(x: 0, y: 0, width: photosView.frame.size.width, height: photosView.frame.size.height), tag: 0)
        photosView.addSubview(photoCollectionView)
        photoCollectionView.reloadData()
    }
    
    func createPhotoCollectionView(_ rect: CGRect, tag: Int) -> UICollectionView {
        
        let cvLayout: SMCVLayout = SMCVLayout()
        cvLayout.cellPadding = 0
        cvLayout.delegate = self
        cvLayout.numberOfColumns = 4
        
        let collectionView: UICollectionView = UICollectionView(frame: rect, collectionViewLayout: cvLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.tag = tag
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        
        let nibName = UINib(nibName: "PhotoCVCell", bundle: Bundle.main)
        collectionView.register(nibName, forCellWithReuseIdentifier: "PhotoCVCell")
        
        return collectionView
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ToMusicVC" {
            let newVC: MusicViewController = (segue.destination as? MusicViewController)!
            newVC.delegate = self
        }
    }
    
    
    private func showImagePicker() {
        Config.Camera.imageLimit = 30
        Config.tabsToShow = [.imageTab, .cameraTab]
        
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
    private func setTimeLabel(_ value: Float) {
        secPerPhoto = Double(exactly: value) ?? 2
        let stringSPP = String(format: "%.2f", value)

        let totalSeconds = value * Float(selectedPhotos.count)
        var minutes = Int(totalSeconds)/60
        var seconds: Int = 0
        if minutes < 1 {
            seconds = Int(totalSeconds)
            minutes = 0
        } else {
            seconds = Int(totalSeconds)%60
        }
        
        let stringMinutes = String(format: "%02d", minutes)
        let stringSeconds = String(format: "%02d", seconds)
        
        labelLength.text = NSLocalizedString("Length", comment: "Length") + " : " + stringMinutes + ":" + stringSeconds + "\n" + stringSPP + " s/pic"
    }
    
    fileprivate func createAlertView(message: String?) {
        let messageAlertController = UIAlertController(title: NSLocalizedString("Message", comment: "Message"), message: message, preferredStyle: .alert)
        messageAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            messageAlertController.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async { [weak self] in
            self?.present(messageAlertController, animated: true, completion: nil)
        }
    }
    
    private func generateMovie() {
        VideoGenerator.current.fileName = "MultipleSingleMovieFileName"
        VideoGenerator.current.shouldOptimiseImageForVideo = true
        
        if let audioURL = selectedMusic?.fileURL {
            VideoGenerator.current.generate(withImages: selectedPhotos, secPerImage: secPerPhoto, andAudios: [audioURL], andType: .singleAudioMultipleImage, { (progress) in
                DispatchQueue.main.async {
                    self.progressRing.value = CGFloat(progress.fractionCompleted * 100)
                }
            }, success: { (url) in
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.pushToFilterVC(videoURL: url)
                }
                print(url)
            }, failure: { (error) in
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.createAlertView(message: error.localizedDescription)
                }
                print(error)
            })
        } else {
            VideoGenerator.current.generate(withImages: selectedPhotos, secPerImage: secPerPhoto, andAudios: [], andType: .singleAudioMultipleImage, { (progress) in
                DispatchQueue.main.async {
                    self.progressRing.value = CGFloat(progress.fractionCompleted * 100)
                }
            }, success: { (url) in
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.pushToFilterVC(videoURL: url)
                }
                print(url)
            }, failure: { (error) in
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.createAlertView(message: error.localizedDescription)
                }
                print(error)
            })
        }
    }
    
    private func pushToFilterVC(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController
            vc?.setVideo(_video: videoURL, _thumbnail: uiImage)
            self.navigationController?.pushViewController(vc!, animated: true)
        } catch let error {
            print(error)
        }
        
    }
    
    
    
    @IBAction func actionNext(_ sender: Any) {
        if selectedPhotos.count > 0 {
            progressView.isHidden = false
            progressRing.value = 0
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.generateMovie()
            }
        } else {
            createAlertView(message: NSLocalizedString("Please import photos", comment: "Please import photos"))
        }
        
    }
    
    @IBAction func timeLengthChanged(_ sender: UISlider) {
        setTimeLabel(sender.value)
    }
    
    @IBAction func actionOpenGallery(_ sender: Any) {
        showImagePicker()
    }
    
}

extension PhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, SMCVLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCVCell", for: indexPath) as? PhotoCVCell
            else { fatalError("unexpected cell in collection view") }
        
        let photo = selectedPhotos[indexPath.row]
        cell.photoView.image = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let ratio = 1.44
        let size = CGSize(width: 100, height: 100 * ratio)
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: size, insideRect: boundingRect)
        
        return rect.height
    }
}

extension PhotoGalleryViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            self?.selectedPhotos = []
            self?.selectedPhotos = resolvedImages.compactMap({ $0 })
            self?.photoCollectionView.reloadData()
            self?.setTimeLabel((self?.timeSlider.value)!)
        })
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}

extension PhotoGalleryViewController: MusicViewControllerDelegate {
    func didSelectMusic(music: MusicItem) {
        selectedMusic = music
        labelMusic.text = music.musicTitle
    }
}

