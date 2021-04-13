//
//  MovieDetailsViewController.swift
//  TMDBDemo
//
//  Created by Kirill Pahnev on 19/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import TMDBKit
import UIKit

class MovieDetailsViewController: UIViewController {
    private let movie: MovieFragment
    private let tmdb: TMDB
    private var fullMovie: Movie? {
        didSet {
            guard let fullMovie = fullMovie else { return }
            ratingLabel.text = String(fullMovie.voteAverage)
            descriptionLabel.text = fullMovie.tagline
            guard let backdrop = fullMovie.backdropPath else { return }
            imageView.downloaded(from: "https://image.tmdb.org/t/p/w780/\(backdrop)")
        }
    }

    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    init(tmdb: TMDB, movie: MovieFragment) {
        self.tmdb = tmdb
        self.movie = movie

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
        tmdb.movies.details(for: movie.id, appending: [.images(languages: nil)]) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let value):
                self.fullMovie = value
            }
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func setRating(_ sender: UIButton) {
        tmdb.movies.rateMovie(movie.id, rating: 1.0) { result in
            print(result)
        }
    }

    @IBAction func removeRating(_ sender: Any) {
        tmdb.movies.deleteRating(of: movie.id) { result in
            print(result)
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) { // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }

    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) { // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
