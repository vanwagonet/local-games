import Hummingbird

extension Request {
    var acceptList: [MediaType]? {
        headers[.accept]?
            .split(separator: ",")
            .map {
                let parts = $0.split(separator: ";q=")
                let type = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines)
                let quality = parts.count > 1 ? Double(parts[1].trimmingCharacters(in: .whitespacesAndNewlines)) : nil
                return (type ?? "", quality ?? 1)
            }
            .sorted { $0.1 < $1.1 }
            .compactMap { MediaType(from: $0.0) }
    }

    func negotiate<Context: RequestContext>(
        context: Context,
        response: (MediaType?) async throws -> (any ResponseGenerator)?
    ) async throws -> Response {
        try await negotiate { try await response($0)?.response(from: self, context: context) }
    }

    func negotiate(_ response: (MediaType?) async throws -> Response?) async throws -> Response {
        for type in acceptList ?? [] {
            if let response = try await response(type) {
                return response
            }
        }
        if let response = try await response(nil) {
            return response
        }
        throw HTTPError(.notAcceptable)
    }
}
