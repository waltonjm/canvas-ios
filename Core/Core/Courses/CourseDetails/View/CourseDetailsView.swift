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

public struct CourseDetailsView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: CourseDetailsViewModel

    public init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            switch viewModel.state {
            case .empty:
                errorView
            case .loading:
                loadingView
            case .data(let tabViewModels):
                tabList(tabViewModels)
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarStyle(.color(viewModel.courseColor))
        .navigationTitle(viewModel.courseName ?? "", subtitle: nil)
        .navigationBarGenericBackButton()
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    @ViewBuilder
    private var errorView: some View {
        // TODO
        Text("Something went wrong")
    }

    @ViewBuilder
    private var loadingView: some View {
        Divider()
        Spacer()
        CircleProgress()
        Spacer()
    }

    @ViewBuilder
    private var header: some View {
        // TODO
        Text("Course name, term")
    }

    private func tabList(_ tabViewModels: [CourseDetailsCellViewModel]) -> some View {
        List {
            ForEach(tabViewModels, id: \.id) { tabViewModel in
                if tabViewModel.isHome {
                    CourseDetailsHomeView(viewModel: tabViewModel)
                } else {
                    CourseDetailsCellView(viewModel: tabViewModel)
                }
            }
        }
        .listStyle(.plain)
        .iOS15Refreshable { completion in
            viewModel.refresh(completion: completion)
        }
    }
}

#if DEBUG
/*
struct CourseDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CourseDetailsViewModel()
        CourseDetailsView(viewModel: viewModel)
    }
}
*/
#endif
