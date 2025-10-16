protocol OptionalProtocol {
    associatedtype Wrapped
    var wrapped: Wrapped? { get set }
}

extension Optional: OptionalProtocol {
    var wrapped: Wrapped? {
        get { self }
        set { self = newValue }
    }
}
