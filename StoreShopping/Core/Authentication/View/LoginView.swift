//
//  LoginView.swift
//  rbqLogin
//
//  Created by Brian Quick on 2023-11-18.
//

import SwiftUI

struct LoginView: View {
    @State private var name = ""
    @State private var shopper = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var modelshopper: ModelShopper
    @EnvironmentObject var modelshoplist: ModelShopList
    @EnvironmentObject var modellocation: ModelLocation
    @EnvironmentObject var modelitem: ModelItem

    var body: some View {
        NavigationStack {
            VStack {
                // image
//                Image(systemName: "globe")
                Image("StoreShoppingCart")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.accentColor)
                    .frame(width: 100, height: 100)
                    .padding(.vertical,32)

                // form fields
                VStack {
                    myTextField(value: $name, title: "Name", texttype: .String, placeHolder: "Your icloud name")
                        .padding(6)
                        .onChange(of: name) { newValue in
                        getValidShopper(name: name)
                    }
                    Text("Your shopper ID is: \(shopper)")
                        .padding(6)
//                    myTextField(value: $shopper, title: "Shopper Nr.", texttype: .Int, placeHolder: "Your assigned shopper number")
//                    .padding(6)

                }
                .padding(.horizontal)
                .padding(.top, 12)

                // sign in Button
                Spacer()

                Button {
                    Task {
                        let ckshopper = modelshopper.getShopper(name: name)
                        try await viewModel.signIn(ckshopper: ckshopper)
                        modelshoplist.createShoplists()
                        modellocation.createLocations()
                        modelitem.createItems()
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)

//                Spacer()

                // sign up Button

                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
            .onAppear() {
                UITextField.appearance().clearButtonMode = .whileEditing
            }
        }
    }
}

// MARK: - AutenticationFormProtocol

extension LoginView: AutenticationFormProtocol {
    var formIsValid: Bool {
        return !name.isEmpty &&
            !shopper.isEmpty
//        !shopper.isEmpty &&
//        containsNumber(value: shopper) &&

    }
    private func containsNumber(value: String) -> Bool {
        if let _ = Int(value) {
            return true
        }
        return false
    }
    private func getValidShopper(name: String) {
        let ckshopper = modelshopper.getShopper(name: name)
        if ckshopper.name == name {
            shopper = String(ckshopper.shopper)
        } else {
            shopper = ""
        }
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
