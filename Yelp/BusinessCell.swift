//
//  BusinessCell.swift
//  Yelp
//
//  Created by Shola Oyedele on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            distanceLabel.text = business.distance
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            
            if let reviewCount = business.reviewCount {
                reviewsCountLabel.text = "\(reviewCount) Reviews"
            } else {
                reviewsCountLabel.text = "No Reviews"
            }
            
            if let ratingsImg = business.ratingImageURL {
                ratingImageView.setImageWith(ratingsImg)
            }
            
            if let bizImage = business.imageURL {
                thumbImageView.setImageWith(bizImage)
            }
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
