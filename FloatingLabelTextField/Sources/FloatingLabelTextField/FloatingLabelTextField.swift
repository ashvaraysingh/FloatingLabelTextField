// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct FloatingLabelTextField: View {
    private var title: String
    @Binding private var text: String
    @Binding private var isValidBinding: Bool
    @Environment(\.clearButtonHidden) var clearButtonHidden
    @Environment(\.isMandatory) var isMandatory
    @Environment(\.validationHandler) var validationHandler

    @State var validationMessage = ""

    @State private var isValid: Bool  = true {
        didSet {
            isValidBinding = isValid
        }
    }

    public init(title: String, text: Binding<String>, isValidBinding: Binding<Bool>? = nil) {
        self.title = title
        self._text = text
        self._isValidBinding = isValidBinding ?? .constant(true)
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            if isValid == false {
                Text(validationMessage)
                    .foregroundStyle(Color.red)
                    .offset(y: -25)
                    .scaleEffect(0.8, anchor: .leading)
            }
            Text(title)
                .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
                .offset(y: text.isEmpty ? 0 : -25)
                .scaleEffect(text.isEmpty ? 1 : 0.8, anchor: .leading)
            TextField("", text: $text)
                .padding(.trailing, 15)
                .overlay {
                    if !clearButtonHidden {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundStyle(Color(uiColor: .systemGray))
                        }
                        .padding(.trailing, 5)
                    } else {
                        EmptyView()
                    }
                }
                .onAppear {
                    validate(text)
                }.onChange(of: text) { _, newValue in
                    validate(newValue)
                }
        }.padding(.top, 15)
            .animation(.default, value: text)
    }

    fileprivate func validate(_ value: String) {
        isValid = true
        if isMandatory {
            isValid = !value.isEmpty
            validationMessage = isValid ? "" : "This field is mandatory"
        }
        if isValid {
            guard let validationHandler = self.validationHandler else { return }
            let validationRequest = validationHandler(value)
            switch validationRequest {
            case .failure(let error):
                isValid = false
                self.validationMessage = error.localizedDescription
            case .success(let isValid):
                self.isValid = isValid
                self.validationMessage = ""
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var clearButtonHidden: Bool = true
    @Entry var isMandatory: Bool = false
    @Entry var validationHandler: ((String) -> Result<Bool, ValidationError>)?
}

extension View {
    public func clearButtonHidden(_ hidden: Bool = true) -> some View {
        environment(\.clearButtonHidden, hidden)
    }

    public func isMandatory(_ isMandatory: Bool = false) -> some View {
        environment(\.isMandatory, isMandatory)
    }

    public func onValidate(validationHandler: ((String) -> Result<Bool, ValidationError>)?) -> some View {
        environment(\.validationHandler, validationHandler)
    }
}

public struct ValidationError: Error {
    public var message: String

    public init(message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "Message for generic validation errors.")
    }
}

// Make this view show up in the Xcode Library
//public struct FloatingLabelTextFieldLibrary: LibraryContentProvider {
//    let textField = FloatingLabelTextField(title: "Email",
//                                           text: .constant("test@example.com"),
//                                           isValidBinding: .constant(true))
//
//    public var views: [LibraryItem] {
//        [ LibraryItem(textField, category: .control)]
//    }
//
//}
