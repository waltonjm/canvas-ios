//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import Foundation
import SwiftUI

public class DashboardInvitationsViewModel: ObservableObject {
    // MARK: - Public Properties
    /** `id` is the enrollment's id. */
    @Published public private(set) var invitations: [(id: String, course: Course, enrollment: Enrollment)] = []

    // MARK: - Private Properties
    private lazy var invitationsStore = AppEnvironment.shared.subscribe(GetCourseInvitations()) { [weak self] in
        self?.update()
    }
    private lazy var coursesStore = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
        self?.update()
    }
    private var isRefreshFinished: Bool {
        invitationsStore.requested && !invitationsStore.pending &&
        coursesStore.requested && !coursesStore.pending
    }

    // MARK: - Public Methods

    public func refresh(force: Bool = false) {
        coursesStore.exhaust(force: force)
        invitationsStore.exhaust(force: force)
    }

    // MARK: - Private Methods

    private func update() {
        guard isRefreshFinished else { return }

        var newInvitations: [(id: String, course: Course, enrollment: Enrollment)] = []

        for enrollment in invitationsStore.all {
            if let id = enrollment.id, let course = coursesStore.first(where: { "course_\($0.id)" == enrollment.canvasContextID }) {
                newInvitations.append((id: id, course: course, enrollment: enrollment))
            }
        }

        self.invitations = newInvitations
    }
}
