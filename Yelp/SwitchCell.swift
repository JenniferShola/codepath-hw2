//
//  SwitchCell.swift
//  Yelp
//
//  Created by Shola Oyedele on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import AIFlatSwitch

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var flipSwitch: AIFlatSwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func switchValueChanged(_ sender: AnyObject) {
        flipSwitch.animatesOnTouch = false
        
        if delegate != nil {
            delegate?.switchCell?(switchCell: self, didChangeValue: flipSwitch.isSelected)
        }
    }

}
