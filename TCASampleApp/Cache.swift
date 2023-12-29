//
//  Cache.swift
//  TCASampleApp
//
//  Created by S J on 12/18/23.
//

import Foundation
import ComposableArchitecture

public protocol Caching {
  var key: String { get }
  func save<Value: Encodable>(_ value: Value)
  func load<Value: Decodable>() -> Value?
}

final class DocumentsCache: Caching {
  init(
    key: String,
    fileManager: FileManager = .default,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.key = key
    self.decoder = decoder
    self.encoder = encoder

    self.fileUrl = fileManager
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("\(key).json")
  }

  let key: String
  let decoder: JSONDecoder
  let encoder: JSONEncoder
  let fileUrl: URL

  func save<Value: Encodable>(_ value: Value) {
    let data = try? encoder.encode(value)
    try? data?.write(to: fileUrl)
  }

  func load<Value: Decodable>() -> Value? {
    guard let data = try? Data(contentsOf: fileUrl) else { return nil }
    return try? decoder.decode(Value.self, from: data)
  }
}

public extension Reducer where State: Codable {
  func caching(cache: Caching) -> Reduce<Self.State, Self.Action> {

    return Reduce<Self.State, Self.Action> { state, action in
      let effect = self.reduce(into: &state, action: action)
      let newState = state
      return .merge(
        .run(operation: { _ in
          cache.save(newState)
        }),
        effect
      )
    }
  }
}


