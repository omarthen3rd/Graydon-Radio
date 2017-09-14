//
//  AnnounementTableViewCell.swift
//  Radio Graydon
//
//  Created by Omar Abbasi on 2017-09-13.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class AnnounementTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
