// Keep original full Swift method names as well as ordinary calls source compatible.
// New optional parameters change method-reference arity even when they have defaults.

public extension TMDB.MovieEndpoints {
    /// Get movie changes using the original method signature and default first page.
    func changes(for movieId: Int, completion: @escaping TMDBResult<ChangesResponse>) {
        changes(for: movieId, pageNumber: 1, startDate: nil, endDate: nil, completion: completion)
    }

    /// Get movie images without an additional image-language filter.
    func images(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>) {
        images(for: movieId, language: language, includeImageLanguages: nil, completion: completion)
    }
}

public extension TVEndpoints {
    /// Get TV changes without a date range.
    func changes(for tvId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<TVChangesResponse>) {
        changes(for: tvId, pageNumber: pageNumber, startDate: nil, endDate: nil, completion: completion)
    }

    /// Get TV images without an additional image-language filter.
    func images(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>) {
        images(for: tvId, language: language, includeImageLanguages: nil, completion: completion)
    }

    /// Get TV videos without an additional video-language filter.
    func videos(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<VideosResponse>) {
        videos(for: tvId, language: language, includeVideoLanguages: nil, completion: completion)
    }

    /// Get shows airing today using the server's default timezone.
    func airingToday(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        airingToday(pageNumber: pageNumber, language: language, timezone: nil, completion: completion)
    }

    /// Get shows on the air using the server's default timezone.
    func onTheAir(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>) {
        onTheAir(pageNumber: pageNumber, language: language, timezone: nil, completion: completion)
    }
}

public extension TMDB.PeopleEndpoints {
    /// Get person changes without a date range.
    func changes(for personId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<ChangesResponse>) {
        changes(for: personId, pageNumber: pageNumber, startDate: nil, endDate: nil, completion: completion)
    }
}

public extension TrendingEndpoints {
    /// Get trending items using the server's default language.
    func trending(_ mediaType: MediaType, withinLast timeWindow: TimeWindow, completion: @escaping TMDBResult<TrendingResponse>) {
        trending(mediaType, withinLast: timeWindow, language: nil, completion: completion)
    }
}

public extension TMDB.ListEndpoints {
    /// Get list details using the server's default page.
    func details(for listId: String, language: String? = nil, completion: @escaping TMDBResult<ListDetails>) {
        details(for: listId, language: language, pageNumber: nil, completion: completion)
    }

    /// Check for a list item using the server's default language.
    func itemStatus(itemId: Int, listId: String, completion: @escaping TMDBResult<ListItemStatus>) {
        itemStatus(itemId: itemId, listId: listId, language: nil, completion: completion)
    }
}
