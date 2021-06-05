enum RuntimeOS {
    case iOS, macOS, tvOS, watchOS

    static var current: RuntimeOS {
        #if os(tvOS)
        return .tvOS
        #elseif os(macOS)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #else
        return .iOS
        #endif
    }
}
