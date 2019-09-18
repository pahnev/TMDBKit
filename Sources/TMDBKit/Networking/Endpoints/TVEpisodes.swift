//
//  TVEpisodes.swift
//  TMDBKit
//
//  Created by Pahnev, Kirill on 18/09/2019.
//

import Foundation

enum TVEpisodes {
    case accountStates(tvId: Int, seasonNumber: String, episodeNumber: Int)

    case changes(episodeId: Int)

    case credits(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case details(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case externalIds(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case images(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case videos(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case translations(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case rateEpisode(tvId: Int, seasonNumber: Int, episodeNumber: Int)

    case deleteRating(tvId: Int, seasonNumber: Int, episodeNumber: Int)
}
