//
//  MovieDetailViewController.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import UIKit
import CoreData
class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var moviePoster: UIImageView!
    @IBOutlet var movieDetail: UITextView!
    @IBOutlet var favoriteButton: UIBarButtonItem!
    
    var movie: MovieTableViewItem!
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = movie.title
        
        if movie.isFav {
            favoriteButton.tintColor = UIColor.red
        }
        
        moviePoster.image = UIImage(named: "PosterPlaceholder")
        TMDBClient.downloadPosterImage(path: movie.posterPath) { data, error in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            self.moviePoster.image = image
        }
        moviePoster.layer.borderWidth = 1
        moviePoster.layer.borderColor = UIColor.lightGray.cgColor
        TMDBClient.getMovieDetails(id: movie.id) { movieDetail, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showErrorAlert(message: "could not fetch the details")
                    return
                }
                if let movieDetail = movieDetail {
                    self.movieDetail.text = "\(movieDetail.originalTitle ?? "")\n" +  "\(movieDetail.overview ?? "")\n" + "Release Date: \(movieDetail.releaseDate ?? "")\n"  + "Vote Count: \(movieDetail.voteCount ?? 0)"
                }
            }
        }
    }
    // MARK: - Helpers
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        if movie.isFav {
            favoriteButton.tintColor = UIColor.gray
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"FavoriteMovies")
            
            fetchRequest.predicate = NSPredicate(format: "favoriteMovieId = %@", "\(movie.id)")
            do
            {
                let fetchedResults =  try context.fetch(fetchRequest) as? [NSManagedObject]
                
                for entity in fetchedResults! {
                    
                    context.delete(entity)
                }
                try context.save()
            }
            catch _ {
                print("Could not be deleted!")
            }
        } else {
            favoriteButton.tintColor = UIColor.red
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let context = appDelegate.persistentContainer.viewContext
            let newMovie = NSEntityDescription.insertNewObject(forEntityName: "FavoriteMovies", into: context)
            
            newMovie.setValue(movie.id, forKey: "favoriteMovieId")
            
            do {
                try context.save()
            } catch  {
                print("Could not be saved!")
            }
        }
        movie.isFav.toggle()
    }
}

