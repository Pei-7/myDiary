//
//  ResponseTableViewCell.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import UIKit

class ResponseTableViewCell: UITableViewCell {
    
    @IBOutlet var responseTextView: UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        responseTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
