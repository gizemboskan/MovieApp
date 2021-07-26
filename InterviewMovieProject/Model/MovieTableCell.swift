//
//  MovieTableCell.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 13.07.2021.
//

import Foundation
import UIKit

class MovieTableCell: UITableViewCell {
    
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var movieFavView: UIImageView! {
        didSet {
            movieFavView.alpha = 0
        }
    }
    @IBOutlet var name: UILabel!
}
