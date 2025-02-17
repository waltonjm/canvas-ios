//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import CanvasCore
@testable import Core
@testable import Student
import TestsFoundation

class RoutesTests: XCTestCase {
    lazy var login = TestLogin()
    class TestLogin: LoginDelegate {
        func userDidLogin(session: LoginSession) {}
        func userDidLogout(session: LoginSession) {}

        var opened: URL?
        func openExternalURL(_ url: URL) {
            opened = url
        }
    }

    var api: API { AppEnvironment.shared.api }
    override func setUp() {
        super.setUp()
        API.resetMocks()
        AppEnvironment.shared.currentSession = LoginSession.make()
        AppEnvironment.shared.loginDelegate = login
        AppEnvironment.shared.router = router
    }

    func testRoutes() {
        XCTAssert(router.match("/act-as-user") is ActAsUserViewController)
        XCTAssertEqual((router.match("/act-as-user/3") as? ActAsUserViewController)?.initialUserID, "3")

        XCTAssert(router.match("/calendar") is PlannerViewController)
        XCTAssert(router.match("/calendar?event_id=7") is CalendarEventDetailsViewController)
        XCTAssert(router.match("/calendar_events/7") is CalendarEventDetailsViewController)

        XCTAssertEqual((router.match("/conversations/1") as? HelmViewController)?.moduleName, "/conversations/:conversationID")

        XCTAssert(router.match("/courses") is CoreHostingController<CourseListView>)

        XCTAssert(router.match("/courses/2/announcements") is AnnouncementListViewController)
        XCTAssert(router.match("/courses/2/announcements/new") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/announcements/3") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/2/announcements/3/edit") is CoreHostingController<DiscussionEditorView>)

        XCTAssert(router.match("/courses/2/discussions") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/new") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/discussion_topics/5/edit") is CoreHostingController<DiscussionEditorView>)

        XCTAssert(router.match("/courses/1/assignments") is CoreHostingController<AssignmentListView>)
        XCTAssert(router.match("/courses/2/assignments/3") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/assignments/1/submissions/2") is SubmissionDetailsViewController)

        XCTAssert(router.match("/courses/3/quizzes") is QuizListViewController)

        XCTAssert(router.match("/groups/7") is GroupNavigationViewController)

        XCTAssert(router.match("/logs") is LogEventListViewController)

        XCTAssert(router.match("/courses/1/users") is PeopleListViewController)
        XCTAssert(router.match("/courses/1/users/1") is CoreHostingController<ContextCardView>)
        XCTAssert(router.match("/groups/1/users") is PeopleListViewController)
        XCTAssert(router.match("/groups/1/users/1") is CoreHostingController<GroupContextCardView>)

        XCTAssert(router.match("/courses/1/modules") is ModuleListViewController)
        XCTAssert(router.match("/courses/1/modules/1") is ModuleListViewController)

        XCTAssert(router.match("/users/1/files/2") is FileDetailsViewController)
        XCTAssert(router.match("/users/1/files/2?origin=globalAnnouncement") is FileDetailsViewController)
    }

    func testRoutesWithK5Alternative() {
        ExperimentalFeature.K5Dashboard.isEnabled = true
        let env = AppEnvironment.shared
        guard let session = env.currentSession else { XCTFail(); return }
        env.userDidLogin(session: session)
        env.k5.userDidLogin(isK5Account: true)
        env.userDefaults?.isElementaryViewEnabled = true
        XCTAssert(router.match("/courses/1") is CoreHostingController<K5SubjectView>)
        env.k5.userDidLogin(isK5Account: false)
        XCTAssertEqual((router.match("/courses/1") as? HelmViewController)?.moduleName, "/courses/:courseID")
    }

    func testModuleItems() {
        XCTAssert(router.match("/courses/1/assignments/syllabus") is SyllabusTabViewController)
        XCTAssert(router.match("/courses/1/assignments/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/assignments/2?origin=module_item_details") is AssignmentDetailsViewController)
        XCTAssert(router.match("/courses/1/discussions/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussions/2") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/1/discussion_topics/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussion_topics/2") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/1/discussion_topics/2?origin=module_item_details") is DiscussionDetailsViewController)
        XCTAssert(router.match("/files/1") is FileDetailsViewController)
        XCTAssert(router.match("/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2?skipModuleItemSequence=true") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2/download") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/files/2/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/download?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2?origin=module_item_details") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2/preview") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/preview?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/quizzes/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/module_item_redirect/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/2/items/3") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/items/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/pages/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/pages/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/wiki/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/pages/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/quizzes/2?origin=module_item_details") is QuizDetailsViewController)
    }

    func testFallbackNonHTTP() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        api.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected))
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackRelative() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        api.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected))
        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        router.route(to: "not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened?.absoluteURL, expected)
    }

    func testFallbackAbsoluteHTTPs() {
        let expected = URL(string: "https://instructure.com")!
        api.mock(GetWebSessionRequest(to: URL(string: "https://google.com")!), value: .init(session_url: expected))
        router.route(to: "https://google.com", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackOpensAuthenticatedSession() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route?token=abcdefg")!
        api.mock(
            GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/not-a-native-route")),
            value: .init(session_url: expected)
        )
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackAuthenticatedError() {
        let expected = URL(string: "https://google.com")!
        api.mock(GetWebSessionRequest(to: expected), error: NSError.internalError())
        router.route(to: "https://google.com", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }
}
