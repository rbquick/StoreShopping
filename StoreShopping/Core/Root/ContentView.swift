//
//  ContentView.swift
//  rbqLogin
//
//  Created by Brian Quick on 2023-11-18.
//

import SwiftUI

struct ContentView1: View {
    @EnvironmentObject var authviewModel: AuthViewModel
    var body: some View {
        Group {
            if authviewModel.userSession != nil {
                LoginView()  // FIXME: go to normal app
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        ContentView1()
    }
}
