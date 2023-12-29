//
//  Dependencies.swift
//  TCASampleApp
//
//  Created by S J on 12/21/23.
//

import Foundation
import Dependencies

@Sendable
func getPatients() async -> Result<Patients, APIError> {
  guard let url = URL(string: "https://gist.githubusercontent.com/dzunk/b24a525d54103d7d59c9baa21a954d01/raw/2428f4936cb63c06daf2c57ebb0a2463d8f13e24/patients.json") else { return .failure(.invalidURL)}
  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    do {
      let patients = try JSONDecoder().decode(Patients.self, from: data)
      return .success(patients)
    }catch let decodeErr {
      print(decodeErr)
      return .failure(.decodeErr)
    }


  } catch {
    return .failure(.apiError)
  }

}

//put them in PatientClientKey as closure
@Sendable
func getStyle() async -> Result<String, APIError> {
  //globally override dependencies
  @Dependency(\.withRandomNumberGenerator) var random
    let mainScreenStyle = ["red", "green", "blue"]
  do {
    try await Task.sleep(for: .seconds(1))
  } catch {
    return .failure(.apiError)
  }
  let randomNumber = random { generator in
    Int.random(in: 0...2, using: &generator)
  }

    return .success(mainScreenStyle[randomNumber])

    // Let's simulate an API call, as if we were querying a device configuration API
    // Task: wait a second, and return random style from array above
}

//private enum PatientClientKey: DependencyKey {
//  static let liveValue = getPatients
//  static var testValue: () async -> Result<Patients, APIError> = unimplemented()
//}
//
//private enum StyleClientKey: DependencyKey {
//  static let liveValue = getStyle
//  static var testValue: () async -> Result<String, APIError> = unimplemented()
//}

extension DependencyValues {
  var apiClient: APIClient {
    get { self[ClientKey.self] }
    set { self[ClientKey.self] = newValue }
  }
}

struct APIClient {
  let getPatients: @Sendable () async -> Result<Patients, APIError>
  let getStyle: @Sendable () async -> Result<String, APIError>
  init(getPatients: @Sendable @escaping () async -> Result<Patients, APIError> = unimplemented(), getStyle: @Sendable @escaping () async -> Result<String, APIError> = unimplemented()) {
    self.getPatients = getPatients
    self.getStyle = getStyle
  }
}

private enum ClientKey: DependencyKey {
  static let liveValue = APIClient(getPatients: getPatients, getStyle: getStyle)
  static var testValue: APIClient = APIClient(getPatients: unimplemented(), getStyle: unimplemented())
}
