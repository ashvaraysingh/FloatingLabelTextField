//
//  SwiftUIView.swift
//  FloatingLabelTextField
//
//  Created by Ashvaray Singh on 16/04/25.
//

import SwiftUI

struct FloatingLabelTextFieldExample: View {
    enum FocusableField: Hashable {
        case firstName
        case lastName
    }

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isFormValid: Bool = false

    @FocusState private var focusField: FocusableField?

    var body: some View {
        VStack {
            FloatingLabelTextField(title: "First Name",
                                   text: $firstName,
                                   isValidBinding: $isFormValid)
                .autocorrectionDisabled()
                .focused($focusField, equals: .firstName)
                .clearButtonHidden(false)
                .isMandatory(true)

            FloatingLabelTextField(title: "Last Name",
                                   text: $lastName,
                                   isValidBinding: $isFormValid)
                .autocorrectionDisabled()
                .focused($focusField, equals: .lastName)
                .clearButtonHidden(false)
                .isMandatory(true)
                .onValidate { value in
                    value.count > 8 ?
                        .success(true) :
                        .failure(ValidationError(message: "Last name must be longer than 8 characters"))
                }
        }
    }
}

#Preview {
    FloatingLabelTextFieldExample()
}
