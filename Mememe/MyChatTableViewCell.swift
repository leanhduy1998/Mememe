//
//  MyChatTableViewCell.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class MyChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userIV: UIImageView!
    
    @IBOutlet weak var messageTF: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
