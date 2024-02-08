import UIKit

class CircularProgressView: UIView {
    var progress: Double = 0 {
        didSet {
            maskLayer.strokeEnd = min(max(CGFloat(progress), 0), 1)
        }
    }
    override var tintColor: UIColor! {
        didSet {
            imageView.tintColor = tintColor
            backgroundImageView.tintColor = tintColor
        }
    }
    private let maskLayer = CAShapeLayer()
    private let imageView: UIImageView
    private let backgroundImageView: UIImageView

    init() {
        let backgroundImage = UIImage(named: "CircularProgressViewBorderThin")!
        backgroundImageView = UIImageView(image: backgroundImage)
        let image = UIImage(named: "CircularProgressViewBorderThick")!
        imageView = UIImageView(image: image)
        super.init(frame: backgroundImageView.frame)
        let x = frame.size.width / 2
        let y = frame.size.height / 2
        let radius = max(x, y)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x, y: y - radius / 2))
        path.addArc(center: CGPoint(x: x, y: y), radius: radius / 2, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = radius
        maskLayer.path = path
        maskLayer.strokeEnd = CGFloat(progress)
        imageView.layer.mask = maskLayer
        addSubview(backgroundImageView)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
