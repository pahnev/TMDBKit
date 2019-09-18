//
//  ViewController.swift
//  TMDBDemo
//
//  Created by Kirill Pahnev on 05/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import UIKit
import TMDBKit
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
import SafariServices

struct Auth: Authenticator {
    let apiKey: String
    let sessionId: String?
}

struct Session: SessionProvider {
    let sessionId: String
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let auth = Auth(apiKey: "123", sessionId: nil)
    lazy var tmdb = try! TMDB(authenticator: auth)
//    #if @available(iOS 12.0, *) {
//        var webAuthSession: ASWebAuthenticationSession?
//    }

    var movies = [MovieFragment]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let sessionId = UserDefaults.standard.value(forKey: "sessionID") as? String {
            tmdb.setSessionProvider(Session(sessionId: sessionId))
        }

        tmdb.getPopularMovies(pageNumber: 1) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self.movies = response.results
            }
        }
    }

    func authenticate(requestToken token: RequestToken) {

        guard let authURL = URL(string: "https://www.themoviedb.org/authenticate/\(token.requestToken)") else {
            return print("URL fucked up")
        }
        let redirectScheme = "tmdbDemo://"
//        let new = authURL.appendingQueryItem(URLQueryItem(name: "redirect_to", value: redirectScheme))
//        #if @available(iOS 12.0, *) {
//            self.webAuthSession = ASWebAuthenticationSession(url: new, callbackURLScheme: redirectScheme) { callbackURL, error in
//                guard error == nil, let callbackURL = callbackURL else {
//                    print(error)
//                    return
//                }
//
//                self.tmdb.createSession(requestToken: token, completion: { result in
//                    switch result {
//                    case .error(let error):
//                        print(error)
//                    case .success(let session):
//                        self.tmdb.setSessionProvider(Session(sessionId: session.sessionId))
//                        UserDefaults.standard.set(session.sessionId, forKey: "sessionID")
//                    }
//                })
//            }
//
//            self.webAuthSession?.start()
//        }

    }

    @IBAction func login(_ sender: Any) {
        tmdb.createRequestToken { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let token):
                print(token)
                self.authenticate(requestToken: token)
            }
        }

    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let movie = movies[indexPath.row]
        cell.textLabel?.text = movie.title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = movies[indexPath.row]
        let vc = MovieDetailsViewController(tmdb: tmdb, movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
}
