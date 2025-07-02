import Foundation

@MainActor
enum alice {

    static func attemptsTo(_ task: ScreenplayTask) {
        perform(task)
    }

    static func sees(_ question: Question) {
        ask(question)
    }

    // MARK: - Private

    private static func ask(_ question: Question) {
        execWithActivityName(question.name) {
            question.ask()
        }
    }

    private static func perform(_ task: ScreenplayTask) {
        execWithActivityName(task.name) {
            task.perform()
        }
    }

    private static func execWithActivityName(_ name: String?, block: () -> Void) {
        if let name = name {
            XCTContext.runActivity(named: name) { _ in
                block()
            }
        } else {
            block()
        }
    }
}
