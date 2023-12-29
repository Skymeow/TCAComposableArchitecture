//
//  ContentView.swift
//  TCASampleApp
//
//  Created by S J on 12/13/23.
//

import SwiftUI
import ComposableArchitecture

//struct baseContentView: View {
//  var store = Store(initialState: FeatureViewReducer.State(viewModel: FeatureViewModel.State(), dataSource: Feature.State()), reducer: {FeatureViewReducer()})
//  var body: some View {
//      ContentView(store: store.scope(state: \.viewModel, action: /FeatureViewReducer.Action.viewModel))
//  }
//}

extension Style {
  var value: Color {
    switch self {
    case .blue:
      return Color.blue
    case .green:
      return Color.green
    case .red:
      return Color.red
    case .clear:
      return Color.clear
    }
  }
}

struct ContentView: View {
  let store: StoreOf<FeatureViewModel>


//  struct ViewState: Equatable {
//    let patients: [PatientViewModel]
//    let style:
//    init(state: FeatureViewModel.State) {
//      self.patients = state.allPatients
//      self.style = state.style
//    }
//  }

    var body: some View {
      //which part of state do you care about, using keypath to decide which state to apply to view
      WithViewStore(self.store, observe: {$0}) { viewStore in
        NavigationView {
          VStack {
            ScrollView {
              ForEach(viewStore.allPatients) { patient in
                patientCell(patient, viewStore.selected == patient ? viewStore.style.value : nil)
                  .onTapGesture {
                    viewStore.send(.selectPatient(patient))

                  }

                Divider()
              }
            }

            Button(viewStore.isLoading ?  "refresh...." : "refresh", action: {
              Task {
                viewStore.send(.reload)
              }
            })
            .frame(width: 200, height: 40)
            .background {
              RoundedRectangle(cornerRadius: 12).fill(Color.red)
            }
            .foregroundColor(.white)

          }
          .navigationTitle(viewStore.style.rawValue)
          //task gets run when app enter foreground
          .task {
            await viewStore.send(.task).finish()
          }
        }
      }
    }


  func patientCell(_ patient: PatientViewModel, _ style: Color? = nil) -> some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 0) {
        Text(patient.patientName)
          .fixedSize(horizontal: false, vertical: true)
          .lineLimit(1)
          .frame(maxWidth: 150)
      }

      .padding(.trailing)

      VStack(alignment: .leading) {
        HStack {
          Text("phone: ")
          Text(patient.phoneNumber)
        }
        HStack(spacing: 5) {
          Text("email: ")
          Text(patient.email)
            .lineLimit(1)

        }
      }
    }
    .padding()
    .background(style ?? .clear)
  }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView(store: Store(initialState: FeatureViewModel.State(selected: nil, allPatients: [
        PatientViewModel(id: 1, patientName: "sky", dateOfBirth: "fjkj", phoneNumber: "9182920382", email: "sdhfjsdh"),
        PatientViewModel(id: 2, patientName: "sky2", dateOfBirth: "fjkj", phoneNumber: "9182920382", email: "sdhfjsdh"),
        PatientViewModel(id: 3, patientName: "sky3", dateOfBirth: "fjkj", phoneNumber: "9182920382", email: "sdhfjsdh")
      ], style: .blue), reducer: {FeatureViewModel()}))
    }
}

//#Preview {
//  ContentView(store: <#T##StoreOf<FeatureViewModel>#>)
//}
