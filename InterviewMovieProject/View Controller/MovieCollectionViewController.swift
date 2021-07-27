//
//  MovieCollectionViewController.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import UIKit
import CoreData

class MovieCollectionViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    
    var filteredMovies = [MovieTableViewItem]()
    var isFiltering: Bool = false
    
    var currentPage: Int = 1
    var isLoadingList: Bool = false
    
    var dataSource = [MovieTableViewItem]()
    var favMovieIds = [Int]()
    
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        loadMoreMovies()
        collectionView.restore()
        setupCollectionUI(currentWidth: view.frame.size.width)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    // MARK: - Helpers
    private func getFavorites() {
        favMovieIds.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovies")
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    guard let favoriteMovieId = result.value(forKey: "favoriteMovieId") as? Int else { return }
                    self.favMovieIds.append(favoriteMovieId)
                    self.checkFavoriteUpdates()
                }
            }
        } catch {
            print("Error")
        }
    }
    private func getMovies(_ pageNumber: Int) {
        TMDBClient.getPopularMovies(page: pageNumber) { result, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showErrorAlert(message: "something went wrong!")
                    return
                }
                let mappedResult = result.map({MovieTableViewItem(id: $0.id, releaseYear: String($0.releaseDate?.prefix(4) ?? ""), title: $0.title, posterPath: $0.posterPath, isFav: self.favMovieIds.contains($0.id))})
                
                self.dataSource.append(contentsOf: mappedResult)
                self.isLoadingList = false
                self.collectionView.reloadData()
            }
        }
    }
    func loadMoreMovies(){
        if currentPage <= 500 {
            currentPage += 1
            getMovies(currentPage)
        }
    }
    private func checkFavoriteUpdates(){
        if !dataSource.isEmpty{
            let newDataSource = dataSource.map({ MovieTableViewItem(id: $0.id, releaseYear: $0.releaseYear, title: $0.title, posterPath: $0.posterPath, isFav: self.favMovieIds.contains($0.id))
            })
            dataSource.removeAll()
            dataSource.append(contentsOf: newDataSource)
            filteredMovies.removeAll()
            filteredMovies.append(contentsOf: newDataSource)
            if isFiltering {
                if let isEmpty = searchBar.text?.isEmpty, !isEmpty{
                    searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text!)
                }
            }
            collectionView.reloadData()
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            self.loadMoreMovies()
        }
    }
    
    private func setupCollectionUI(currentWidth: CGFloat) {
        let space:CGFloat = 3.0
        let dimensionWidth = (currentWidth - (2 * space)) / 2.0
        let dimensionHeight = dimensionWidth
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
    }
}

// MARK: - UICollectionViewDataSource and Delegate
extension MovieCollectionViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredMovies.count
        }
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        
        var movies = [MovieTableViewItem]()
        if isFiltering {
            movies = filteredMovies
        }else {
            movies = dataSource
        }
        
        let movie = movies[indexPath.row]
        cell.name.numberOfLines = 0
        cell.name?.text = "\(movie.title) - \(movie.releaseYear)"
        cell.movieImageView?.image = UIImage(named: "PosterPlaceholder")
        TMDBClient.downloadPosterImage(path: movie.posterPath) { data, error in
            guard let data = data else {
                return
            }
            let image = UIImage(data: data)
            cell.movieImageView?.image = image
            cell.setNeedsLayout()
        }
        
        cell.movieImageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.movieImageView.layer.borderWidth = 2
        cell.movieImageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        if movie.isFav{
            cell.movieFavView.alpha = 1
        }else{
            cell.movieFavView.alpha = 0
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "movieDetail") as? MovieDetailViewController {
            
            var movies = [MovieTableViewItem]()
            if isFiltering{
                movies = filteredMovies
            }else {
                movies = dataSource
            }
            vc.movie = movies[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension MovieCollectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let isEmpty = searchBar.text?.isEmpty, isEmpty, searchText.isEmpty{
            DispatchQueue.main.async {
                self.isFiltering = false
                self.collectionView.restore()
                self.collectionView.reloadData()
                self.searchBar.resignFirstResponder()
                return
            }
        }
        
        isFiltering = true
        
        filteredMovies = dataSource.filter({ (movie: MovieTableViewItem) -> Bool in
            return movie.title.lowercased().contains(searchText.lowercased())
        })
        
        if filteredMovies.isEmpty {
            collectionView.setEmptyView(title: "Oops! Your search was not found.", message: "Search for another result!")
            self.isLoadingList = false
        }else {
            collectionView.restore()
            self.isLoadingList = true
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        collectionView.reloadData()
    }
}

// MARK: - Custom Empty View
extension UICollectionView {
    
    func setEmptyView(title: String, message: String){
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "empty"))
        
        imageView.backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 15)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageView)
        
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        
        titleLabel.numberOfLines = 0
        messageLabel.numberOfLines = 0
        
        UIView.animate(withDuration: 1, animations: {
            
            imageView.transform = CGAffineTransform(rotationAngle: .pi / 15)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 15))
            }, completion: { (finish) in
                UIView.animate(withDuration: 1, animations: {
                    imageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        self.backgroundView = emptyView
        
    }
    func restore() {
        self.backgroundView = nil
    }
}



