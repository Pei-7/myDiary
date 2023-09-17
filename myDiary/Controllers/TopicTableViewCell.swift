//
//  TopicTableViewCell.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import UIKit

class TopicTableViewCell: UITableViewCell {

    @IBOutlet var ellipsisImageView: UIImageView!
    @IBOutlet var topicTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        topicTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
