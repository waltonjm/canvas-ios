//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import SwiftUI

public class CourseDetailsViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[CourseDetailsCellViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var homeLabel: String?
    @Published public private(set) var homeSubLabel: String?
    @Published public private(set) var homeRoute: URL?

    @Environment(\.appEnvironment) private var env

    private let context: Context

    private lazy var colors = env.subscribe(GetCustomColors())
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseDidUpdate()
    }
    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.tabsDidUpdate()
    }

    public init(context: Context) {
        self.context = context
    }

    public func viewDidAppear() {
        course.refresh()
        colors.refresh()
        tabs.exhaust()
    }

    private func courseDidUpdate() {
        guard let course = course.first else { return }
        courseColor = course.color
        courseName = course.name
        setupHome(course: course)
    }

    private func setupHome(course: Course) {
        guard let defaultView = course.defaultView else { return }
        homeRoute = URL(string: "courses/\(course.id)/\(defaultView.rawValue)")

        switch course.defaultView {
        case .assignments:
            homeSubLabel = NSLocalizedString("Assignments", comment: "")
        case .feed:
            homeSubLabel = NSLocalizedString("Recent Activity", comment: "")
            homeRoute = URL(string: "courses/\(course.id)/activity_stream")
        case .modules:
            homeSubLabel = NSLocalizedString("Course Modules", comment: "")
        case .syllabus:
            homeSubLabel = NSLocalizedString("Syllabus", comment: "")
        case .wiki:
            homeSubLabel = NSLocalizedString("Front Page", comment: "")
            homeRoute = URL(string: "courses/\(course.id)/pages/front_page")
        case .none:
            return
        }
    }

    private func tabsDidUpdate() {
        if tabs.requested, tabs.pending, tabs.hasNextPage { return }
        var tabs = tabs.all


        if let index = tabs.firstIndex(where: { $0.id == "home" }) {
            let homeTab = tabs.remove(at: index)
            homeLabel = homeTab.label
        }
        let cellViewModels = tabs.map { CourseDetailsCellViewModel(tab: $0, courseColor: courseColor) }
        state = (cellViewModels.isEmpty ? .empty : .data(cellViewModels))
    }
}

extension CourseDetailsViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        course.refresh(force: true)
        tabs.exhaust(force: true) { [weak self] _ in
            if self?.tabs.hasNextPage == false {
                completion()
            }
            return true
        }
    }
}
