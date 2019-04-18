//
//  MusicViewController.swift
//  SlideMagic
//
//  Created by RX on 4/5/19.
//  Copyright © 2019 JZ. All rights reserved.
//

import UIKit

protocol MusicViewControllerDelegate {
    func didSelectMusic(music: MusicItem)
}

class MusicViewController: UIViewController {

    public var delegate: MusicViewControllerDelegate!
    private var musics: MusicLibrary!

    @IBOutlet weak var musicTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        musicTableview.register(UINib(nibName: "MusicTVCell", bundle: Bundle.main), forCellReuseIdentifier: "MusicTVCell")
        musicTableview.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        allowAuthorize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for cell in musicTableview.visibleCells {
            if cell is MusicTVCell {
                let musicCell = cell as! MusicTVCell
                musicCell.resetCell()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func allowAuthorize() {
        switch MusicLibrary.status {
            
        case .notDetermined:
            MusicLibrary.askAuthorization { _ in
                self.allowAuthorize()
            }
            
        case .denied, .restricted:
            // User denied access
            DispatchQueue.main.async {
                let alert = UIAlertController(title: NSLocalizedString("Music Access Denied", comment: "Music Access Denied"),
                                              message: NSLocalizedString("Do you want to change this in Settings?", comment: "Do you want to change this in Settings?"),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))
                let confirmAction = UIAlertAction(title: NSLocalizedString("Authorize", comment: "Authorize"), style: .default) { _ in
                    
                    // Open iOS Settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                              options: [:])
                }
                alert.addAction(confirmAction)
                alert.preferredAction = confirmAction
                self.present(alert, animated: true)
            }
            
        case .authorized:
            // User shares access, dismiss this Request view
            musics = MusicLibrary()
            DispatchQueue.main.async {
                self.musicTableview.reloadData()
            }
        }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension MusicViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if musics == nil {
            return 0
        }
        return musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTVCell", for: indexPath) as? MusicTVCell else { return MusicTVCell() }
        
        let data = musics[indexPath.row]
        cell.configureWithData(data, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is MusicTVCell {
            let musicCell = cell as! MusicTVCell
            musicCell.resetCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 8.0
    }
}

extension MusicViewController: MusicTVCellDelegate {
    func didClickUseButton(indexPath: IndexPath) {
        let data = musics[indexPath.row]
        delegate.didSelectMusic(music: data)
        navigationController?.popViewController(animated: true)
    }
}
