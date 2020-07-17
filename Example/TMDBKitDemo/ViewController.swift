//
//  ViewController.swift
//  TMDBDemo
//
//  Created by Kirill Pahnev on 05/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import UIKit
import TMDBKit
import AuthenticationServices

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
    var webAuthSession: ASWebAuthenticationSession?

    var movies = [MovieFragment]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let sessionId = UserDefaults.standard.value(forKey: "sessionID") as? String {
            print("Found sessionId in storage. Setting up TMDB session")
            tmdb.setSessionProvider(Session(sessionId: sessionId))
        }

        tmdb.movies.popular(pageNumber: 1) { result in
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
            fatalError("Failed to create authentication URL")
        }

        let redirectScheme = "tmdbDemo://"
        let authWithRedirect = authURL.appendingQueryItem(URLQueryItem(name: "redirect_to", value: redirectScheme))

        webAuthSession = ASWebAuthenticationSession(url: authWithRedirect, callbackURLScheme: redirectScheme) { _, error in
            guard error == nil else {
                return print(error!)
            }

            self.tmdb.createSession(requestToken: token, completion: { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let session):
                    self.tmdb.setSessionProvider(Session(sessionId: session.sessionId))
                    UserDefaults.standard.set(session.sessionId, forKey: "sessionID")
                }
            })
        }

        webAuthSession?.presentationContextProvider = self
        webAuthSession?.start()
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

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window ?? ASPresentationAnchor()
    }
}

extension URL {
    func appendingQueryItem(_ queryItem: URLQueryItem) -> URL {
        guard var urlComps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Invalid url \(self)")
        }

        let currentQueryItems = urlComps.queryItems ?? []
        urlComps.queryItems = currentQueryItems + [queryItem]

        return urlComps.url!
    }
}
