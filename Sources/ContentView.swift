import SwiftUI

struct ContentView: View {
    @ObservedObject var taskStore: TaskStore
    @State private var newTaskText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tasks")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 2)

            if taskStore.items.isEmpty {
                Text("No tasks yet.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(taskStore.items) { item in
                            TaskRowView(item: item) {
                                taskStore.complete(item)
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                }
                .frame(minHeight: 300, maxHeight: 500)
            }

            // Input field
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .foregroundColor(.white.opacity(0.35))
                    .font(.system(size: 11))

                TextField("Add a task...", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .focused($isInputFocused)
                    .onSubmit {
                        withAnimation {
                            taskStore.add(newTaskText)
                        }
                        newTaskText = ""
                        isInputFocused = true
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .frame(width: 420)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.78))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.09), lineWidth: 0.5)
                }
        }
        .onExitCommand {
            NotificationCenter.default.post(name: .hidePanel, object: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusInput)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isInputFocused = true
            }
        }
    }
}

struct TaskRowView: View {
    let item: TodoItem
    let onComplete: () -> Void

    var body: some View {
        Button(action: onComplete) {
            HStack(spacing: 10) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green.opacity(0.7) : .white.opacity(0.45))
                    .font(.system(size: 14))
                    .animation(.easeOut(duration: 0.2), value: item.isCompleted)

                Text(item.title)
                    .foregroundColor(.white.opacity(item.isCompleted ? 0.3 : 0.88))
                    .font(.system(size: 13))
                    .strikethrough(item.isCompleted, color: .white.opacity(0.3))
                    .lineLimit(2)
                    .animation(.easeOut(duration: 0.2), value: item.isCompleted)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(item.isCompleted ? 0.35 : 1.0)
        .animation(.easeOut(duration: 0.3), value: item.isCompleted)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.white.opacity(item.isCompleted ? 0 : 0.05))
        )
    }
}
