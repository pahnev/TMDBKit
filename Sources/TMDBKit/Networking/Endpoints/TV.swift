//
//  TV.swift
//  TMDBKit
//
//  Created by Kirill Pahnev on 20/07/2018.
//  Copyright © 2018 Pahnev. All rights reserved.
//

import Foundation

enum TV {
    case accountStates(tvId: Int, sessionsId: String)

    case details(tvId: Int)

    case changes(tvId: Int)

    case contentRatings(tvId: Int)

    case credits(tvId: Int)

    case externalIds(tvId: Int)

    case images(tvId: Int)

    case keywords(tvId: Int)

    case recommendations(tvId: Int, pageNumber: PageNumber)

    case reviews(tvId: Int, pageNumber: PageNumber)

    /// Get a list of seasons or episodes that have been screened in a film festival or theatre
    case screenedTheatrically(tvId: Int)

    case similarShows(tvId: Int, pageNumber: PageNumber)

    case translations(tvId: Int)

    case videos(tvId: Int)

    case latest

    case rateMovie(rating: Double, tvId: Int, sessionId: String)

    case deleteRating(tvId: Int, sessionId: String)

    case popular(pageNumber: PageNumber)

    /// Get the top rated movies on TMDb.
    case topRated(pageNumber: PageNumber)

    case airingToday

    case onTheAir
}
