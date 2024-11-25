//
//  MainView.swift
//  StoreShopping
//

import SwiftUI

// the MainView simply decides which top-level view to use, based on
// the horizontal size class of the app.
struct MainView: View {
    @EnvironmentObject var authviewModel: AuthViewModel
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var navPath = NavigationPath()
	var body: some View {
//        CompactMainView()
        if authviewModel.userSession != nil {
            if horizontalSizeClass == .compact {
                // standard tab view for an iPhone in portrait, etc.
                CompactMainView()
            } else {
                // this looks better on the iPad since the introduction of NavigationSplitView
                // and it behaves better than before.
                RegularMainView()
            }
        } else {
            LoginView()
        }
//            .onAppear(perform: myOnAppear)
	}
    func myOnAppear() {
        navPath.removeLast(navPath.count)
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
            .environmentObject(ModelItem())
            .environmentObject(ModelShopList())
            .environmentObject(ModelLocation())
            .environmentObject(ModelItemSection())
            
    }
}

