import Hummingbird
import class Foundation.JSONDecoder

struct AppRequestDecoder: RequestDecoder {
    func decode<T: Decodable>(_ type: T.Type, from request: Request, context: some RequestContext) async throws -> T {
        guard let contentType = request.headers[.contentType].flatMap(MediaType.init(from:)) else {
            throw HTTPError(.badRequest)
        }
        switch contentType {
        case .applicationJson:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try await decoder.decode(type, from: request, context: context)
        case .applicationUrlEncoded:
            var decoder = URLEncodedFormDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try await decoder.decode(type, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
