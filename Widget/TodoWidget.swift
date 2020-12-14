//
//  Widget.swift
//  Widget
//
//  Created by Bruno Dias on 26/11/20.
//

import WidgetKit
import SwiftUI
import Intents
import Combine

class TodoTimelineProvider: IntentTimelineProvider {
    var request: AnyCancellable?
    
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(
            date: Date(),
            title: "Title",
            value: "Placeholder Placeholder Placeholder Placeholder Placeholder Placeholder Placeholder Placeholder",
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodoEntry) -> ()) {
        let entry = TodoEntry(
            date: Date(),
            title: "Title",
            value: "Snapshot",
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.request = TodoAPI.todos().print().sink(
            receiveCompletion: { _ in },
            receiveValue: { todos in
                var entries: [TodoEntry] = []
                for (index, todo) in todos.enumerated() {
                    let entry = TodoEntry(
                        date: Calendar.current.date(byAdding: .second, value: 10 * index, to: Date())!,
                        title: "\(configuration.title ?? "TODO") \(index)/\(todos.count)",
                        value: todo.title,
                        configuration: configuration
                    )
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                self.request?.cancel()
                completion(timeline)
            })
    }
}

struct TodoEntry: TimelineEntry {
    var date: Date
    let title: String
    let value: String
    let configuration: ConfigurationIntent
}

struct TodoWidgetView : View {
    var entry: TodoEntry

    var body: some View {
        VStack(alignment: .center) {
            Text(entry.title).foregroundColor(.blue)
            Text(entry.value).foregroundColor(.gray)
            if self.entry.configuration.showTimer == true {
                Text(entry.date, style: .relative)
                    .foregroundColor(.orange)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
        }.background(Color.white)
    }
}

@main
struct TodoWidget: Widget {
    let kind: String = "WidgetTodo"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: TodoTimelineProvider()
        ) { entry in
            TodoWidgetView(entry: entry)
        }
        .configurationDisplayName("TODO Widget")
        .description("See a random TODO item.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        TodoWidgetView(
            entry: TodoEntry(
                date: Date(),
                title: "Title",
                value: "Test",
                configuration: ConfigurationIntent()
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
