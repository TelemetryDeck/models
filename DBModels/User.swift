import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    /// if true, this user may not be deleted
    @Field(key: "is_founding_user")
    var isFoundingUser: Bool

    @Field(key: "email")
    var email: String

    @Field(key: "receive_marketing_emails")
    var receiveMarketingEmails: Bool

    @Field(key: "password_hash")
    var passwordHash: String

    @Parent(key: "organization_id")
    var organization: Organization

    init() {}

    init(id: UUID? = nil, firstName: String, lastName: String, isFoundingUser: Bool, email: String, receiveMarketingEmails: Bool, passwordHash: String, organizationID: UUID) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isFoundingUser = isFoundingUser
        self.email = email
        self.receiveMarketingEmails = receiveMarketingEmails
        self.passwordHash = passwordHash
        $organization.id = organizationID
    }
}

struct UserDataTransferObject: Content {
    let id: UUID
    let organization: Organization?
    let isFoundingUser: Bool
    let firstName: String
    let lastName: String
    let email: String

    init(user: User) {
        id = user.id!
        organization = user.$organization.value
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        isFoundingUser = user.isFoundingUser
    }
}

extension User: CaseInsensitiveModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    /// Used for email/password login in order to generate Tokens
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }

    /// Return the canonical hashed version of the given password string
    static func hash(from password: String) -> String {
        // Bcrypt is a password hashing algorithm that uses a randomized salt to ensure
        // hashing the same password multiple times doesn't result in the same digest.
        let hashedPassword = try! Bcrypt.hash(password)

        return hashedPassword
    }

    /// Used to generate login tokens for use in the rest of the API
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: requireID()
        )
    }
}
