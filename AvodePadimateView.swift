import SwiftUI

struct AvodePadimateView: View {
    @State private var currentFrame: Int = 1
    @State private var isPlaying: Bool = false
    @State private var onionSkinEnabled: Bool = true
    
    // Kare verileri (Kare Numarası -> Çizgi Noktaları Dizisi)
    @State private var frameData: [Int: [[CGPoint]]] = [:]
    @State private var currentPath: [CGPoint] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Üst Menü / Toolbar
            HStack {
                Text("Avode Padimate")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                
                Spacer()
                
                // Soğan Zarı (Onion Skin) Butonu
                Button(action: { onionSkinEnabled.toggle() }) {
                    Image(systemName: "square.3.layers.3d.template")
                        .font(.title3)
                        .foregroundColor(onionSkinEnabled ? .orange : .gray)
                }
                .padding(.trailing, 10)
                
                // Oynat / Durdur Butonu
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button("Dışa Aktar") {
                    // Export İşlemleri
                }
                .font(.headline)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // 2. Çizim Tuvalı (Stage)
            GeometryReader { geometry in
                Canvas { context, size in
                    // --- SOĞAN ZARI (Önceki Kare) ---
                    if onionSkinEnabled && currentFrame > 1 {
                        let prevFrame = currentFrame - 1
                        if let prevPaths = frameData[prevFrame] {
                            for pathPoints in prevPaths {
                                var path = Path()
                                if let first = pathPoints.first {
                                    path.move(to: first)
                                    for point in pathPoints.dropFirst() {
                                        path.addLine(to: point)
                                    }
                                }
                                context.stroke(path, with: .color(.red.opacity(0.3)), lineWidth: 2)
                            }
                        }
                    }
                    
                    // --- AKTİF KARE ÇİZİMLERİ ---
                    if let currentPaths = frameData[currentFrame] {
                        for pathPoints in currentPaths {
                            var path = Path()
                            if let first = pathPoints.first {
                                path.move(to: first)
                                for point in pathPoints.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                            context.stroke(path, with: .color(.black), lineWidth: 3)
                        }
                    }
                    
                    // --- ANLIK ÇİZİLEN ÇİZGİ ---
                    var activePath = Path()
                    if let first = currentPath.first {
                        activePath.move(to: first)
                        for point in currentPath.dropFirst() {
                            activePath.addLine(to: point)
                        }
                    }
                    context.stroke(activePath, with: .color(.black), lineWidth: 3)
                }
                .background(Color.white)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.append(value.location)
                        }
                        .onEnded { _ in
                            var paths = frameData[currentFrame] ?? []
                            paths.append(currentPath)
                            frameData[currentFrame] = paths
                            currentPath = []
                        }
                )
            }
            
            // 3. Alt Zaman Çizelgesi (Timeline Panel)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Kare: \(currentFrame)")
                        .font(.caption)
                        .bold()
                    Spacer()
                    Text(onionSkinEnabled ? "Soğan Zarı: Açık" : "Soğan Zarı: Kapalı")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 6) {
                        ForEach(1...40, id: \.self) { frameIndex in
                            let hasContent = frameData[frameIndex]?.isEmpty == false
                            
                            VStack(spacing: 2) {
                                Rectangle()
                                    .fill(frameIndex == currentFrame ? Color.orange : Color(UIColor.systemGray5))
                                    .frame(width: 32, height: 45)
                                    .cornerRadius(4)
                                    .overlay(
                                        Group {
                                            if hasContent {
                                                Circle()
                                                    .fill(frameIndex == currentFrame ? Color.white : Color.orange)
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                    )
                                    .overlay(
                                        Text("\(frameIndex)")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(frameIndex == currentFrame ? .white : .primary)
                                            .padding(.top, 22)
                                    )
                            }
                            .onTapGesture {
                                currentFrame = frameIndex
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(height: 95)
            .background(Color(UIColor.systemBackground))
        }
    }
}