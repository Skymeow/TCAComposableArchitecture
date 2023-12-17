//
//  NetworkManager.swift
//  TCASampleApp
//
//  Created by S J on 12/13/23.
//

import Foundation

enum APIError: Error {
  case emptyResult
  case apiError
  case invalidURL
  case decodeErr
}

final class APIManager {

    func getStyle() async -> Result<String, APIError> {
        let mainScreenStyle = ["red", "green", "blue"]
      do {
        try await Task.sleep(for: .seconds(1))
      } catch {
        return .failure(.apiError)
      }
      if let style = mainScreenStyle.randomElement() {
        return .success(style)
      } else {
        return .failure(.emptyResult)
      }
        // Let's simulate an API call, as if we were querying a device configuration API
        // Task: wait a second, and return random style from array above
    }

    // Task: implement method getPatients
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

}
