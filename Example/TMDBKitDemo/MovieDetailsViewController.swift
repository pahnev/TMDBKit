//
//  MovieDetailsViewController.swift
//  TMDBDemo
//
//  Created by Kirill Pahnev on 19/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import UIKit
import TMDBKit

class MovieDetailsViewController: UIViewController {

    private let movie: MovieFragment
    private let tmdb: TMDB
    private var fullMovie: Movie? {
        didSet {
            guard let fullMovie = fullMovie else { return }
            ratingLabel.text = String(fullMovie.voteCount) ?? ""
        }
    }
    @IBOutlet weak var ratingLabel: UILabel!

    init(tmdb: TMDB, movie: MovieFragment) {
        self.tmdb = tmdb
        self.movie = movie

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        tmdb.movies.details(for: movie.id, appending: [.images(languages: nil)]) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let value):
                self.fullMovie = value
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func setRating(_ sender: UIButton) {
        tmdb.movies.rateMovie(movie.id, rating: 1.0) { (result) in
            print(result)
        }
    }
    @IBAction func removeRating(_ sender: Any) {
        tmdb.movies.deleteRating(of: movie.id) { (result) in
            print(result)
        }
    }
}
