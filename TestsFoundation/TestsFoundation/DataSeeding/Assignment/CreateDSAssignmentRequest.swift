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

//https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.create
public struct CreateDSAssignmentRequest: APIRequestable {
    public typealias Response = DSAssignment

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body, courseId: String) {
        self.body = body
        self.path = "/api/v1/courses/\(courseId)/assignments"
    }
}

extension CreateDSAssignmentRequest {
    public struct RequestDSAssignment: Encodable {
        let name: String
        let description: String?
        let published: Bool

        public init(name: String = "Assignment Name", description: String? = nil, published: Bool = true) {
            self.name = name
            self.description = description
            self.published = published
        }
    }

    public struct Body: Encodable {
        let assignment: RequestDSAssignment
    }
}
