import SwiftUI

struct CenteredSliderView: View {
    @State private var selectedValue: Int = 70
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedValue)°")
                .font(.footnote)
                .bold()
            
            CenteredSlider(range: 45...99, selectedValue: $selectedValue, highlightColor: .blue)
        }
        .padding()
        .background(Color.black)
    }
}

struct CenteredSlider: View {
    let range: ClosedRange<Int>
    @Binding var selectedValue: Int
    var highlightColor: Color = LocalColor.Primary.medium
    
    private let sliderHeight: CGFloat = 50
    private let itemWidth: CGFloat = 60
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let sidePadding = (totalWidth - itemWidth) / 2
            
            ZStack {
                // Top and bottom border for the slider area
                Rectangle()
                    .fill(LocalColor.Monochrome.transparent)
                    .frame(height: 50)
                    .overlay(
                        VStack {
                            Rectangle().frame(height: 1).foregroundColor(LocalColor.Secondary.dark)
                            Spacer()
                            Rectangle().frame(height: 1).foregroundColor(LocalColor.Secondary.dark)
                        }
                    )

                // Center Highlight Box (optional visual marker)
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
//                    .frame(width: itemWidth, height: 50)
//                    .zIndex(1)
                
                    RoundedRectangle(cornerRadius: 8)
                        .fill(highlightColor)
                        .frame(width: itemWidth, height: 50)
                        .zIndex(0)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { scrollView in
                        HStack(spacing: 0) {
                            LocalColor.Monochrome.transparent.frame(width: sidePadding)
                            
                            ForEach(range, id: \.self) { value in
                                GeometryReader { itemGeo in
                                    let midX = itemGeo.frame(in: .global).midX
                                    let center = geo.frame(in: .global).midX
                                    let distance = abs(midX - center)
                                    
                                    let scale = max(0.7, 1.3 - (distance / 300))
                                    
                                    DispatchQueue.main.async {
                                        if distance < itemWidth / 2 && selectedValue != value {
                                            selectedValue = value
                                        }
                                    }
                                    
                                    return Text("\(value)°")
                                        .foregroundColor(
                                            value == selectedValue
                                            ? LocalColor.Monochrome.white
                                            : LocalColor.Monochrome.medium
                                        )
                                        .font(.system(size: value == selectedValue ? 30 : 22))
                                        .scaleEffect(scale)
                                        .fontWeight(.bold)
                                        .frame(width: itemWidth, height: 50)
                                        .zIndex(1)
                                        .id(value)
                                }
                                .frame(width: itemWidth, height: 50)
                            }
                            
                            LocalColor.Monochrome.transparent.frame(width: sidePadding)
                        }
                        .background(GeometryReader { scrollGeo in
                            LocalColor.Monochrome.transparent.preference(key: ScrollOffsetPreferenceKey.self, value: scrollGeo.frame(in: .global).minX)
                        })
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                            scrollOffset = offset
                        }
                        .onAppear {
                            scrollView.scrollTo(selectedValue, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(height: 50)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    CenteredSliderView()
}

