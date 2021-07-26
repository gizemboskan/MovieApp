//
//  MovieCell.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var movieFavView: UIImageView! {
        didSet {
            movieFavView.alpha = 0
        }
    }
    
}
