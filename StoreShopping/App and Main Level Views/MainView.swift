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
    @State private var lastSizeClass: UserInterfaceSizeClass? = nil  // Track previous state
    @State private var lastNavPath: NavigationPath? = nil  // Store last navigation state

    var body: some View {
        NavigationStack(path: $navPath) {
            Group {
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
            }
            .onAppear {
                lastSizeClass = horizontalSizeClass
            }
            .onChange(of: horizontalSizeClass) { newSizeClass in
                if newSizeClass != lastSizeClass {
                    if newSizeClass == .compact {
                        // If returning to compact mode, restore the last navigation state
                        if let savedPath = lastNavPath {
                            navPath = savedPath
                        }
                    } else {
                        // If switching to regular mode, save the current navigation state and reset path
                        lastNavPath = navPath
                        navPath = NavigationPath()
                    }
                    lastSizeClass = newSizeClass
                }
            }
        }
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

/*
 
 func myOnAppear() {
     navPath.removeLast(navPath.count)
 }
 */
