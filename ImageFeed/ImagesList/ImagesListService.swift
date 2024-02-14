//  Created by Дмитрий Зайцев on 13.02.24.
//

import UIKit

class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let requestBuilder = URLRequestBuilder.shared
    private let photosPerPage = 10
    
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private (set) var photos: [Photo] = []
    
    func fetchPhotosNextPage(){
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let request = makeImagesListRequest(page: nextPage, perPage: photosPerPage) else {
            assertionFailure("Invalid Request")
            return
        }
        
        let currentTask = urlSession.objectTask(for: request) { [weak self] (response: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch response {
                case .success(let photoResultList):
                    let photos = photoResultList.map { (photo) -> Photo in
                        let size = CGSize(width: photo.width, height: photo.height)
                        
                        return Photo(
                            id: photo.id,
                            size: size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.description,
                            thumbImageURL: photo.urls.thumb ?? "",
                            largeImageURL: photo.urls.full ?? "",
                            isLiked: photo.likedByUser
                        )
                    }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: nil)
                case .failure(let error):
                    assertionFailure("Error: \(error)")
                }
                self.currentTask = nil
            }
        }
        self.currentTask = currentTask
        currentTask.resume()
    }
}

extension ImagesListService {
    func makeImagesListRequest(page: Int, perPage: Int) -> URLRequest? {
        requestBuilder.makeHTTPRequest(
            path: "/photos"
            + "&&page=\(page)"
            + "&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURLString: DefaultBaseURLString)
    }
}
