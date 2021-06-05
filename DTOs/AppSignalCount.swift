import Foundation

public extension DTO {
    struct AppAdminEntry: Codable, Identifiable {
        public let id: UUID
        public let appName: String?
        public let organisationName: String?
        public let organisationID: UUID?
        public let signalCount: Int
        public let userCount: Int
    }
}

#if canImport(Vapor)
import Vapor

extension DTO.AppAdminEntry: Content {}
#endif
