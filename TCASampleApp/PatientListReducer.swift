//
//  PatientListReducer.swift
//  TCASampleApp
//
//  Created by S J on 12/13/23.
//

import Foundation
import ComposableArchitecture

//sepearte them into two different reducers and compose them into one to be used in view
//Feature data source VS ViewModel data source that comform to Reducer

//this is for cell to use, so we don't reply on data model
//no action on cell now so it doesn't need to conform to Reducer
struct PatientViewModel: Equatable, Identifiable {
  var id: Int
  var patientName: String
  var dateOfBirth: String
  var phoneNumber: String
  var email: String
}

enum Style: String, Equatable {
  case blue
  case green
  case red
  case clear
}

struct FeatureViewModel: Reducer {
  struct State: Equatable {
    var selected: PatientViewModel? = nil
    var allPatients: [PatientViewModel] = []
    var style: Style = .clear
    var isLoading: Bool = false
  }

  enum Action {
    case selectPatient(_ patient: PatientViewModel)
    case allPatients([PatientViewModel])
    case task
    case reload
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .selectPatient(let patient):
        state.selected = patient
        return .none
      case .allPatients(let patients):
        state.allPatients = patients
        state.isLoading = false
        return .none
      case .task, .reload:
        state.isLoading = true
        return .none
      }
    }
  }
}

//combiner
struct FeatureViewReducer: Reducer {
  struct State: Equatable {
    var viewModel: FeatureViewModel.State
    var dataSource: Feature.State
  }

  enum Action {
    case viewModel(FeatureViewModel.Action)
    case dataSource(Feature.Action)
  }

  var body: some Reducer<State, Action> {
    // this is a hack I need to update swift

    //route actions through reducer tree
    Scope(state: \.viewModel, action: /Action.viewModel) {
      FeatureViewModel()
    }
    Scope(state: \.dataSource, action: /Action.dataSource) {
      Feature()
    }
    //get data in datasource into FeatureVM
    Reduce { state, action in
      switch action {
      case .dataSource(.patientData(let data)):
//        state.viewModel.allPatients = data.map{PatientViewModel(id: $0.id, patientName: $0.name, dateOfBirth: $0.dateBirth, phoneNumber: $0.phoneNumber, email: $0.email)}
        let patients = data.map{PatientViewModel(id: $0.id, patientName: $0.name, dateOfBirth: $0.dateBirth, phoneNumber: $0.phoneNumber, email: $0.email)}
        return .send(.viewModel(.allPatients(patients)))
      case .dataSource(.styleData(let style)):
        state.viewModel.style = Style(rawValue: style) ?? .clear
        return .none
      case .viewModel(.task):
        return .send(.dataSource(.fetchAll))
      case .viewModel(.reload):
        return .send(.dataSource(.fetchAll))
      case .viewModel, .dataSource:
        return .none

      }
    }
  }
}

//datasource
struct Feature: Reducer {

  struct State: Equatable {
    var style: String = ""
    var patients: [Patient] = []
    var err: String = ""
  }
//where to put the loading state? in action too?
  enum Action {
    case fetchAll
    case styleData(_ style: String)
    case patientData([Patient])
    case error(String)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .fetchAll:
        //pass in the state before send if you need to capture state
        return .run { send in
          let styleResult = await APIManager().getStyle()
          switch styleResult {
          case .success(let style):
            await send(.styleData(style))
          case .failure(let error):
            print(error)
            await send(.error(error.localizedDescription))
          }

          let patientResult = await APIManager().getPatients()
          switch patientResult {
          case .success(let patients):
            //send action back to reducer, once reducer finish processing it, update state
            await send(.patientData(patients.data))
          case .failure(let error):
            print(error)
            await send(.error(error.localizedDescription))
          }
        }


      case .styleData(let style):
        state.style = style
        //after this action is being processed, no further action
        return .none
      case .patientData(let patients):
        state.patients = patients
        return .none
      case .error(let errMsg):
        state.err = errMsg
        return .none
      }
    }
  }
}
