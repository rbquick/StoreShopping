//
//  AuthViewModel.swift
//  rbqLogin
//
//  Created by Brian Quick on 2023-11-18.
//

import Foundation
import SwiftUI
import Combine

protocol AutenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: ShopperCodable?
    @Published var currentUser: ShopperCodable?
    @Published var icloudname = ""
    @Published var icloudPermission = false
    @Published var error = ""

    var cancellables = Set<AnyCancellable>()

    init() {
        fetchUser()
    }

//    func signIn(withEmail: email, password: String) async throws {
    func signIn(ckshopper: CKShopperRec) async throws {
        print("AuthViewModel.signIn:")
        let shopper = ShopperCodable(ashopper: ckshopper.shopper, aname: ckshopper.name)

            userSession = shopper
            currentUser = shopper
            MyDefaults().aShopperRec = shopper

    }

    func signOut() {
        print("AuthViewModel.signOut:")
        userSession = nil
        currentUser = nil
    }

    func deleteAccount() {
        print("AuthViewModel.deleteAccount:")
        MyDefaults().removemyMasterShopperShopper()
        signOut()
    }

    func fetchUser() {
        print("AuthViewModel.fetchUser:")
        userSession = MyDefaults().aShopperRec
        currentUser = MyDefaults().aShopperRec
        if (userSession!.name == "UNKNOWN_SHOPPER") {
            userSession = nil
            currentUser = nil
        }


    }
}
