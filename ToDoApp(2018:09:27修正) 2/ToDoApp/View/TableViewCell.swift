//
//  TableViewCell.swift
//  ToDoApp
//
//  Created by 土井　麻菜美 on 2018/09/01.
//  Copyright © 2018年 Manami. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
        override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
