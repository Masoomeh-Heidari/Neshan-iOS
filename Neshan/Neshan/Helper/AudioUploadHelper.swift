import Foundation
import AVFoundation

class AudioUploadHelper {
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    func uploadFile(using fileURL: URL,
                          to endpoint: String,
                          progress: @escaping (Double) -> Void,
                          completion: @escaping (Result<String?, AppError>) -> Void) {
        do {
            let data = try Data(contentsOf: fileURL)
            requestManager.uploadFile(using: data, to: endpoint, progress: progress) { result in
                switch result {
                    case .success(let data):
                    guard let data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let term = json["text"] as? String else {
                        completion(.failure(AppError.invalidResponse))
                        return
                    }
                    completion(.success(term))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch let error {
            completion(.failure(AppError.fileConversionFailed))

        }
    }
}

// MARK: - Usage Example
//extension AudioUploadHelper {
//    static func example() {
//        let helper = AudioUploadHelper()
//        
//        guard let bundlePath = Bundle.main.path(forResource: "report", ofType: "wav"),
//              let voiceRecordingURL = URL(string: "file://" + bundlePath) else {
//            print("Failed to find voice.wav file")
//            return
//        }
//        
//        helper.convertAndUpload(
//            audioFileURL: voiceRecordingURL,
//            to: "process",
//            progress: { progress in
//                print("Upload progress: \(progress * 100)%")
//            },
//            completion: { result in
//                switch result {
//                case .success(let data):
//                    print("Upload successful: \(String(describing: data))")
//                case .failure(let error):
//                    print("Upload failed: \(error)")
//                }
//            }
//        )
//    }
//}
