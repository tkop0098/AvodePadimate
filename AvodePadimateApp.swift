import SwiftUI

struct AvodePadimateView: View {
    @State private var currentFrame: Int = 1
    @State private var isPlaying: Bool = false
    @State private var onionSkinEnabled: Bool = true // Soğan zarı anahtarı
    
    // Her karenin çizim verilerini saklayan yapı (Frame Index -> Çizgiler)
    @State private var frameData: [Int: [[CGPoint]]] = [:]
    
    @State private var currentPath: [CGPoint] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Üst Menü ve Araç Çubuğu
            HStack {
                Text("Avode Padimate")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.orange) // Flash turuncusu vurgu
                
                Spacer()
                
                // Soğan Zarı Açma/Kapama Düğmesi
                Button(action: { onionSkinEnabled.toggle() }) {
                    Image(systemName: "square.3.layers.3d.template")
                        .foregroundColor(onionSkinEnabled ? .orange : .gray)
                }
                .help("Onion Skin (Soğan Zarı)")
                
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                Button("Export MP4") {
                    // Video dışa aktarma tetikleyicisi
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // 2. Çizim Tuvalı (Stage + Onion Skin)
            GeometryReader { geometry in
                Canvas { context, size in
                    // --- SOĞAN ZARI (Önceki Kareleri Silik Çizdir) ---
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
                                // Önceki kareyi yarı şeffaf kırmızı/pembe tonunda göster
                                context.stroke(path, with: .color(.red.opacity(0.3)), lineWidth: 2)
                            }
                        }
                    }
                    
                    // --- MEVCUT KARENİN ÇİZİMLERİ ---
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
                    
                    // --- O AN ÇİZİLMEKTE OLAN ÇİZGİ ---
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
                            // Çizim bitince mevcut karenin listesine ekle
                            var paths = frameData[currentFrame] ?? []
                            paths.append(currentPath)
                            frameData[currentFrame] = paths
                            currentPath = []
                        }
                )
            }
            
            // 3. Alt Zaman Çizelgesi (Timeline)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Kare: \(currentFrame)")
                        .font(.caption)
                    Spacer()
                    Text(onionSkinEnabled ? "Soğan Zarı: Açık" : "Soğan Zarı: Kapalı")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 6) {
                        ForEach(1...30, id: \.self) { frameIndex in
                            let hasContent = frameData[frameIndex]?.isEmpty == false
                            
                            VStack(spacing: 2) {
                                // Kare Kutusu
                                Rectangle()
                                    .fill(frameIndex == currentFrame ? Color.orange : Color(UIColor.systemGray5))
                                    .frame(width: 30, height: 45)
                                    .overlay(
                                        // İçinde çizim varsa küçük bir nokta göster
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
                                            .font(.system(size: 8))
                                            .foregroundColor(frameIndex == currentFrame ? .white : .primary)
                                            .padding(.top, 20)
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
            .frame(height: 90)
            .background(Color(UIColor.systemBackground))
        }
    }
}