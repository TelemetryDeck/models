//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

public struct UserDataTransferObject: Codable, Identifiable {
    public let id: UUID
    public let organization: Organization?
    public let firstName: String
    public let lastName: String
    public let email: String
    public let isFoundingUser: Bool
}

public struct Organization: Codable, Hashable {
    public init(id: UUID? = nil, name: String, isSuperOrg: Bool) {
        self.id = id
        self.name = name
        self.isSuperOrg = isSuperOrg
    }
    
    public var id: UUID?
    public var name: String
    public var isSuperOrg: Bool
}

public struct TelemetryApp: Codable, Hashable, Identifiable {
    public init(id: UUID, name: String, organization: [String : String]) {
        self.id = id
        self.name = name
        self.organization = organization
    }
    
    public var id: UUID
    public var name: String
    public var organization: [String: String]
}

public struct Signal: Codable, Hashable {
    public init(id: UUID? = nil, receivedAt: Date, clientUser: String, type: String, payload: [String : String]? = nil) {
        self.id = id
        self.receivedAt = receivedAt
        self.clientUser = clientUser
        self.type = type
        self.payload = payload
    }
    
    public var id: UUID?
    public var receivedAt: Date
    public var clientUser: String
    public var type: String
    public var payload: [String: String]?
}

public struct InsightGroup: Codable, Identifiable, Hashable {
    public var id: UUID
    public var title: String
    public var order: Double?
    public var insights: [Insight] = []

    public func getDTO() -> InsightGroupDTO {
        InsightGroupDTO(id: id, title: title, order: order)
    }

    public static func == (lhs: InsightGroup, rhs: InsightGroup) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct InsightGroupDTO: Codable, Identifiable {
    public init(id: UUID, title: String, order: Double? = nil) {
        self.id = id
        self.title = title
        self.order = order
    }
    
    public var id: UUID
    public var title: String
    public var order: Double?
}

public enum InsightDisplayMode: String, Codable {
    case number // Deprecated, use Raw instead
    case raw
    case barChart
    case lineChart
    case pieChart
}

public enum InsightGroupByInterval: String, Codable {
    case hour
    case day
    case week
    case month
}

public struct Insight: Codable, Identifiable {
    public var id: UUID
    public var group: [String: UUID]

    public var order: Double?
    public var title: String
    public var subtitle: String?

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public var signalType: String?

    /// If true, only include at the newest signal from each user
    public var uniqueUser: Bool

    /// Only include signals that match all of these key-values in the payload
    public var filters: [String: String]

    /// How far to go back to aggregate signals
    public var rollingWindowSize: TimeInterval

    /// If set, break down the values in this key
    public var breakdownKey: String?

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: InsightGroupByInterval?

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode

    /// If true, the insight will be displayed bigger
    public var isExpanded: Bool

    /// The amount of time (in seconds) this query took to calculate last time
    public var lastRunTime: TimeInterval?

    /// The query that was last used to run this query
    public var lastQuery: String?

    /// The date this query was last run
    public var lastRunAt: Date?

    /// Should use druid for calculating this insght
    public var shouldUseDruid: Bool
}

public struct InsightData: Codable {
    public init(xAxisValue: String, yAxisValue: String?) {
        self.xAxisValue = xAxisValue
        self.yAxisValue = yAxisValue
    }
    
    public let xAxisValue: String
    public let yAxisValue: String?

    public enum CodingKeys: String, CodingKey {
        case xAxisValue
        case yAxisValue
    }

    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()

    public var yAxisNumber: NSNumber? {
        guard let yAxisValue = yAxisValue else { return NSNumber(value: 0) }
        return numberFormatter.number(from: yAxisValue)
    }

    public var yAxisDouble: Double? {
        yAxisNumber?.doubleValue
    }

    public var yAxisString: String {
        guard let yAxisValue = yAxisValue else { return "0" }
        guard let yAxisNumber = yAxisNumber else { return yAxisValue }
        return numberFormatter.string(from: yAxisNumber) ?? yAxisValue
    }

    public var xAxisDate: Date? {
        if #available(macOS 10.14, iOS 14.0, *) {
            return Formatter.iso8601noFS.date(from: xAxisValue) ?? Formatter.iso8601.date(from: xAxisValue)
        } else {
            return nil
        }
    }
}

public struct InsightDataTransferObject: Codable {
    public init(id: UUID, order: Double?, title: String, subtitle: String?, signalType: String?, uniqueUser: Bool, filters: [String : String], rollingWindowSize: TimeInterval, breakdownKey: String? = nil, groupBy: InsightGroupByInterval? = nil, displayMode: InsightDisplayMode, data: [InsightData], calculatedAt: Date, calculationDuration: TimeInterval, shouldUseDruid: Bool?) {
        self.id = id
        self.order = order
        self.title = title
        self.subtitle = subtitle
        self.signalType = signalType
        self.uniqueUser = uniqueUser
        self.filters = filters
        self.rollingWindowSize = rollingWindowSize
        self.breakdownKey = breakdownKey
        self.groupBy = groupBy
        self.displayMode = displayMode
        self.data = data
        self.calculatedAt = calculatedAt
        self.calculationDuration = calculationDuration
        self.shouldUseDruid = shouldUseDruid
    }
    
    public let id: UUID

    public let order: Double?
    public let title: String
    public let subtitle: String?

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public let signalType: String?

    /// If true, only include at the newest signal from each user
    public let uniqueUser: Bool

    /// Only include signals that match all of these key-values in the payload
    public let filters: [String: String]

    /// How far to go back to aggregate signals
    public let rollingWindowSize: TimeInterval

    /// If set, break down the values in this key
    public var breakdownKey: String?

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: InsightGroupByInterval?

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode

    /// Current Live Calculated Data
    public let data: [InsightData]

    /// When was this DTO calculated?
    public let calculatedAt: Date

    /// How long did this DTO take to calculate?
    public let calculationDuration: TimeInterval

    /// Should use druid for calculating this insght
    public let shouldUseDruid: Bool?

    public var isEmpty: Bool {
        data.compactMap(\.yAxisValue).count == 0
    }
}

public struct InsightDefinitionRequestBody: Codable {
    public init(order: Double? = nil, title: String, subtitle: String? = nil, signalType: String? = nil, uniqueUser: Bool, filters: [String : String], rollingWindowSize: TimeInterval, breakdownKey: String? = nil, groupBy: InsightGroupByInterval? = nil, displayMode: InsightDisplayMode, groupID: UUID? = nil, id: UUID? = nil, isExpanded: Bool, shouldUseDruid: Bool) {
        self.order = order
        self.title = title
        self.subtitle = subtitle
        self.signalType = signalType
        self.uniqueUser = uniqueUser
        self.filters = filters
        self.rollingWindowSize = rollingWindowSize
        self.breakdownKey = breakdownKey
        self.groupBy = groupBy
        self.displayMode = displayMode
        self.groupID = groupID
        self.id = id
        self.isExpanded = isExpanded
        self.shouldUseDruid = shouldUseDruid
    }
    
    public var order: Double?
    public var title: String
    public var subtitle: String?

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public var signalType: String?

    /// If true, only include at the newest signal from each user
    public var uniqueUser: Bool

    /// Only include signals that match all of these key-values in the payload
    public var filters: [String: String]

    /// How far to go back to aggregate signals
    public var rollingWindowSize: TimeInterval

    /// If set, break down the values in this key
    public var breakdownKey: String?

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: InsightGroupByInterval?

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode

    /// Which group should the insight belong to? (Only use this in update mode)
    public var groupID: UUID?

    /// The ID of the insight. Not changeable, only set in update mode
    public var id: UUID?

    /// If true, the insight will be displayed bigger
    public var isExpanded: Bool

    /// Should use druid for calculating this insght
    public var shouldUseDruid: Bool

    public static func from(insight: Insight) -> InsightDefinitionRequestBody {
        let requestBody = Self(
            order: insight.order,
            title: insight.title,
            subtitle: insight.subtitle,
            signalType: insight.signalType,
            uniqueUser: insight.uniqueUser,
            filters: insight.filters,
            rollingWindowSize: insight.rollingWindowSize,
            breakdownKey: insight.breakdownKey,
            groupBy: insight.groupBy ?? .day,
            displayMode: insight.displayMode,
            groupID: insight.group["id"],
            id: insight.id,
            isExpanded: insight.isExpanded,
            shouldUseDruid: insight.shouldUseDruid
        )

        return requestBody
    }

    public static func newTimeSeriesInsight(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "New Time Series Insight",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }

    public static func newBreakdownInsight(groupID: UUID, title: String? = nil, breakdownKey: String? = nil) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: title ?? "New Breakdown Insight",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: breakdownKey ?? "systemVersion",
            groupBy: .day,
            displayMode: .pieChart,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }

    public static func newDailyUserCountInsight(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "Daily Active Users",
            subtitle: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }

    public static func newWeeklyUserCountInsight(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "Weekly Active Users",
            subtitle: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .week,
            displayMode: .barChart,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }

    public static func newMonthlyUserCountInsight(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "Active Users this Month",
            subtitle: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .month,
            displayMode: .raw,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }

    public static func newSignalInsight(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "Signals by Day",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            groupID: groupID,
            id: nil,
            isExpanded: false,
            shouldUseDruid: false
        )
    }
}

public struct ChartDataPoint: Hashable, Identifiable {
    public var id: String { xAxisValue }

    public let xAxisValue: String
    public let yAxisValue: Double

    public init(insightData: InsightData) throws {
        xAxisValue = insightData.xAxisValue

        if let yAxisValue = insightData.yAxisDouble {
            self.yAxisValue = yAxisValue
        } else {
            throw ChartDataSet.DataError.insufficientData
        }
    }
}

public enum RegistrationStatus: String, Codable {
    case closed
    case tokenOnly
    case open
}

public enum TransferError: Error {
    case transferFailed
    case decodeFailed
    case serverError(message: String)

    public var localizedDescription: String {
        switch self {
        case .transferFailed:
            return "There was a communication error with the server. Please check your internet connection and try again later."
        case .decodeFailed:
            return "The server returned a message that this version of the app could not decode. Please check if there is an update to the app, or contact the developer."
        case let .serverError(message: message):
            return "The server returned this error message: \(message)"
        }
    }
}

public struct ServerErrorDetailMessage: Codable {
    public let detail: String
}

public struct ServerErrorReasonMessage: Codable {
    public let reason: String
}

public struct PasswordChangeRequestBody: Codable {
    public init(oldPassword: String, newPassword: String, newPasswordConfirm: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.newPasswordConfirm = newPasswordConfirm
    }
    
    public var oldPassword: String
    public var newPassword: String
    public var newPasswordConfirm: String
}

public struct BetaRequestEmail: Codable, Identifiable, Equatable {
    public let id: UUID
    public let email: String
    public let registrationToken: String
    public let requestedAt: Date
    public let sentAt: Date?
    public let isFulfilled: Bool
}

public struct LexiconSignalType: Codable, Identifiable {
    public init(id: UUID, firstSeenAt: Date, isHidden: Bool, type: String) {
        self.id = id
        self.firstSeenAt = firstSeenAt
        self.isHidden = isHidden
        self.type = type
    }
    
    public let id: UUID
    public let firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    public let isHidden: Bool
    public let type: String
}

public struct LexiconPayloadKey: Codable, Identifiable {
    public init(id: UUID, firstSeenAt: Date, isHidden: Bool, payloadKey: String) {
        self.id = id
        self.firstSeenAt = firstSeenAt
        self.isHidden = isHidden
        self.payloadKey = payloadKey
    }
    
    public let id: UUID
    public let firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    public let isHidden: Bool
    public let payloadKey: String
}

/// Represents a standing invitation to join an organization
public struct OrganizationJoinRequest: Codable, Identifiable, Equatable {
    public let id: UUID
    public let email: String
    public let registrationToken: String
    public let organization: [String: UUID]
}

/// Sent to the server to create a user belonging to the organization
public struct OrganizationJoinRequestURLObject: Codable {
    public init(email: String, firstName: String, lastName: String, password: String, organizationID: UUID, registrationToken: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.organizationID = organizationID
        self.registrationToken = registrationToken
    }
    
    public var email: String
    public var firstName: String
    public var lastName: String
    public var password: String
    public let organizationID: UUID
    public var registrationToken: String
}

public struct RegistrationRequestBody: Codable {
    public init() {}
    
    public var registrationToken: String = ""
    public var organisationName: String = ""
    public var userFirstName: String = ""
    public var userLastName: String = ""
    public var userEmail: String = ""
    public var userPassword: String = ""
    public var userPasswordConfirm: String = ""

    public var isValid: Bool {
        !organisationName.isEmpty && !userFirstName.isEmpty && !userEmail.isEmpty && !userPassword.isEmpty && !userPasswordConfirm.isEmpty && !userPassword.contains(":")
    }
}

public struct LoginRequestBody {
    public init(userEmail: String = "", userPassword: String = "") {
        self.userEmail = userEmail
        self.userPassword = userPassword
    }
    
    public var userEmail: String = ""
    public var userPassword: String = ""

    public var basicHTMLAuthString: String? {
        let loginString = "\(userEmail):\(userPassword)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }

    public var isValid: Bool {
        !userEmail.isEmpty && !userPassword.isEmpty
    }
}

public struct RequestPasswordResetRequestBody: Codable {
    public init(email: String = "", code: String = "", newPassword: String = "") {
        self.email = email
        self.code = code
        self.newPassword = newPassword
    }
    
    public var email: String = ""
    public var code: String = ""
    public var newPassword: String = ""

    public var isValidEmailAddress: Bool {
        !email.isEmpty
    }

    public var isValid: Bool {
        !email.isEmpty && !code.isEmpty && !newPassword.isEmpty
    }
}

public struct UserToken: Codable {
    public var id: UUID?
    public var value: String
    public var user: [String: String]

    public var bearerTokenAuthString: String {
        "Bearer \(value)"
    }
}

public struct BetaRequestUpdateBody: Codable {
    public init(sentAt: Date?, isFulfilled: Bool) {
        self.sentAt = sentAt
        self.isFulfilled = isFulfilled
    }
    
    public let sentAt: Date?
    public let isFulfilled: Bool
}

public struct ChartDataSet {
    public enum DataError: Error {
        case insufficientData
    }

    public let data: [ChartDataPoint]
    public let lowestValue: Double
    public let highestValue: Double

    public init(data: [InsightData]) throws {
        self.data = try data.map { try ChartDataPoint(insightData: $0) }

        highestValue = self.data.reduce(0) { max($0, $1.yAxisValue) }
        lowestValue = 0
    }
}

public struct OrganizationAdminListEntry: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let foundedAt: Date
    public let sumSignals: Int
    public let isSuperOrg: Bool
    public let firstName: String?
    public let lastName: String?
    public let email: String
}

public struct AggregateDTO: Codable {
    public let min: TimeInterval
    public let avg: TimeInterval
    public let max: TimeInterval
}

public enum AppRootViewSelection: Hashable {
    case insightGroup(group: InsightGroup)
    case lexicon
    case rawSignals
    case noSelection
}
