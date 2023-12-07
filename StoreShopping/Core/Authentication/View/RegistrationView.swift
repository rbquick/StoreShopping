//
//  RegistrationView.swift
//  rbqLogin
//
//  Created by Brian Quick on 2023-11-18.
//

import SwiftUI

struct RegistrationView: View {

    @State private var name = ""
    @State private var shopper = ""
    @EnvironmentObject var modelshopper: ModelShopper
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
//            Image(systemName: "globe")
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
                myTextField(value: $shopper, title: "Shopper Nr.", texttype: .Int, placeHolder: "Your assigned shopper number")
                .padding(6)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Button {

                    createUser(name: name, shopper: Int64(shopper) ?? 99 )

            } label: {
                HStack {
                    Text("SIGN UP")
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

            Spacer()

            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign up")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }

        }
    }
}
// MARK: - AutenticationFormProtocol

extension RegistrationView: AutenticationFormProtocol {
    var formIsValid: Bool {
        return !name.isEmpty &&
        !shopper.isEmpty &&
        containsNumber(value: shopper)

    }
    private func containsNumber(value: String) -> Bool {
        if let _ = Int(value) {
            return true
        }
        return false
    }


    func createUser(name: String, shopper: Int64)  {
        print("RegistrationView.createUser:")

        let shopper = CKShopperRec(shopper: Int64(shopper), name: name)!
        modelshopper.addOrUpdate(shopper: shopper) { returnvalue in
            print(returnvalue)
            let shopperCodable = ShopperCodable(ashopper: shopper.shopper, aname: shopper.name)
            MyDefaults().aShopperRec = shopperCodable
            viewModel.currentUser = shopperCodable
            viewModel.userSession = shopperCodable
        }

    }
}

struct RegistrationView_Previews: PreviewProvider {
    @EnvironmentObject var viewModel: AuthViewModel
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
