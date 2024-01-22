//
//  URLRequestBuilder.swift
//  ImageFeed
//
//  Created by Дмитрий Зайцев on 08.12.23.
//

import Foundation

final class URLRequestBuilder {

    static let shared = URLRequestBuilder()

    private let storage: OAuth2TokenStorage

    init(storage: OAuth2TokenStorage = OAuth2TokenStorage()) {
        self.storage = storage
    }

    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String
    ) -> URLRequest? {
        guard
            let url = URL(string: baseURLString),
            let baseUrl = URL(string: path, relativeTo: url)
        else { return nil }

        var request = URLRequest (url: baseUrl)
        request.httpMethod = httpMethod

        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

