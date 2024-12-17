import Hummingbird

struct AppRequestContext: RequestContext {
    let app = AppContext.default
    var coreContext: CoreRequestContextStorage
    var session: Session?

    init(source: Source) {
        self.coreContext = .init(source: source)
    }

    var requestDecoder: AppRequestDecoder { AppRequestDecoder() }
}
