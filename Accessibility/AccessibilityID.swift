import Foundation

public struct AccessibilityID {

    public struct TabBar {
        public static let view = "TabBar.view"

        public static let dailyTasksTabButton = "TabBar.dailyTasksTabButton"
        public static let avoTabButton = "TabBar.avoTabButton"
        public static let trackerTabButton = "TabBar.trackerTabButton"
        public static let exploreTabButton = "TabBar.exploreTabButton"
        public static let profileTabButton = "TabBar.profileTabButton"
    }

    public static let journalItemEditButton = "foodIntakeEditButton"

    public enum FoodDiary {
        public static let intakeRowCell = "FoodDiary.intakeRowCell"
        public static let waterRowCell = "FoodDiary.waterRowCell"
        public static let activityRowCell = "FoodDiary.activityRowCell"
        public static let weightRowCell = "FoodDiary.weightRowCell"
        public static let collectionView = "FoodDiary.collectionView"
        public static let cellHeader = "FoodDiary.cellHeader"
        public static let cellDateLabel = "FoodDiary.cellDateLabel"
        public static let cellTitleLabel = "FoodDiary.cellTitleLabel"
        public static let valueLabel = "FoodDiary.valueLabel"
        public static let fastingRowCell = "FoodDiary.fastingRowCell"
        public static let symptomsView = "FoodDiary.symptomsView"
        public static let fastingInfoView = "FoodDiary.fastingInfoView"
        public static let firstEmojiLabel = "FoodDiary.firstEmojiLabel"
        public static let statisticItemView = "FoodDiary.statisticItemView"
        public static let calendarContainerView = "FoodDiary.calendarContainerView"
    }

    public enum FoodDiaryWeightCell {
        public static let localImage = "FoodDiaryWeightCell.localImage"
        public static let remoteImage = "FoodDiaryWeightCell.remoteImage"
    }

    public static let yesButton = "yesButton"
    public static let editButton = "edit"
    public static let deleteButton = "delete"
    public static let cancelButton = "cancel"

    public static let navigationBarRightButton = "navigationBarRightButton"
    public static let navigationBarBackButton = "navigationBarBackButton"

    public static let mainStatusLogMealButton = "mainStatusLogMealButton"
    public static let mainStatusStartFastingButton = "mainStatusStartFastingButton"
    public static let bottomButton = "bottomButton"

    public enum MainStatus {
        public static let bodyStatusLabel = "MainStatus.bodyStatusLabel"
        public static let waterTrackerCell = "MainStatus.waterTrackerCell"
        public static let startingYourFastPopover = "MainStatus.startingYourFastPopover"
        public static let startingYourFastPopoverDismissButton = "MainStatus.startingYourFastPopoverDismissButton"
        public static let foodRowCell = "MainStatus.foodRowCell"
        public static let activityTrackerCell = "MainStatus.activityTrackerCell"
        public static let logPreviousFastButton = "MainStatus.logPreviousFastButton"
        public static let fastingDoneRowCell = "MainStatus.fastingDoneRowCell"
        public static let goTodayButton = "MainStatus.goTodayButton"
        public static let fastingEditButton = "MainStatus.fastingEditButton"
        public static let smartCameraButton = "MainStatus.smartCameraButton"

        public enum NavBar {
            public static let avatarButton = "MainStatus.NavBar.avatarButton"
        }
    }

    public enum WaterTracker {
        public static let drinkTypeCell = "WaterTracker.DrinkTypeCell"
        public static let screen = "WaterTracker.Screen"
        public static let collectionView = "WaterTracker.collectionView"
        public static let breaksFastingDisclaimerLabel = "WaterTracker.breaksFastingDisclaimerLabel"
    }

    public enum Onboarding {
        public static let nextButton = "Onboarding.nextButton"
        public static let skipButton = "Onboarding.skipButton"

        public enum Welcome {
            public static let screen = "Onboarding.Welcome.screen"
            public static let optInPrivacy = "Onboarding.Welcome.optInPrivacy"
            public static let signInButton = "Onboarding.Welcome.signInButton"
        }

        public enum EmailLogin {
            public static let emailTextField = "Onboarding.EmailLogin.emailTextField"
            public static let nextButton = "Onboarding.EmailLogin.nextButton"
        }

        public enum CheckYourEmail {
            public static let screen = "Onboarding.CheckYourEmail.screen"
        }

        public enum Name {
            public static let screen = "Onboarding.Name.screen"
            public static let textField = "Onboarding.Name.textField"
        }

        public enum List {
            public static let cell = "Onboarding.List.cell"
            public static let cellTitle = "Onboarding.List.cellTitle"
        }

        public enum Plan {
            public static let screen = "Onboarding.Plan.screen"
        }
    }

    public enum NoteTracker {
        public static let closeButton = "NoteTracker.closeButton"
        public static let startFastButton = "NoteTracker.startFastButton"
        public static let textInput = "NoteTracker.textInput"
        public static let dateButton = "NoteTracker.dateButton"
        public static let mealNameButton = "NoteTracker.mealNameButton"

        public enum MealType {
            public static let breakfast = "NoteTracker.MealType.breakfast"
            public static let lunch = "NoteTracker.MealType.lunch"
            public static let dinner = "NoteTracker.MealType.dinner"
            public static let snack = "NoteTracker.MealType.snack"
        }
    }

    public enum Tips {
        public static let edit = "Tips.edit"
        public static let confirm = "Tips.confirm"
        public static let view = "Tips.tipView"
        public static func actionButton(buttonName: String) -> String {
            "tipActionButton_\(buttonName)"
        }
    }

    public enum DailyTasks {
        public static let checkmarkView = "DailyTasks.checkmarkView"

        public static func rowCell(position: Int) -> String {
            "DailyTasks.taskCell_position_\(position)"
        }

        public static func rowCell(taskId: Int) -> String {
            return "task_\(taskId)"
        }
    }

    public enum DailyTaskDetails {
        public static let menuButton = "DailyTaskDetails.menuButton"
        public static let skip = "DailyTaskDetails.skip"
        public static let markIncomplete = "DailyTaskDetails.markIncomplete"
        public static let primaryButton = "DailyTaskDetails.primaryButton"
        public static let secondaryButton = "DailyTaskDetails.secondaryButton"
        public static let chatButton = "DailyTaskDetails.chatButton"
        public static let contentButton = "DailyTaskDetails.contentButton"
        public static let completeIconView = "DailyTaskDetails.completeIconView"
        public static let headerRowCell = "DailyTaskDetails.headerRowCell"
        public static let completeLabel = "DailyTaskDetails.completeLabel"
        public static let screen = "DailyTaskDetails.screen"
        public static let errorView = "DailyTaskDetails.errorView"

        public enum SkipConfirmationDialog {
            public static let keepButton = "DailyTaskDetails.SkipConfirmationDialog.keepButton"
            public static let skipButton = "DailyTaskDetails.SkipConfirmationDialog.skipButton"
        }
    }

    public enum Unboxing {
        public static let tooltipView = "Unboxing.tooltipView"
        public static let nextButton = "Unboxing.nextButton"
        public static let avoTooltipView = "Unboxing.avoTooltipView"
        public static let avoCloseButton = "Unboxing.avoCloseButton"

        public static func streakOption(position: Int) -> String {
            "Unboxing.streakOption_\(position)"
        }
    }

    public static let mainStatusEndFastingButton = "mainStatusEndFastingButton"
    public static let mainStatusSkipFastingButton = "mainStatusSkipFastingButton"

    public static let scrollView = "scrollView"
    public static let collectionView = "collectionView"
    public static let datePicker = "datePicker"

    public enum FastingEditScreen {
        public static let optionView = "FastingEditScreen.optionView"
        public static let rateRowCell = "FastingEditScreen.rateRowCell"
        public static let symptomsLabel = "FastingEditScreen.symptomsLabel"
        public static let collectionView = "FastingEditScreen.collectionView"
        public static let doneButton = "FastingEditScreen.doneButton"
        public static let symptomsButton = "FastingEditScreen.symptomsButton"
        public static let datePicker = "FastingEditScreen.datePicker"
        public static let startFastingDateButton = "FastingEditScreen.startFastingDateButton"
        public static let finishFastingDateButton = "FastingEditScreen.finishFastingDateButton"

        public static let rateViewStarRated: @Sendable (Int) -> String = {
            "FastingEditScreen.rateViewStar.\($0)"
        }
    }

    public static let valuePickerCell = "valuePickerCell"
    public static let valuePickerCellLabel = "valuePickerCellLabel"

    public static let mainStatusCalendarTodayDayView = "mainStatusCalendarTodayDayView"

    public static func mainStatusCalendarWeekDayLabel(dayName: String) -> String {
        "weekDayLabel_\(dayName)"
    }

    public static let mainStatusCalendarCell = "mainStatusCalendarCell"
    public static let mainStatusFastingPlanButton = "mainStatusFastingPlanButton"
    public static let mainStatusFastingInformationTitleLabel = "mainStatusFastingInformationTitleLabel"
    public static let mainStatusFastingInformationSubtitleLabel = "mainStatusFastingInformationSubtitleLabel"

    public static let mainStatusWaterTrackerButton = "mainStatusWaterTrackerButton"
    public static let mainStatusWaterTrackerJournalButton = "mainStatusWaterTrackerJournalButton"
    public static let mainStatusWaterTrackerValueLabel = "mainStatusWaterTrackerValueLabel"
    public static let mainStatusActivityTrackerButton = "mainStatusActivityTrackerButton"
    public static let mainStatusActivityTrackerJournalButton = "mainStatusActivityTrackerJournalButton"
    public static let mainStatusActivityTrackerValueLabel = "mainStatusActivityTrackerValueLabel"
    public static let mainStatusActivityTrackerStepsValueLabel = "mainStatusActivityTrackerStepsValueLabel"
    public static let mainStatusWeightTrackerButton = "mainStatusWeightTrackerButton"
    public static let trackerLogButton = "trackerLogButton"

    public static let picker = "picker"

    public enum ImagePickerPopover {
        public static let camera = "camera"
        public static let photoLibrary = "photoLibrary"
        public static let cancel = "cancel"
    }

    public enum WeightTracker {
        public static let saveButton = "WeightTracker.saveButton"
        public static let addPhotoButton = "WeightTracker.addPhotoButton"
    }

    public enum ChangeStartingWeight {
        public static let currentWeight = "ChangeStartingWeight.currentWeight"
        public static let oldWeight = "ChangeStartingWeight.oldWeight"
        public static let newWeight = "ChangeStartingWeight.newWeight"
    }

    public enum TooLongFastingDialog {
        public static let title = "TooLongFastingDialog.title"
        public static let acceptButton = "TooLongFastingDialog.acceptButton"
        public static let rejectButton = "TooLongFastingDialog.rejectButton"
    }

    public enum AutocompleteLongFastingDialog {
        public static let keepFastingButton = "AutocompleteLongFastingDialog.keepFastingButton"
        public static let markFastCompleteButton = "AutocompleteLongFastingDialog.markFastCompleteButton"
    }

    public enum TooShortFastingDialog {
        public static let title = "TooShortFastingDialog.title"
        public static let acceptButton = "TooShortFastingDialog.acceptButton"
        public static let rejectButton = "TooShortFastingDialog.rejectButton"
    }

    public static let noteTrackerDoneButton = "noteTrackerDoneButton"
    public static let saveButton = "saveButton"
    public static let closeButton = "closeButton"
    public static let errorCloseButton = "errorCloseButton"
    public static let fastingDoneOkButton = "fastingDoneOkButton"
    public static let shareButton = "shareFastingButton"
    public static let startFastingPopoverExistingMeal = "startFastingPopoverExistingMeal"
    public static let startFastingPopoverNewMeal = "startFastingPopoverNewMeal"

    public static func mealContextOptionView(id: String) -> String {
        "mealContextOptionView_\(id)"
    }

    public static let fastingPlanGoalLabel = "fastingPlanGoalLabel"
    public static let fastingPlanGoalCell = "fastingPlanGoalCell"
    public static let fastingPlanGoalPicker = "fastingPlanGoalPicker"
    public static let fastingPlanScheduleSlider = "fastingPlanScheduleSlider"
    public static let fastingPlanCloseButton = "fastingPlanCloseButton"
    public static let fastingPlanSaveButton = "fastingPlanSaveButton"

    public enum FastingPlan {
        public enum ManualSchedule {
            public static let switcher = "FastingPlan.ManualSchedule.Switcher"
            public static let dayItemLabel = "FastingPlan.ManualSchedule.dayItemLabel"
            public static let dayItem: @Sendable (Int) -> String = {
                "FastingPlan.ManualSchedule.dayItem.\($0)"
            }
        }
    }

    public static let feedCollectionView = "feedCollectionView"

    public enum Profile {
        public static let collectionView = "Profile.collectionView"
        public static let programCard = "Profile.programCard"
        public static let programLegendRow = "Profile.programLegendRow"

        public static let editActivityGoalButton = "Profile.editActivityGoalButton"
        public static let editHydrationGoalButton = "Profile.editHydrationGoalButton"
        public static let editFastingGoalButton = "Profile.editFastingGoalButton"
        public static let editWeightGoalButton = "Profile.editWeightGoalButton"
    }

    public static let viewAllLoggingActivityButton = "viewAllLoggingActivityButton"

    public enum PersonalData {
        public static let screen = "PersonalData.screen"
        public static let collectionView = "PersonalData.collectionView"
        public static let logoutButton = "PersonalData.logoutButton"
    }

    public enum GeneralAssessment {
        public static let screen = "GeneralAssessment.screen"
    }

    public enum DailyCheckIn {
        public static let startCell = "DailyCheckIn.startCell"
        public static let startButton = "DailyCheckIn.startButton"
        public static let finishedRowCell = "DailyCheckIn.finishedRowCell"
    }

    public enum AINutritionistChat {
        public static let screen = "AINutritionistChat.screen"
        public static let fullScreenError = "AINutritionistChat.fullScreenError"
        public static let inputTextView = "AINutritionistChat.inputTextView"
        public static let sendMessageButton = "AINutritionistChat.sendMessageButton"
        public static let likeMessageButton = "AINutritionistChat.likeMessageButton"
        public static let messagesScrollView = "AINutritionistChat.messagesScrollView"
        public static let backButton = "AINutritionistChat.backButton"
        public static let rateView = "AINutritionistChat.rateView"
        public static let rateSubmitButton = "AINutritionistChat.rateSubmitButton"
        public static let scrollDownFloatButton = "AINutritionistChat.scrollDownFloatButton"
        public static let cameraInputButton = "AINutritionistChat.cameraInputButton"
        public static let rateCloseButton = "AINutritionistChat.rateCloseButton"
        public static let imageMessageCell = "AINutritionistChat.imageMessageCell"
        public static let quickRepliesView = "AINutritionistChat.quickRepliesView"
        public static let todayPlanButton = "AINutritionistChat.todayPlanButton"
        public static let consentButton = "AINutritionistChat.consentButton"
        public static let agreedOfTermsButton = "AINutritionistChat.agreedOfTermsButton"
        public static let energyLevelSlider = "AINutritionistChat.energyLevelSlider"
        public static let sliderActionButton = "AINutritionistChat.sliderActionButton"
        public static let continueButton = "AINutritionistChat.continueButton"
        public static let taskPlanView = "AINutritionistChat.taskPlanView"

        public static func chatReply(titleLabel: String) -> String {
            return "AINutritionistChat.chatReply.\(titleLabel)"
        }
    }

    public enum SmartCamera {

        public static let screen = "SmartCamera.screen"
        public static let galleryButton = "SmartCamera.galleryButton"
        public static let cameraPermissionsCTA = "SmartCamera.Promo.cameraPermissionsCTA"
        public static let errorView = "SmartCamera.errorView"
        public static let scoreView = "SmartCamera.scoreView"

        public enum Promo {
            public static let closeButton = "SmartCamera.Promo.closeButton"
            public static let tipOverlayButton = "SmartCamera.Promo.tipOverlayButton"
        }

        public enum ScoreView {
            public static let logButton = "SmartCamera.ScoreView.logButton"
        }
    }

    public static let protocolConfigurationTitleLabel = "protocolConfigurationTitleLabel"

    public enum Paywall {
        public enum Video {
            public static let scrollView = "Paywall.Video.scrollView"
            public static let continueButton = "Paywall.Video.continueButton"
        }

        public enum Web {
            public static let webViewContainer = "Paywall.Web.webViewContainer"
        }

        public enum OfferGradient {
            public static let rootView = "Paywall.OfferGradient.rootView"
        }
    }

    public enum LoadingView {
        public static let retryButton = "LoadingView.retryButton"
    }

    public enum Feed {
        public static let storyRowCell = "Feed.storyRowCell"
    }

    public enum Content {
        public static let collectionView = "Content.collectionView"
        public static let loadingView = "Content.loadingView"
        public static let feedbackRow = "Content.feedbackRow"
        public static let likeButton = "Content.likeButton"
        public static let likeSelectedButton = "Content.likeSelectedButton"
        public static let rateView = "Content.rateView"
        public static let rateViewStarRated: @Sendable (Int) -> String = {
            "Content.rateViewStar.\($0)"
        }
    }

    public enum StoryArticle {
        public static let collectionView = "StoryArticle.collectionView"

        public static let loadingView = "StoryArticle.loadingView"
        public static let closeButton = "StoryArticle.closeButton"
        public static let likeButton = "StoryArticle.likeButton"
        public static let likedButton = "StoryArticle.likedButton"
        public static let bookmarkButton = "StoryArticle.bookmarkButton"
        public static let nextButton = "StoryArticle.nextButton"
    }

    public enum MealSchedule {
        public static let nextButton = "MealSchedule.nextButton"
    }

    public enum SubscriptionStatus {
        public static let screen = "SubscriptionStatus.screen"
        public static let textLabel = "SubscriptionStatus.textLabel"

        public static let notSubscribedLabel = "SubscriptionStatus.notSubscribedLabel"
        public static let restoreButton = "SubscriptionStatus.restoreButton"
    }

    public enum FoodFeedback {
        public static let screen = "FoodFeedback.screen"
        public static let backButton = "FoodFeedback.backButton"
        public static let doneButton = "FoodFeedback.doneButton"
        public static let rateScreen = "FoodFeedback.rateScreen"
        public static let rateScreenStarView = "FoodFeedback.rateScreenStarView"
        public static let rateViewSubmitButton = "FoodFeedback.rateViewSubmitButton"
        public static let rateViewNotNowButton = "FoodFeedback.rateViewNotNowButton"
        public static let messageRowCell = "FoodFeedback.messageRowCell"
        public static let rateViewStarRated: @Sendable (Int) -> String = {
            "FoodFeedback.rateViewStar.\($0)"
        }

        public static let collectionView = "FoodFeedback.collectionView"
        public static let titleLabel = "FoodFeedback.titleLabel"
        public static let scoreView = "FoodFeedback.scoreView"
        public static let scoreLabel = "FoodFeedback.scoreLabel"
        public static let mealRowCell = "FoodFeedback.mealRowCell"
        public static let mealRowCellLabel = "FoodFeedback.mealRowCellLabel"
    }

    public enum DailyScore {
        public static let mealCell = "DailyScore.mealCell"
        public static let mealCellView = "DailyScore.mealCellView"
        public static let mealCellLabel = "DailyScore.mealCellLabel"
        public static let mealCellScoreLabel = "DailyScore.mealCellScoreLabel"
        public static let scoreRowCell = "DailyScore.scoreRowCell"
    }

    public enum MealSummary {
        public static let editButton = "MealSummary.editButton"
        public static let screen = "MealSummary.screen"
        public static let mealNameLabel = "MealSummary.titleLabel"
        public static let headerRowCell = "MealSummary.headerRowCell"
    }

    public enum NotificationSettings {
        public static let screen = "NotificationSettings.screen"

        public static func boolSetting(key: String) -> String {
            "NotificationSettings.boolSetting.\(key)"
        }
    }

    public enum ExternalSourceConnections {
        public static let screen = "ExternalSourceConnections.screen"
    }

    public static let foodFeedbackLoading = "foodFeedbackLoading"

    public static let noteTrackerScreen = "noteTrackerScreen"

    public static let noteTrackerDoneScreen = "noteTrackerDoneScreen"

    public static let weightTrackerScreen = "weightTrackerScreen"

    public static let feedScreen = "feedScreen"

    public static let storyScreen = "storyScreen"

    public static let profileScreen = "profileScreen"

    public static let horizontalPickerViewCollectionView = "horizontalPickerViewCollectionView"

    public static let dashboardViewControllerCollectionView = "dashboardViewControllerCollectionView"

    public enum ActivityTracker {

        public static let screen = "ActivityTracker.screen"
        public static let collectionView = "ActivityTracker.collectionView"
        public static let textField = "ActivityTracker.textField"

        public static func horizontalPicker(questionId: String) -> String {
            "ActivityTracker.horizontalPicker_" + questionId
        }

        public static func selectRow(questionId: String) -> String {
            "ActivityTracker.selectRow_" + questionId
        }
    }
}
