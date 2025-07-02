import Foundation

class DailyTasksDynamicMocks {

    private let host = "https://rest.dev.fstr.app"

    private var taskStatuses: [String: Bool] = [
        "333536": false,
        "413734": false,
        "334174": false,
        "348733": false
    ]

    private let taskFiles: [String: (active: String, done: String)] = [
        "333536": ("log_low_saturated_fats.json", "log_low_saturated_fats_done.json"),
        "413734": ("move_your_body.json", "move_your_body_done.json"),
        "334174": ("log_weight.json", "log_weight_done.json"),
        "348733": ("log_12_hour_fast.json", "log_12_hour_fast_done.json")
    ]

    func mocks() -> [ServerMockData] {
        return [
            .init(urlTemplate: "\(host)/daily_tasks/api/v3/tasks",
                  handler: .init(run: { _ in
                      return .ok(.jsonFile("dailyTasks.json"))
                  })),

            .init(urlTemplate: "\(host)/daily_tasks/api/v2/tasks/:id",
                  handler: .init { [weak self] request in
                      guard let self = self,
                            let taskId = request.params[":id"] else {
                          return .internalServerError(nil)
                      }

                      if request.method == "PUT" {
                          self.toggleTaskStatus(for: taskId)
                      }

                      guard let fileName = self.taskDetailFile(for: taskId) else {
                          return .internalServerError(nil)
                      }

                      return .ok(.jsonFile(fileName))
                  }),

            .init(urlTemplate: "\(host)/v1/feed/section/logAtLeastOneMeal",
                  handler: .ok(jsonFile: "mocked_content_3waysToEnjoyAMeal.json"))
        ]
    }

    private func toggleTaskStatus(for taskId: String) {
        taskStatuses[taskId]?.toggle()
    }

    private func taskDetailFile(for taskId: String) -> String? {
        let isDone = taskStatuses[taskId] ?? false
        return isDone ? taskFiles[taskId]?.done : taskFiles[taskId]?.active
    }
}
