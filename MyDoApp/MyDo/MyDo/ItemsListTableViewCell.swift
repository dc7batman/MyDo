//
//  ItemsListTableViewCell.swift
//  MyDo
//
//  Created by Mohan on 27/12/16.
//  Copyright © 2016 eventfy. All rights reserved.
//

import UIKit

class ItemsListTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
