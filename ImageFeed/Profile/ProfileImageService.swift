//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий Зайцев on 13.12.23.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let requestBuilder = URLRequestBuilder.shared
    private var currentTask: URLSessionTask?
    
    private (set) var avatarURL: URL?
    
    func fetchProfileImageURL(username: String,
                              _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        currentTask?.cancel()
        
        guard let request = makeProfileImageRequest(userName: username) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.urlSessionError)) //TODO: Errors
            return
        }
        
        let urlSession = URLSession.shared
        
        let currentTask = urlSession.objectTask(for: request) { [weak self]
            (response: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch response {
            case .success(let profilePhoto):
                guard let mediumPhoto = profilePhoto.profileImage?.medium else { return }
                self.avatarURL = URL(string: mediumPhoto)
                completion(.success(mediumPhoto))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": mediumPhoto]
                )
            case .failure(let error):
                completion(.failure(error))
            }
            self.currentTask = nil
        }
        self.currentTask = currentTask
        currentTask.resume()
    }
    
    private func makeProfileImageRequest(userName: String) -> URLRequest? {
        requestBuilder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            baseURLString: DefaultBaseURLString)
    }
    
}


