//
//  TVSeasons.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18/09/2019.
//

import Foundation

enum TVSeasons {
    case accountStates(tvId: Int, sessionsId: String)

    case changes(seasonId: Int)

    case credits(tvId: Int, seasonNumber: Int)

    case details(tvId: Int, seasonNumber: Int)

    case externalIds(tvId: Int, seasonNumber: Int)

    case images(tvId: Int, seasonNumber: Int)

    case videos(tvId: Int, seasonNumber: Int)
}
