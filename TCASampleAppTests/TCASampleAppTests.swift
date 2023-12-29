//
//  TCASampleAppTests.swift
//  TCASampleAppTests
//
//  Created by S J on 12/21/23.
//

import XCTest
@testable import TCASampleApp
import ComposableArchitecture

@MainActor
final class TCASampleAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFeatureDataSourceFetchAll() async throws {
      let mockedPatients: [Patient] = [
          Patient(id: 1, name: "sky1", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f"),
          Patient(id: 2, name: "sky2", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f"),
          Patient(id: 3, name: "sky3", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f")
        ]

      let store = TestStore(initialState: Feature.State()) {
        Feature().dependency(\.apiClient, APIClient(getPatients: {.success(Patients(data: mockedPatients))}, getStyle: {
          .success("green")
        }))
      }
      await store.send(.fetchAll)
      await store.receive(.styleData("green")) { state in
        state.style = "green"
      }
      await store.receive(.patientData(mockedPatients)) { state in
        state.patients = mockedPatients
      }
    }

  func testFeatureViewModelTask() async throws {
//    let store = TestStore(initialState: FeatureViewReducer.State(from: <#Decoder#>)) {
//      FeatureViewModel()
//    }
//    let mockedPatients: [Patient] = [
//        Patient(id: 1, name: "sky1", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f"),
//        Patient(id: 2, name: "sky2", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f"),
//        Patient(id: 3, name: "sky3", email: "sky@mail.com", phoneNumber: "9182749284", dateBirth: "04/14", gender: "f")
//      ]
//
//    let mockedPatientVM = mockedPatients.map{PatientViewModel(id: $0.id, patientName: $0.name, dateOfBirth: $0.dateBirth, phoneNumber: $0.phoneNumber, email: $0.email)}
//    await store.send(.allPatients(mockedPatientVM))
//
//    await store.receive(.allPatients(mockedPatientVM)) { state in
//      state.allPatients = mockedPatientVM
//    }
  }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
