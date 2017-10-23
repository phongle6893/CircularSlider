//
//  BWCircularSlider.swift
//  TB_CustomControlsSwift
//
//  Created by Yari D'areglia on 03/11/14.
//  Copyright (c) 2014 Yari D'areglia. All rights reserved.
//

import UIKit

struct Config {
    
    static let TB_SLIDER_SIZE:CGFloat = UIScreen.main.bounds.size.width
    static let TB_SAFEAREA_PADDING:CGFloat = 60.0
    static let TB_LINE_WIDTH:CGFloat = 20.0
    static let TB_FONTSIZE:CGFloat = 40.0
    
}


// MARK: Math Helpers

func DegreesToRadians (value:Double) -> Double {
    return value * Double.pi / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
    return value * 180.0 /  Double.pi
}

func Square (value:CGFloat) -> CGFloat {
    return value * value
}

enum SelectSlider{
    case slider1 //inside
    case slider2 //outside
    case `nil`
}
// MARK: Circular Slider

class BWCircularSlider: UIControl {
    
    var breakTime:UITextField?
    var pomodoroTime:UITextField?
    var radius1:CGFloat = 0
    var radius2:CGFloat = 0
    var angle1:Int = 30
    var angle2:Int = 150
    var startColor = UIColor.blue
    var endColor = UIColor.purple
    var selectSlider: SelectSlider = .nil
    // Custom initializer
    convenience init(startColor:UIColor, endColor:UIColor, frame:CGRect){
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        
        //Define the circle radius taking into account the safe area
        radius1 = self.frame.size.width/2 - Config.TB_SAFEAREA_PADDING - Config.TB_LINE_WIDTH * 1.5 
        radius2 = self.frame.size.width/2 - Config.TB_SAFEAREA_PADDING
        
        //Define the Font
        let font = UIFont(name: "Avenir", size: Config.TB_FONTSIZE)
        //Calculate font size needed to display 3 numbers
        let str = "💪🏻: 00" as NSString
        let fontSize:CGSize = str.size(withAttributes: [NSAttributedStringKey.font:font!])
        //Using a TextField area we can easily modify the control to get user input from this field
        let pomodoroTimeRect = CGRect(
            x: 0,
            y: 0,
            width: fontSize.width, height: fontSize.height);
        
        pomodoroTime = UITextField(frame: pomodoroTimeRect)
        pomodoroTime?.backgroundColor = UIColor.clear
        pomodoroTime?.textColor = UIColor(white: 1.0, alpha: 0.8)
        pomodoroTime?.textAlignment = .center
        pomodoroTime?.font = font
        pomodoroTime?.text = "🍅: \(Int((Float(angle2)/360) * 60))"
        
        let breakTimeRect = CGRect(
            x: (frame.size.width  - fontSize.width),
            y: 0,
            width: fontSize.width, height: fontSize.height);
        
        breakTime = UITextField(frame: breakTimeRect)
        breakTime?.backgroundColor = UIColor.clear
        breakTime?.textColor = UIColor(white: 1.0, alpha: 0.8)
        breakTime?.textAlignment = .center
        breakTime?.font = font
        
        breakTime?.text = "💪🏻:\(Int((Float(angle1)/360) * 60))"
        
        addSubview(pomodoroTime!)
        addSubview(breakTime!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event!)
        print("--------------")
        print("begin tracking")
        let beginPoint = touch.location(in: self)
        chooseSlider(beginTouch: beginPoint)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        print("-----------------")
        print("continue tracking")
        let lastPoint = touch.location(in: self)
        print(lastPoint)

        self.moveHandle(lastPoint: lastPoint)
        
        self.sendActions(for: UIControlEvents.valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        print("end tracking")
    }
    
    //Use the draw rect to draw the Background, the Circle and the Handle
    override func draw(_ rect: CGRect){
        super.draw(rect)
        print("draw")
        
        /** Draw the Background **/
        let ctx1 = UIGraphicsGetCurrentContext()
        let ctx2 = UIGraphicsGetCurrentContext()
        
        ctx1?.addArc(center: CGPoint(x: CGFloat(self.frame.size.width / 2.0), y: CGFloat(self.frame.size.height / 2.0)), radius: radius1, startAngle: 0, endAngle: CGFloat(CGFloat.pi * 2), clockwise: true)
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).set()
        ctx1?.setLineWidth(Config.TB_LINE_WIDTH * 1.5)
        ctx1?.setLineCap(CGLineCap.butt)
        ctx1?.drawPath(using: CGPathDrawingMode.stroke)
        
        ctx2?.addArc(center: CGPoint(x: CGFloat(self.frame.size.width / 2.0), y: CGFloat(self.frame.size.height / 2.0)), radius: radius2, startAngle: 0, endAngle: CGFloat(CGFloat.pi * 2), clockwise: true)
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).set()
        ctx2?.setLineWidth(Config.TB_LINE_WIDTH * 1.5)
        ctx2?.setLineCap(CGLineCap.butt)
        ctx2?.drawPath(using: CGPathDrawingMode.stroke)
        
        /** Draw the circle **/
        
        /** Create THE MASK Image **/
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height));
        let imageCtx1 = UIGraphicsGetCurrentContext()
        imageCtx1?.addArc(center: CGPoint(x: CGFloat(self.frame.size.width/2)  , y: CGFloat(self.frame.size.height/2)), radius: radius1, startAngle: CGFloat.pi/2, endAngle: CGFloat(DegreesToRadians(value: Double(angle1))), clockwise: true)
        UIColor.red.set()
        
        //Use shadow to create the Blur effect
        imageCtx1?.setShadow(offset: CGSize.zero, blur: CGFloat(self.angle1/15), color: UIColor.black.cgColor)
        //define the path
        imageCtx1?.setLineWidth(Config.TB_LINE_WIDTH)
        imageCtx1?.drawPath(using: .stroke)
        
        
        let imageCtx2 = UIGraphicsGetCurrentContext()
        imageCtx2?.addArc(center: CGPoint(x: CGFloat(self.frame.size.width/2)  , y: CGFloat(self.frame.size.height/2)), radius: radius2, startAngle: CGFloat.pi/2, endAngle: CGFloat(DegreesToRadians(value: Double(angle2))), clockwise: true)
        UIColor.red.set()
        
        //Use shadow to create the Blur effect
        imageCtx2?.setShadow(offset: CGSize.zero, blur: CGFloat(self.angle2/15), color: UIColor.black.cgColor)
        //define the path
        imageCtx2?.setLineWidth(Config.TB_LINE_WIDTH)
        imageCtx2?.drawPath(using: .stroke)

        //save the context content into the image mask
        let mask:CGImage = UIGraphicsGetCurrentContext()!.makeImage()!;
        UIGraphicsEndImageContext();
        
        /** Clip Context to the mask **/
        ctx1!.saveGState()
        ctx1?.clip(to: self.bounds, mask: mask)
        
        /** The Gradient **/
        
        // Split colors in components (rgba)
        let startColorComps = startColor.cgColor.components;
        let endColorComps = endColor.cgColor.components;
        let components : [CGFloat] = [
            startColorComps![0], startColorComps![1], startColorComps![2], 1.0,     // Start color
            endColorComps![0], endColorComps![1], endColorComps![2], 1.0      // End color
        ]
        
        // Setup the gradient
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: baseSpace, colorComponents: components, locations: nil, count: 2)
        
        // Gradient direction
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        // Draw the gradient
        ctx1?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        ctx1!.restoreGState();
        
        
        /* Draw the handle */
        drawTheHandle(ctx: ctx1!, radius: radius1, angle: angle1)
        drawTheHandle(ctx: ctx2!, radius: radius2, angle: angle2)
        
    }
    
    
    
    /** Draw a white knob over the circle **/
    
    func drawTheHandle(ctx:CGContext, radius: CGFloat, angle: Int){
        print("draw handle")
        ctx.saveGState();
        
        //I Love shadows
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 3, color: UIColor.black.cgColor);
        
        //Get the handle position
        let handleCenter = pointFromAngle(angleInt: angle, radius: radius)
        
        //Draw It!
        UIColor(white:1.0, alpha:0.7).set();
        ctx.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: Config.TB_LINE_WIDTH, height: Config.TB_LINE_WIDTH))
        ctx.restoreGState();
    }
    
    
    
    /** Move the Handle **/
    
    func moveHandle(lastPoint:CGPoint){
        print("move hendle")
        //Get the center
        let centerPoint:CGPoint  = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle:Double = AngleFromNorth(p1: centerPoint, p2: lastPoint, flipped: false);
        let angleInt = Int(floor(currentAngle))
        
        //Store the new angle
        switch selectSlider {
        case .slider1:
            //Store the new angle
            angle1 = Int(360 - angleInt)
            //Update the textfield
            breakTime!.text = "💪🏻: \(Int((Float(angle1)/360) * 60))"
        case .slider2:
            //Store the new angle
            angle2 = Int(360 - angleInt)
            //Update the textfield
            pomodoroTime!.text = "🍅: \(Int((Float(angle2)/360) * 60))"
        default:
            print("select nil")
        }
        
        //Redraw
        setNeedsDisplay()
    }
    
    /** Given the angle, get the point position on circumference **/
    func pointFromAngle(angleInt:Int, radius: CGFloat)->CGPoint{
        
        //Circle center
        let centerPoint = CGPoint(x: self.frame.size.width/2.0 - Config.TB_LINE_WIDTH/2.0, y: self.frame.size.height/2.0 - Config.TB_LINE_WIDTH/2.0);
        
        //The point position on the circumference
        var result:CGPoint = CGPoint.zero
        let y = round(Double(radius) * sin(DegreesToRadians(value: Double(-angleInt)))) + Double(centerPoint.y)
        let x = round(Double(radius) * cos(DegreesToRadians(value: Double(-angleInt)))) + Double(centerPoint.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result;
    }
    
    
    //Sourcecode from Apple example clockControl
    //Calculate the direction in degrees from a center point to an arbitrary position.
    func AngleFromNorth(p1:CGPoint , p2:CGPoint , flipped:Bool) -> Double {
        var v:CGPoint  = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag:CGFloat = Square(value: Square(value: v.x) + Square(value: v.y))
        var result:Double = 0.0
        v.x /= vmag;
        v.y /= vmag;
        let radians = Double(atan2(v.y,v.x))
        result = RadiansToDegrees(value: radians)
        return (result >= 0  ? result : result + 360.0);
    }
    func chooseSlider(beginTouch: CGPoint)  {
        
        let centerPoint:CGPoint  = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
        let distance = CGPointDistanceSquared(from: centerPoint, to: beginTouch)
        let avgRadius = (radius1 + radius2) / 2

        selectSlider = (distance < avgRadius) ? .slider1 : .slider2
    }
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
    }
    
}

