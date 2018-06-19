import Foundation

func loadJSON(from fileName: String) -> Data {
    let bundle = Bundle(for: EntityTests.self)
    let path = bundle.path(forResource: fileName, ofType: ".json")!
    let url = URL(fileURLWithPath: path)
    return try! Data(contentsOf: url)
}
