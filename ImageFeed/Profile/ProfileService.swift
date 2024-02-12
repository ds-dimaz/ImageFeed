//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дмитрий Зайцев on 01.12.23.
//

import Foundation

final class ProfileService {

    static let shared = ProfileService()

    private let builder: URLRequestBuilder
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?

    private (set) var profile: Profile?

    init(builder: URLRequestBuilder = .shared) {
        self.builder = builder
    }

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        currentTask?.cancel()

        guard let request = makeProfileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let currentTask = urlSession.objectTask(for: request) { [weak self] (response: Result<ProfileResult, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.currentTask = currentTask
        currentTask.resume()
    }

    
    private func makeProfileRequest() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURLString: DefaultBaseURLString
        )
        
    }
}
