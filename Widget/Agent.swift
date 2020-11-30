import Combine
import Foundation

enum TodoAPI {
    static let agent = Agent()
    static let base = URL(string: "https://jsonplaceholder.typicode.com")!
}

extension TodoAPI {
    static func todos() -> AnyPublisher<[Todo], Error> {
        let request = URLRequest(url: base.appendingPathComponent("todos"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

struct Agent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct Todo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
