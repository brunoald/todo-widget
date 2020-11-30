//
//  WidgetSampleApp.swift
//  WidgetSample
//
//  Created by Bruno Dias on 26/11/20.
//

import SwiftUI

@main
struct WidgetSampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
