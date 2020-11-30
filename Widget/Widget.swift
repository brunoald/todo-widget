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

class Provider: IntentTimelineProvider {
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
            receiveCompletion: { completion in
                print(context)
            },
            receiveValue: { todos in
                var entries: [TodoEntry] = []
                let entry = TodoEntry(
                    title: configuration.title ?? "",
                    date: Date(),
                    value: todos.shuffled().first!.title,
                    configuration: configuration
                )
                entries.append(entry)
                let nextUpdate = Calendar.current.date(byAdding: .second, value: 5, to: Date())
                let timeline = Timeline(entries: entries, policy: .after(nextUpdate!))
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

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(entry.title).foregroundColor(.blue)
            Text(entry.value).foregroundColor(.gray)
            Text(entry.date, style: .relative)
                .foregroundColor(.orange)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }.frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
        ).background(Color.white)
    }
}

@main
struct TodoWidget: SwiftUI.Widget {
    let kind: String = "WidgetTodo"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(
            entry: TodoEntry(
                title: "Title",
                date: Date(),
                value: "Test",
                configuration: ConfigurationIntent()
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
