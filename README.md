# Wormhole

[![Build Status](https://travis-ci.org/giginet/Wormhole.svg?branch=master)](https://travis-ci.org/giginet/Wormhole)

Type safety App Store Connect API client in Swift :rocket:

:bug: **Wormhole** invites you to the fastest trip to AppStore Connect.

This library is currently developing.

:warning: App Store Connect API is currently unavailable.

## Features

- :white_check_mark: Pure Swifty
- :white_check_mark: Type Safed
- :white_check_mark: Swift Package Manager Support
- :construction: Linux Support
- :skull_and_crossbones: Available this summer

## Requirements

- Xcode 10
- libjwt(unstable version)

### libjwt

You need to install unstable version of [libjwt](https://github.com/benmcollins/libjwt).

```console
$ brew tap giginet/libjwt https://github.com/giginet/libjwt.git
$ brew install giginet/libjwt/libjwt
```

## Setup

### 1. Generate new project with SwiftPM

```console
$ mkdir MyExecutable
$ cd MyExecutable
$ swift package init --type executable
```

### 2. Add the dependency to your `Package.swift`.

```swift
// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyExecutable",
    dependencies: [
        .package(url: "https://github.com/giginet/Wormhole.git", .from("0.1.0")),
    ],
    targets: [
        .target(
            name: "MyExecutable",
            dependencies: ["Wormhole"]),
    ]
)
```

### 3. Run with SwiftPM

```console
$ swift run -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib
```

## Usage

### Initialize API Client

You can find your issuerID, keyID or private key on App Store Connect.

```swift
import Foundation
import Wormhole
import Result

// Download your private key from App Store Connect
let client = try! Client(p8Path: URL(fileURLWithPath: "/path/to/private_key.p8"), 
                         issuerID: UUID(uuidString: "b91d85c7-b7db-4451-8f3f-9a3c8af9a392")!, 
                         keyID: "100000")
```

### Define model

```swift
enum Role: String, Codable {
    case developer = "DEVELOPER"
    case marketing = "MARKETING"
}

struct User: AttributeType {
    let firstName: String
    let lastName: String
    let email: String
    let roles: [Role]
}
```

### Send Get Request

```swift
/// Define request model
struct GetUsersRequest: RequestType {
    // You can use `SingleContainer<AttributeType>` or `CollectionContainer<AttributeType>`
    typealias Response = CollectionContainer<User>

    // HTTP method(get, post, patch or delete)
    let method: HTTPMethod = .get

    // API endpoint
    let path = "/users"

    // Request payload. You can use `.void` to send request without any payloads.
    let payload: RequestPayload = .void
}

let request = GetUsersRequest()
client.send(request) { (result: Result<CollectionContainer<User>, ClientError>) in
    switch result {
    case .success(let container):
        let firstUser: User = container.data.first!
        print("Name: \(firstUser.firstName) \(firstUser.lastName)")
        print("Email: \(firstUser.email)")
        print("Roles: \(firstUser.roles)")
    case .failure(let error):
        print("Something went wrong")
        print(String(describing: error))
    }
}
```

### Send Patch Request

```swift
// UUID of a target user
let uuid = UUID(uuidString: "588ec36e-ba74-11e8-8879-93c782f9ccb3")

// Define Request model
struct RoleModificationRequest: RequestType {
    // Response should indicate a single user.
    typealias Response = SingleContainer<User>
    let method: HTTPMethod = .patch
    var path: String {
        return "/users/\(id.uuidString.lowercased())"
    }
    let id: UUID
    let roles: [Role]

    // Payload
    var payload: RequestPayload {
        return .init(id: id,
                     type: "users",
                     attributes: roles)
    }
}

let request = RoleModificationRequest(id: uuid, roles: [.developer, .marketing])
client.send(request) { result in
    switch result {
    case .success(let container):
        let modifiedUser: User = container.data
        print("Name: \(modifiedUser.firstName) \(modifiedUser.lastName)")
        print("Email: \(modifiedUser.email)")
        print("Roles: \(modifiedUser.roles)")
    case .failure(let error):
        print("Something went wrong")
        print(String(describing: error))
    }
}
```

## Development

### Generate Xcode project

```console
$ swift package generate-xcodeproj --xcconfig-overrides Config.xcconfig
$ open ./Wormhole.xcodeproj
```
