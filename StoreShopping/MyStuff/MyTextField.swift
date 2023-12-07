//
//  MyTextField.swift
//
//  Created by Brian Quick on 2021-09-02.
//
// 2021-11-26 added numberPad if numeric
/*
   2023-11-24 added a check for multiple decimals in a Double or CGFloat
              fixed the geometry reader so it does not take up a full screen
          added the placeholder that will default to title
          these should not affect the current use of this in the handicapp app
            added a SecureField type for password entry
*/
import SwiftUI

enum myTextType: String {
    case String
    case Int
    case Double
    case CGFloat
    case Display
    case SecureField
}
struct myTextField: View {
    @Binding var value: String
    var title: String
    var subtitle: String?
    var texttype: myTextType
    var placeHolder: String = ""
    let ints = "1234567890"
    let decimalSeperator: String = Locale.current.decimalSeparator ?? "."
    let doubles = "1234567890" + (Locale.current.decimalSeparator ?? ".")


    var body: some View {
        return GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .frame(width: geometry.size.width * 0.33)
                    if let subtitle = subtitle, subtitle.isEmpty == false {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    }
                }
                switch texttype {
                case .Display:
                    Text("\(value)")
                case .SecureField:
                    SecureField(title, text: $value)
                default:

                    Spacer()

                    TextField(placeHolder == "" ? title : placeHolder, text: $value)
                    // FIXME: this will set the keyboard type on ios but not on macos
#if os(iOS)
                        .keyboardType(keyboardTypeForTextType(texttype))
#endif
                        .border(Color.gray)
                        .onChange(of: value, perform: {
                            var txt = ""
                            switch texttype {
                            case .Double, .CGFloat:
                                txt = $0.filter(doubles.contains)
                                // do not allow more that one decimal to be entered
                                if txt.components(separatedBy: decimalSeperator).count-1 > 1 {
                                    txt = String(txt.dropLast())
                                }
                            case .Int:
                                txt = $0.filter(ints.contains)
                            default:
                                txt = $0
                            }
                            if $0 != txt {
                                value = txt
                            }
                        })
                }
            }
        }
        .fixedSize( horizontal: false, vertical: true)
    }
    // Function to determine keyboard type based on MyTextType
    private func keyboardTypeForTextType(_ type: myTextType) -> UIKeyboardType {
        switch type {
        case .Int:
            return .numberPad
        case .CGFloat, .Double:
            return .decimalPad
        default:
            return .default
        }
    }
}

// Previews OK 2021-11-03 08:18
struct myTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            myTextField(value: .constant("1"), title: "title", subtitle: "subTitle", texttype: .Int)
                .frame(width: 300)
        }
    }
}

