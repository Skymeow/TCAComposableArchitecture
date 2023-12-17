//
//  TCASampleAppApp.swift
//  TCASampleApp
//
//  Created by S J on 12/13/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCASampleAppApp: App {
  var store = Store(initialState: FeatureViewReducer.State(viewModel: FeatureViewModel.State(), dataSource: Feature.State()), reducer: {FeatureViewReducer()})
    var body: some Scene {
        WindowGroup {
          //only recent you can convert closure for enum using keypath
          ContentView(store: store.scope(state: \.viewModel, action: {.viewModel($0)}))
        }
    }
}
