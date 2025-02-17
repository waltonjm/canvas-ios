//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

class DashboardCardTests: CoreTestCase {
    func testDashboardCard() {
        ContextColor.make(canvasContextID: "course_1", color: .red)
        Course.make()
        let useCase = GetDashboardCards()
        api.mock(useCase, value: [ .make(
            assetString: "course_1",
            courseCode: "CRS1",
            id: "1",
            shortName: "Course One"
        ), ])
        useCase.fetch()
        let card: DashboardCard? = databaseClient.fetch(scope: useCase.scope).first
        XCTAssertEqual(card?.color, .red)
        XCTAssertEqual(card?.course?.id, "1")
        XCTAssertEqual(card?.shortName, "Course One")
    }

    func testTeacherEnrollment() {
        let useCase = GetDashboardCards()
        api.mock(useCase, value: [
            .make(),
            .make(enrollmentType: "TeacherEnrollment", id: "2"),
            .make(enrollmentType: "TAEnrollment", id: "3"),
        ])

        useCase.fetch()
        let cards: [DashboardCard] = databaseClient.fetch(scope: useCase.scope)
        let studentCard: DashboardCard? = cards[0]
        let teacherCard: DashboardCard? = cards[1]
        let taCard: DashboardCard? = cards[2]

        XCTAssertTrue(studentCard?.isTeacherEnrollment == false)
        XCTAssertTrue(teacherCard?.isTeacherEnrollment == true)
        XCTAssertTrue(taCard?.isTeacherEnrollment == true)
    }

    func testUpdatesCourseRelationship() {
        let course = Course.save(.make(), in: databaseClient)
        let card = DashboardCard.save(.make(), position: 0, in: databaseClient)
        XCTAssertEqual(card.course, course)
    }
}
