import SwiftUI

struct ThermostatDet: View {
    
    var deviceId: String
    @State private var selectedValue = 62
    let items = Array(45...99)
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Label(title: "Thermostat", xl18: true, grey: true, left: true)

                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Label(title: "Indoor", xl24: true, white: true, bold: true, left: true)
                            Label(title: "74", xl24: true, white: true, bold: true, center: true)
                        }
                        .frame(width: .infinity)

                        Spacer()
                        
                        OutlinedButton(
                            title: "Heat",
                            heat: true
                        ) {
                            // Handle button tap
                        }
                    }
                    .padding(.horizontal)
                    
                    SetPointPick(items: items, selectedValue: $selectedValue)
                }
            }
        }
    }
}

//#Preview {
//    ThermostatDet()
//}
