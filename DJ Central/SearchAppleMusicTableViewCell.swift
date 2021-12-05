//
//  SearchAppleMusicTableViewCell.swift
//  DJ Central
//
//  Created by William Thompson on 6/22/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//

import UIKit

class SearchAppleMusicTableViewCell: UITableViewCell {
    
    static let identifier = "SearchAppleMusicTableViewCell"
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    
    weak var delegate: SearchAppleMusicTableViewCellDelegate?
    var mediaItem: MediaItem? {
        didSet {
            songTitleLabel.text = mediaItem?.name ?? ""
            songArtistLabel.text = mediaItem?.artistName ?? ""
            albumArtworkImageView.image = nil
            
        }
    }
    
    @IBAction func addToPlaylist(_ sender: UIButton) {
        if let mediaItem = mediaItem {
            delegate?.searchAppleMusicTableViewCell(self, addToPlaylist: mediaItem)
        }
        
    }
    
    @IBAction func playMediaItem(_ sender: UIButton) {
        if let mediaItem = mediaItem {
            delegate?.searchAppleMusicTableViewCell(self, playMediaItem: mediaItem)
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol SearchAppleMusicTableViewCellDelegate: AnyObject {
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, addToPlaylist mediaItem: MediaItem)
    
    func searchAppleMusicTableViewCell(_ searchAppleMusicTableViewCell: SearchAppleMusicTableViewCell, playMediaItem mediaItem: MediaItem)
}
