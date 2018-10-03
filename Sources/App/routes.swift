import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.post("create") { req in
        return SessionManager.shared.createSession(for: req)
    }
    
    router.post("close", Session.parameter) { req -> HTTPStatus in
        let session = try req.parameters.next(Session.self)
        SessionManager.shared.close(session)
        return .ok
    }
    
    router.post(Location.self, at: "update", Session.parameter) { req, location -> HTTPStatus in
        let session = try req.parameters.next(Session.self)
        SessionManager.shared.update(location, for: session)
        return .ok
    }
}
