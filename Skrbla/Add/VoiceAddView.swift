import SwiftUI
import Speech
import AVFoundation

struct AddScreenTestView: View {
    let onAdd: (Transaction) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speech = SpeechRecognizer()
    @State private var isRecording = false
    @State private var transcript: String = ""
    @State private var parsed: Transaction?
    @State private var errorMessage: String?
    @State private var isSimulator = false
    @State private var showResults = false
    @State private var animationOffset: CGFloat = 0
    @State private var animationPhase: Double = 0

    init(onAdd: @escaping (Transaction) -> Void = { _ in }) {
        self.onAdd = onAdd
    }

    var body: some View {
        ZStack {
            // Jednoduché černé pozadí
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Velká koule uprostřed s animovaným obsahem
                ZStack {
                    // Animované pozadí uvnitř koule - vrstva 1 (aktivní pouze při nahrávání)
                    Circle()
                        .fill(
                            isRecording ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.6),
                                    Color.purple.opacity(0.4),
                                    Color.blue.opacity(0.3),
                                    Color.black.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 240, height: 240)
                        .offset(x: isRecording ? animationOffset * 0.3 : 0, y: isRecording ? animationOffset * 0.2 : 0)
                        .animation(isRecording ? .linear(duration: 8).repeatForever(autoreverses: true) : .linear(duration: 0.3), value: animationOffset)
                        .clipShape(Circle())
                    
                    // Animované pozadí uvnitř koule - vrstva 2 (aktivní pouze při nahrávání)
                    Circle()
                        .fill(
                            isRecording ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.blue.opacity(0.5),
                                    Color.purple.opacity(0.2),
                                    Color.black.opacity(0.6)
                                ]),
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            ) : LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .frame(width: 240, height: 240)
                        .offset(x: isRecording ? -animationOffset * 0.2 : 0, y: isRecording ? animationOffset * 0.4 : 0)
                        .animation(isRecording ? .linear(duration: 12).repeatForever(autoreverses: true) : .linear(duration: 0.3), value: animationOffset)
                        .clipShape(Circle())
                    
                    // Animované pozadí uvnitř koule - vrstva 3 (radiální, aktivní pouze při nahrávání)
                    Circle()
                        .fill(
                            isRecording ? RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.4),
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.black.opacity(0.7)
                                ]),
                                center: isRecording ? UnitPoint(x: 0.3 + animationPhase * 0.4, y: 0.2 + animationPhase * 0.6) : UnitPoint(x: 0.5, y: 0.5),
                                startRadius: 20,
                                endRadius: 120
                            ) : RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ]),
                                center: UnitPoint(x: 0.5, y: 0.5),
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .animation(isRecording ? .linear(duration: 15).repeatForever(autoreverses: true) : .linear(duration: 0.3), value: animationPhase)
                        .clipShape(Circle())
                    
                    // Vnější kruh pro definici hranice koule
                    Circle()
                        .stroke(
                            isRecording ? LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.blue.opacity(0.6),
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ) : LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 240, height: 240)
                }
                .scaleEffect(isRecording ? 1.15 : 0.6)
                .animation(.easeInOut(duration: 0.5), value: isRecording)
                .shadow(color: isRecording ? .blue.opacity(0.5) : .white.opacity(0.3), radius: isRecording ? 20 : 8)
                .shadow(color: isRecording ? .white.opacity(0.3) : .white.opacity(0.2), radius: isRecording ? 10 : 4)
                .blur(radius: isRecording ? 1 : 0)
                .onAppear {
                    // Jemná pulzující animace pro bílou kouli
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animationOffset = 10
                    }
                }
                
                Spacer()
                
                // Dvě kruhová tlačítka dole
                HStack(spacing: 40) {
                    // Tlačítko mikrofonu
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.8))
                                .frame(width: 60, height: 60)
                                .shadow(color: .white.opacity(0.1), radius: 5)
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(isSimulator)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
                    
                    // Tlačítko X (zrušit)
                    Button(action: {
                        isRecording = false
                        speech.stop()
                        transcript = ""
                        parsed = nil
                        showResults = false
                        // Zastavení animací
                        animationOffset = 0
                        animationPhase = 0
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.8))
                                .frame(width: 60, height: 60)
                                .shadow(color: .white.opacity(0.1), radius: 5)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Overlay pro zobrazení výsledků
            if showResults {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showResults = false
                    }
                
                VStack(spacing: 20) {
                    Text("Rozpoznaný text:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        Text(transcript)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .frame(maxHeight: 200)
                    
                    if let parsed {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: parsed.type == .expense ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundColor(parsed.type == .expense ? .red : .green)
                                Text(parsed.type == .expense ? "Výdaj" : "Příjem")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            
                            Text("Částka: \(Int(parsed.amount)) CZK")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            if let category = parsed.category, !category.isEmpty {
                                Text("Kategorie: \(category)")
                                    .foregroundColor(.gray)
                            }
                            if !parsed.note.isEmpty {
                                Text("Poznámka: \(parsed.note)")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        
                        Button("Uložit") {
                            onAdd(parsed)
                            transcript = ""
                            self.parsed = nil
                            isRecording = false
                            speech.stop()
                            showResults = false
                            // Zastavení animací
                            animationOffset = 0
                            animationPhase = 0
                        }
                        .padding(.horizontal, 30).padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .font(.headline)
                    } else if !transcript.isEmpty {
                        Button("Analyzovat") {
                            parsed = VoiceTransactionParser.parse(text: transcript)
                        }
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    
                    if isSimulator {
                        Button("Test text") {
                            transcript = "Koupil jsem kávu za 150 korun"
                            parsed = VoiceTransactionParser.parse(text: transcript)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Detekce simulátoru
            #if targetEnvironment(simulator)
            isSimulator = true
            #endif
            
            speech.requestAuthorization { authorized, message in
                if !authorized {
                    errorMessage = message ?? "Chybí oprávnění k rozpoznávání řeči nebo mikrofonu."
                }
            }
        }
        .onChange(of: speech.transcript) { _, newValue in
            transcript = newValue
            if !newValue.isEmpty {
                showResults = true
            }
        }
        .onChange(of: isRecording) { _, recording in
            if recording {
                // Spuštění animací při začátku nahrávání
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                    animationOffset = 50
                }
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: true)) {
                    animationPhase = 1.0
                }
            } else {
                // Zastavení animací při konci nahrávání
                animationOffset = 0
                animationPhase = 0
            }
        }
    }

    private func toggleRecording() {
        if isSimulator {
            transcript = "Koupil jsem kávu za 150 korun"
            parsed = VoiceTransactionParser.parse(text: transcript)
            showResults = true
            return
        }
        
        if isRecording {
            speech.stop()
            isRecording = false
        } else {
            errorMessage = nil
            speech.start { result in
                transcript = result
                showResults = true
            } onError: { err in
                errorMessage = err
                isRecording = false
            }
            isRecording = true
        }
    }
}

// MARK: - Model

enum TransactionType {
    case expense
    case income
}

struct Transaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let amount: Double
    let currency: String
    let category: String?
    let note: String
}

// MARK: - Parser

struct VoiceTransactionParser {
    private static let expenseWords = [
        "koupil", "koupila", "zaplatil", "zaplatila", "utratil", "utratila",
        "stalo", "stála", "stalo me", "stalo mě", "natankoval", "objednal", "objednala"
    ]
    
    private static let incomeWords = [
        "dostal", "dostala", "prislo", "přišlo", "prisly", "přišly",
        "prisla", "přišla", "vydelal", "vydělala", "ziskal", "získala",
        "prijem", "příjem", "pripsali", "připsali", "obdržel", "obdrzel"
    ]
    
    static func parse(text: String) -> Transaction? {
        let original = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !original.isEmpty else { return nil }

        let normalized = normalize(original)

        let expenseScore = expenseWords.reduce(0) { $0 + (normalized.contains($1) ? 1 : 0) }
        let incomeScore = incomeWords.reduce(0) { $0 + (normalized.contains($1) ? 1 : 0) }

        let type: TransactionType = incomeScore > expenseScore ? .income : .expense

        // Částka
        guard let amount = extractAmount(from: normalized) else { return nil }

        // Kategorie (velmi jednoduché přiřazení podle klíčových slov)
        let category: String? = {
            if normalized.contains("natank") || normalized.contains("benz") || normalized.contains("paliv") {
                return "Benzín"
            }
            if normalized.contains("oble") || normalized.contains("triko") || normalized.contains("kalhot") {
                return "Oblečení"
            }
            if normalized.contains("jidlo") || normalized.contains("jídlo") || normalized.contains("restaur") || normalized.contains("kava") || normalized.contains("káva") {
                return "Jídlo"
            }
            if normalized.contains("darek") || normalized.contains("dárek") {
                return "Dárky"
            }
            return nil
        }()

        return Transaction(type: type, amount: amount, currency: "CZK", category: category, note: original)
    }

    private static func normalize(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "\u{00A0}", with: " ") // NBSP
    }

    private static func extractAmount(from text: String) -> Double? {
        // Najdi poslední číslo (mívá formát: 1 500, 1500, 1.500, 1500.50, 1500,50)
        let pattern = "(\\d{1,3}(?:[\\u00A0\\s]?\\d{3})*(?:[\\.,]\\d{1,2})?)|\\b\\d+(?:[\\.,]\\d{1,2})?\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let last = matches.last, let rng = Range(last.range, in: text) else { return nil }
        var number = String(text[rng])
        number = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: ".", with: "")
        number = number.replacingOccurrences(of: ",", with: ".")
        return Double(number)
    }
}

// MARK: - Speech

final class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "cs-CZ"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestAuthorization(completion: @escaping (Bool, String?) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(true, nil)
                case .denied:
                    completion(false, "Přístup k rozpoznávání řeči byl zamítnut.")
                case .restricted, .notDetermined:
                    completion(false, "Rozpoznávání řeči není povoleno nebo nebylo určeno.")
                @unknown default:
                    completion(false, "Neznámý stav oprávnění.")
                }
            }
        }
    }

    func start(onUpdate: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        stop()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            onError("Nelze aktivovat audio seanci: \(error.localizedDescription)")
            return
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else {
            onError("Nepodařilo se vytvořit požadavek na rozpoznání.")
            return
        }
        request.shouldReportPartialResults = true

        guard let recognizer, recognizer.isAvailable else {
            onError("Rozpoznávač řeči není dostupný.")
            return
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // Kontrola validity formátu před instalací tap
        guard format.sampleRate > 0 && format.channelCount > 0 else {
            onError("Neplatný audio formát. Zkuste spustit na skutečném zařízení místo simulátoru.")
            return
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            onError("Nelze spustit audio engine: \(error.localizedDescription)")
            return
        }

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = text
                    onUpdate(text)
                }
                if result.isFinal {
                    self.stop()
                }
            }
            if let error {
                DispatchQueue.main.async {
                    onError("Chyba rozpoznávání: \(error.localizedDescription)")
                }
                self.stop()
            }
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
    }
}

#Preview {
    AddScreenTestView()
}
