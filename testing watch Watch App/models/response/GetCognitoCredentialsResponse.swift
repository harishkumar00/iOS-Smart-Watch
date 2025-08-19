import Foundation

struct GetCognitoCredentialsResponse: Codable {
    let identityPoolId: String
    let identityId: String
    let token: String
    let awsEndPoint: String
    let region: String
    let accountId: String
    let providerName: String

    enum CodingKeys: String, CodingKey {
        case identityPoolId = "identity_pool_id"
        case identityId = "identity_id"
        case token = "token"
        case awsEndPoint = "aws_endpoint"
        case region = "region"
        case accountId = "account_id"
        case providerName = "provider_name"
    }
}

