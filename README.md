# Wormhole

Type safety App Store Connect API client in Swift :rocket:

:bug: **Wormhole** invites you to the fastest trip to AppStore Connect.

This library is currently developing.

:warning: App Store Connect API is currently unavailable.

## TODO

- [x] GET
- [x] DELETE
- [ ] POST
- [ ] PATCH
- [ ] Swift Package Manager support
    - Currently, it uses cpp-jwt, so it can't be built with SPM.

## Usage

```swift

struct User: AttributeType {
    let firstName: String
    let lastName: String
    let email: String
    let inviteType: String
}

let client = try! Client(p8Path: URL(fileURLWithPath: "/path/to/private_key.p8"), 
                         issuerID: 10000, 
                         keyID: UUID(uuidString: "b91d85c7-b7db-4451-8f3f-9a3c8af9a392"))
client.get(from: "/users") { (result: CollectionResult<User>) in
    switch result {
    case .success(let container):
        let users = container.data
        let user = users.first!
        print(user.firstName)
    case .failure(let error):
        switch error {
        case .apiError(let errors):
            print(errors.first!.title)
        }
    }
}
```
