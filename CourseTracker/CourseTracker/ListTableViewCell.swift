//
//  ListTableViewCell.swift
//  CourseTracker
//
//  Created by Rushan on 2017-06-13.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell{

    //MARK: Tableview Properties
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listTime: UILabel!
    @IBOutlet weak var listData: UILabel!
    @IBOutlet weak var listLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    

}
