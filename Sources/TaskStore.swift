import SwiftUI

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool = false

    init(title: String) {
        self.id = UUID()
        self.title = title
    }
}

class TaskStore: ObservableObject {
    @Published var items: [TodoItem] = []

    private let saveKey = "todobar_items"

    init() { load() }

    func add(_ title: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        items.append(TodoItem(title: t))
        save()
    }

    func complete(_ item: TodoItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isCompleted = true
        save()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.items.removeAll { $0.id == item.id }
            }
            self.save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let saved = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
        items = saved.filter { !$0.isCompleted }
    }
}
