import Foundation
import SwiftUI

@Observable
class TimerManager {
    var currentPhase: TimerPhase = .sitting
    var timeRemaining: Int = 0
    var isRunning: Bool = false
    var showAlert: Bool = false
    
    private var timer: Timer?
    let settings: SettingsStore  // 改为 let，外部可访问
    
    init(settings: SettingsStore) {
        self.settings = settings
        self.timeRemaining = settings.duration(for: .sitting)
    }
    
    var timeDisplay: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.showAlert = true
            }
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
    }
    
    func resume() {
        start()
    }
    
    func nextPhase() {
        currentPhase = currentPhase.next
        timeRemaining = settings.duration(for: currentPhase)
        showAlert = false
        start()
    }
    
    func skipToNext() {
        timer?.invalidate()
        nextPhase()
    }
    
    func reset() {
        timer?.invalidate()
        isRunning = false
        currentPhase = .sitting
        timeRemaining = settings.duration(for: .sitting)
        showAlert = false
    }
}
