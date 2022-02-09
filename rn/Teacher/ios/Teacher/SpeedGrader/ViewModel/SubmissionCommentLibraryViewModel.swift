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

import Core
import SwiftUI

class SubmissionCommentLibraryViewModel: ObservableObject {

    @Environment(\.appEnvironment) var env
    @Published var comments: [LibraryComment] = []

    init() {
        let userId = env.currentSession?.userID ?? ""
        let requestable = CommentLibraryRequest(userId: userId)
        env.api.makeRequest(requestable, refreshToken: true) { response, _, _  in performUIUpdate {
            guard let response = response else { return }
            self.comments = response.comments.map { LibraryComment(id: $0.id, text: $0.comment)}
        }
        }
    }
}

class LibraryComment: Identifiable, Hashable {

    let id: ID
    let text: String

    internal init(id: String, text: String) {
        self.id = ID(id)
        self.text = text
    }

    static func == (lhs: LibraryComment, rhs: LibraryComment) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
    }
}
