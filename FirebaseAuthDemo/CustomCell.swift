//
//  CustomCell.swift
//  FirebaseAuthDemo
//
//  Created by Madhav on 25/08/19.
//  Copyright © 2019 Madhav. All rights reserved.
//

import UIKit

protocol CustomCellDelegate {
    func playPauseAction(CustomCell customCell:CustomCell, IsPlaying isPlaying: Bool)
}

class CustomCell: UICollectionViewCell {
    
    var isPlaying = Bool()
    
    var delegate: CustomCellDelegate?
    
    @IBOutlet weak var btnPlayPause: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10
    }
    
    @IBAction func actionPlayPause(_ sender: Any) {
        delegate?.playPauseAction(CustomCell: self, IsPlaying: isPlaying)
        isPlaying = !isPlaying
    }

}


