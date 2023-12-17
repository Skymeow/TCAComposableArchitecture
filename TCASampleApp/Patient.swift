//
//  Patient.swift
//  TCASampleApp
//
//  Created by S J on 12/13/23.
//

import Foundation

struct Patients: Codable, Equatable {
  let data: [Patient]
}

struct Patient: Codable, Equatable, Identifiable {
  let id: Int
  let name: String
  let email: String
  let phoneNumber: String
  let dateBirth: String
  let gender: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case email
    case phoneNumber = "phone_number"
    case dateBirth = "date_of_birth"
    case gender
  }
}
