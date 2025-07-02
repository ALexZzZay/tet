import Foundation
import AnalyticsEventsChecker

struct EventsScenarioSource {
    var getScenario: () throws -> EventsCheckerLogic.Config.Scenario

    static func file(_ fileName: String) -> Self {
        .init {
            try codable(data: readFile(fileName)).getScenario()
        }
    }

    static func codable(data: Data) -> Self {
        .init {
            try JSONDecoder().decode(
                EventsCheckerLogic.Config.Scenario.self,
                from: data
            )
        }
    }
}

private func readFile(_ filePath: String, bundle: Bundle? = nil) -> Data {
    BundleHelper.loadData(filePath, bundle: bundle)
}
