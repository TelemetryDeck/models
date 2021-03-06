import Foundation

/// Extraction functions define the transformation applied to each dimension value.
public indirect enum ExtractionFunction: Codable, Equatable, Hashable {
    case regex(RegularExpressionExtractionFunction)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "regex":
            self = .regex(try RegularExpressionExtractionFunction(from: decoder))
        default:
            throw EncodingError.invalidValue("Invalid type", .init(codingPath: [CodingKeys.type], debugDescription: "Invalid Type", underlyingError: nil))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .regex(regexFunction):
            try container.encode("regex", forKey: .type)
            try regexFunction.encode(to: encoder)
        }
    }
}

/// Returns the first matching group for the given regular expression. If there is no match,
/// it returns the dimension value as is.
public struct RegularExpressionExtractionFunction: Codable, Equatable, Hashable {
    public init(expr: String, index: Int = 1, replaceMissingValue: Bool = false, replaceMissingValueWith: String? = nil) {
        self.expr = expr
        self.index = index
        self.replaceMissingValue = replaceMissingValue
        self.replaceMissingValueWith = replaceMissingValueWith
    }

    /// The regular expression to match.
    ///
    /// For example, using `(\\w\\w\\w).*` will transform 'Monday', 'Tuesday', 'Wednesday' into 'Mon', 'Tue', 'Wed'.
    public let expr: String

    /// The group to extract, default 1
    public let index: Int

    /// If the replaceMissingValue property is true, the extraction function will transform dimension values that do not match the regex pattern to a user-specified String. Default value is false.
    public let replaceMissingValue: Bool

    /// Sets the String that unmatched dimension values will be replaced with.
    ///
    /// The replaceMissingValueWith property sets the String that unmatched dimension values will
    /// be replaced with, if replaceMissingValue is true. If replaceMissingValueWith is not
    /// specified, unmatched dimension values will be replaced with nulls.
    public let replaceMissingValueWith: String?
}
