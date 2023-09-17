//
//  DateTableViewCell.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
