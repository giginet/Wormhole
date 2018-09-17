import Foundation

// SPM currently not supports file fixtures...

let errorResponse = """
{
"errors": [
{
"status": "400",
"id": "b91d85c7-b7db-4451-8f3f-9a3c8af9a392",
"title": "A parameter has an invalid value",
"detail": "'emaill' is not a valid filter type",
"code": "PARAMETER_ERROR.INVALID",
"source": {
"parameter": "filter[emaill]"
}
}
]
}
"""

let privateKey = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----
"""

let userResponse = """
{
"data": {
"type": "users",
"id": "b91d85c7-b7db-4451-8f3f-9a3c8af9a392",
"attributes": {
"firstName": "John",
"lastName": "Appleseed",
"email": "john-appleseed@mac.com",
"inviteType": "EMAIL",
"roles": ["DEVELOPER"]
},
"relationships": {},
"links": {
"self": ".../v1/betaTesters/4277b871-ce4e-4fc7-9e34"
}
}
}
"""

let usersResponse = """
{
"data": [
{
"type": "users",
"id": "b91d85c7-b7db-4451-8f3f-9a3c8af9a392",
"attributes": {
"firstName": "John",
"lastName": "Appleseed",
"email": "john-appleseed@mac.com",
"inviteType": "EMAIL",
"roles": ["DEVELOPER"]
},
"relationships": {},
"links": {
"self": ".../v1/betaTesters/4277b871-ce4e-4fc7-9e34"
}
},
{
"type": "users",
"id": "093a04ed-b021-42e3-a1df-5d064f05ec3f",
"attributes": {
"firstName": "John",
"lastName": "Appleseed",
"email": "john-appleseed@mac.com",
"inviteType": "EMAIL",
"roles": ["DEVELOPER"]
},
"relationships": {},
"links": {
"self": ".../v1/betaTesters/4277b871-ce4e-4fc7-9e34"
}
}
]
}
"""

let postUserInvitations = """
{
"data": {
"type": "userInvitations",
"id": "24e811a2-2ad0-46e4-b632-61fec324ebed",
"attributes": {
"firstName": "John",
"lastName": "Appleseed",
"email": "john-appleseed@mac.com",
"roles": ["DEVELOPER"],
"allAppsVisible": true,
"expirationDate": "2018-06-10T13:15.00"
},
"links": {
"self": "../v1/userInvitations/24e811a2-2ad0-46e4-b632-61fec324ebed"
}
}
}
"""

func loadFixture(_ raw: String) -> Data {
    return raw.data(using: .utf8)!
}
