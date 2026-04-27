import SwiftUI
import UIKit

@MainActor
enum ShareManager {
    /// Generate a branded share card image
    static func generateShareImage(
        title: String,
        score: Int,
        floor: Int,
        jokerCount: Int,
        ascension: Int
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 600, height: 400)

            // Dark gradient background
            let colors = [UIColor(red: 0.08, green: 0.08, blue: 0.15, alpha: 1.0).cgColor,
                          UIColor(red: 0.12, green: 0.05, blue: 0.08, alpha: 1.0).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: colors as CFArray, locations: [0, 1])!
            ctx.cgContext.drawLinearGradient(gradient, start: .zero,
                                             end: CGPoint(x: 0, y: 400), options: [])

            // Gold border
            UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.6).setStroke()
            let borderPath = UIBezierPath(roundedRect: rect.insetBy(dx: 8, dy: 8), cornerRadius: 16)
            borderPath.lineWidth = 2
            borderPath.stroke()

            // Title
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .heavy),
                .foregroundColor: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            ]
            let titleStr = NSString(string: "🏆 \(title)")
            let titleSize = titleStr.size(withAttributes: titleAttrs)
            titleStr.draw(at: CGPoint(x: (600 - titleSize.width) / 2, y: 40), withAttributes: titleAttrs)

            // Score
            let scoreAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 56, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let scoreStr = NSString(string: "\(score)")
            let scoreSize = scoreStr.size(withAttributes: scoreAttrs)
            scoreStr.draw(at: CGPoint(x: (600 - scoreSize.width) / 2, y: 110), withAttributes: scoreAttrs)

            // Subtitle
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor(white: 0.7, alpha: 1)
            ]
            let lang = L10n.isEnglish
            let subStr = NSString(string: lang
                ? "Floor \(floor) | \(jokerCount) Jokers\(ascension > 0 ? " | A\(ascension)" : "")"
                : "第\(floor)层 | \(jokerCount)张规则牌\(ascension > 0 ? " | 挑战A\(ascension)" : "")")
            let subSize = subStr.size(withAttributes: subAttrs)
            subStr.draw(at: CGPoint(x: (600 - subSize.width) / 2, y: 190), withAttributes: subAttrs)

            // Divider line
            UIColor(white: 0.3, alpha: 1).setStroke()
            let divider = UIBezierPath()
            divider.move(to: CGPoint(x: 60, y: 240))
            divider.addLine(to: CGPoint(x: 540, y: 240))
            divider.lineWidth = 1
            divider.stroke()

            // App name + branding
            let brandAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.8)
            ]
            let brandStr = NSString(string: lang ? "Dou Po Qian Kun" : "斗破乾坤")
            let brandSize = brandStr.size(withAttributes: brandAttrs)
            brandStr.draw(at: CGPoint(x: (600 - brandSize.width) / 2, y: 270), withAttributes: brandAttrs)

            let tagAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(white: 0.5, alpha: 1)
            ]
            let tagStr = NSString(string: lang
                ? "Chinese Poker Roguelike | App Store"
                : "斗地主肉鸽卡牌 | App Store")
            let tagSize = tagStr.size(withAttributes: tagAttrs)
            tagStr.draw(at: CGPoint(x: (600 - tagSize.width) / 2, y: 310), withAttributes: tagAttrs)

            // Challenge text
            let challengeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor(red: 0.4, green: 0.9, blue: 1, alpha: 0.9)
            ]
            let challengeStr = NSString(string: lang ? "Can you beat my score?" : "你能超过我吗？")
            let challengeSize = challengeStr.size(withAttributes: challengeAttrs)
            challengeStr.draw(at: CGPoint(x: (600 - challengeSize.width) / 2, y: 355), withAttributes: challengeAttrs)
        }
    }

    /// Present share sheet
    static func share(image: UIImage, text: String) {
        let items: [Any] = [image, text]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            // Handle iPad popover
            vc.popoverPresentationController?.sourceView = root.view
            vc.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
            root.present(vc, animated: true)
        }
    }
}
