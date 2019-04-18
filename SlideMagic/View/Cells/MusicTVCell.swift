//
//  MusicTVCell.swift
//  SlideMagic
//
//  Created by RX on 4/4/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit
import AVFoundation

protocol MusicTVCellDelegate {
    func didClickUseButton(indexPath: IndexPath)
}

class MusicTVCell: UITableViewCell {

    public var delegate: MusicTVCellDelegate!
    
    var music: MusicItem?
    var indexPath: IndexPath?
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelLength: UILabel!
    @IBOutlet weak var buttonUse: RoundBorderButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            buttonUse.isHidden = false
            playAudio()
        } else {
            resetCell()
        }
    }
    
    public func resetCell() {
        buttonUse.isHidden = true
        
        if audioPlayer != nil {
            audioPlayer!.stop()
            audioPlayer = nil
        }
    }
    
    func configureWithData(_ data: MusicItem, indexPath: IndexPath) {
        thumbImageView.image = (data.thumb != nil) ? data.thumb : UIImage(named: "ic_music")
        labelTitle.text = data.musicTitle
        labelArtist.text = data.artist
        labelLength.text = data.durationInMin
        
        music = data
        self.indexPath = indexPath
        
        playAudio()
    }
    
    func playAudio() {
        guard let url = music!.fileURL else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            if audioPlayer == nil {
                audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            }
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            audioPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func actionUse(_ sender: Any) {
        delegate.didClickUseButton(indexPath: self.indexPath!)
    }
}
