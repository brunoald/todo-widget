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
            title: "Title",
            date: Date(),
            value: "Placeholder",
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodoEntry) -> ()) {
        let entry = TodoEntry(
            title: "Title",
            date: Date(),
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
                        title: "TODO \(index)/\(todos.count)",
                        date: Calendar.current.date(byAdding: .second, value: 10 * index, to: Date())!,
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
    var title: String
    var date: Date
    let value: String
    let configuration: ConfigurationIntent
}

struct TodoWidgetView : View {
    var entry: TodoTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(entry.title).foregroundColor(.blue)
            Text(entry.value).foregroundColor(.gray)
            if self.entry.configuration.showTimer == true {
                Text(entry.date, style: .relative)
                    .foregroundColor(.orange)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
        }.frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
        ).background(Color.white)
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
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        TodoWidgetView(
            entry: TodoEntry(
                title: "Title",
                date: Date(),
                value: "Test",
                configuration: ConfigurationIntent()
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
