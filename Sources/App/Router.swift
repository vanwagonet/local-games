import Hummingbird

/// Build router
func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    router.addMiddleware {
        LogRequestsMiddleware(.info)
        FileMiddleware(cacheControl: .init([ (MediaType(type: .any), [ .noCache, .noStore ]) ]))
        SessionMiddleware()
    }

    router.addRoutes(HomeController().routes)
    router.addRoutes(ScrambleController().routes, atPath: "/scramble")

    router.get("/health") { _, _ in
        HTTPResponse.Status.ok
    }

    return router
}
