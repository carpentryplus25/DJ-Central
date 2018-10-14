//
//  SongsTableViewCell.swift
//  DJ Central
//
//  Created by William Thompson on 6/9/17.
//  Copyright © 2017 J.W. Enterprises, LLC. All rights reserved.
//

import UIKit

protocol SongsTableViewCellDelegate: NSObjectProtocol {
    func didChangeVoteCount()
}

class SongsTableViewCell: UITableViewCell {

    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    
    var voteCount: Int = 0
    weak var delegate: SongsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func incrementVoteCount(_ sender: UIButton) {
        voteCount += 1
        delegate?.didChangeVoteCount()
    }
}
