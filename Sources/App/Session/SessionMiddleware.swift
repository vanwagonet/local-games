import Hummingbird

struct SessionMiddleware: RouterMiddleware {
    typealias Context = AppRequestContext

    func handle(_ input: Request, context: Context, next: (Request, Context) async throws -> Output) async throws -> Response {
        var context = context

        if let cookie = input.cookies[Session.cookieName]?.value,
           let session = await context.app.sessions[cookie: cookie] {
            context.session = session
        }

        return try await next(input, context)
    }
}
