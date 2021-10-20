# UIView汇总

一、UIView的一些能力：
- 绘图和动画：
  - 视图使用UIKit或Core Graphics在其矩形区域绘制内容。
  - 您可以将一些视图属性动画为新值。

- 布局和子视图管理
  - 视图可以包含零个或多个子视图。
  - 视图可以调整子视图的大小和位置。
  - 使用Auto Layout来定义调整视图大小和重新定位的规则，以响应视图层次结构中的更改。

- 事件处理
  - 视图是UIResponder的子类，可以响应触摸和其他类型的事件。
  - 视图可以安装手势识别器来处理常见的手势。

二、视图嵌套

默认情况下，当子视图的可见区域扩展到其父视图的边界之外时，子视图的内容不会发生剪切。使用clipsToBounds属性更改该行为。

`addSubview(_:)` 叠加子视图

`insertSubview(_:aboveSubview:)`和`insertSubview(_:belowSubview:)`方法来指定子视图的相对z轴次序


三、视图绘制周期

- 绘制时机：第一次显示时；或由于布局改变而使其全部或部分变得可见时
- 对于使用UIKit或Core Graphics包含自定义内容的视图，系统调用视图的`draw(_:)`方法,这个方法将内容绘制到当前图形上下文（当前图形上下文中是在调用这个方法之前由系统自动设置的）
- 当视图的实际内容发生变化时，通知系统视图需要重绘是您的责任。你可以通过调用视图的`setNeedsDisplay()`或`setNeedsDisplay(_:)`方法来实现。这些方法让系统知道它应该在**下一个绘图周期中更新视图**。因为它要等到下一个绘图周期才更新视图，所以您可以在多个视图上同时调用这些方法来更新它们。

>Note
>
>如果你使用OpenGL ES来画画，你应该使用GLKView类而不是UIView子类化。有关如何使用OpenGL ES绘图的更多信息，请参阅[OpenGL ES Programming Guide.](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008793)

四、Animations

以下UIView类的属性是可动画的:

- frame
- bounds
- center
- transform
- alpha
- backgroundColor

**UIViewPropertyAnimator**

五、子类化

子类化需要您做更多的工作来实现视图并调优其性能。

下面的列表包括了可以考虑在UIView子类中重写的方法:
- Initialization：
  - init(frame:) - 建议您实现此方法。除了这个方法之外，您还可以实现定制的初始化方法。
  - init(coder:) - 如果你从storyboards或nib文件加载视图，并且你的视图需要自定义初始化，那么就实现这个方法。
  - layerClass 只有当你想让你的视图使用不同的核心动画层作为后台存储时，才使用此属性。例如，如果您的视图使用平铺来显示一个大的可滚动区域，您可能希望将属性设置为CATiledLayer类。
    ```swift
    class var layerClass: AnyClass {get}
    
    override class var layerClass : AnyClass {
        return CATiledLayer.self
    }
    //这个方法只在创建视图的早期调用一次，以便创建相应的层对象。
    ```
    

- Drawing and printing:
  - draw(_:) - 如果视图绘制自定义内容，请实现此方法。如果您的视图没有进行任何自定义绘图，请避免重写此方法。
  
  ```swift
  func draw(_ rect: CGRect)

  参数 rect:
  需要更新的视图边界的部分。第一次绘制视图时，这个矩形通常是视图的整个可见边界。然而，在随后的绘图操作中，矩形可能只指定视图的一部分。

  这个方法的默认实现什么也不做。
  使用Core Graphics和UIKit等技术来绘制视图内容的子类应该覆盖这个方法并在那里实现它们的绘制代码。如果视图以其他方式设置其内容，则不需要重写此方法。例如，如果你的视图只是显示一个背景颜色，或者你的视图直接使用底层对象设置它的内容，你就不需要重写这个方法。
  
  当这个方法被调用时，UIKit已经为你的视图配置了适当的绘图环境，你可以简单地调用任何你需要渲染你的内容的绘图方法和函数。具体来说，UIKit创建并配置一个用于绘图的图形上下文，并调整该上下文的转换，使其原点与视图边界矩形的原点匹配。您可以使用`UIGraphicsGetCurrentContext()`函数获得对图形上下文的引用，但不要建立对图形上下文的强引用，因为它可以在调用`draw(_:)`方法之间更改。

  同样,如果使用OpenGL ES和GLKView类绘制,GLKit会在配置底层OpenGL ES上下文之前调用该方法(or the glkView(_:drawIn:) method of your GLKView delegate), so you can simply issue whatever OpenGL ES commands you need to render your content. For more information about how to draw using OpenGL ES, see OpenGL ES Programming Guide.

  您应该将任何绘图限制在rect参数中指定的矩形内。另外，如果视图的isOpaque属性设置为true，你的draw(_:)方法必须完全用不透明的内容填充指定的矩形。
    如果你直接子类化UIView，这个方法的实现不需要调用super。但是，如果你在子类化一个不同的视图类，你应该在实现的某个点调用super。
    当视图首次显示或发生使视图可见部分失效的事件时，将调用此方法。你不应该直接调用这个方法。要使视图的一部分无效，并因此导致该部分被重绘，请调用setNeedsDisplay()或setNeedsDisplay(_:)方法。

    ```

  - draw(_:for:) - Implement this method only if you want to draw your view’s content differently during printing.只有当您希望在打印过程中以不同的方式绘制视图内容时，才需要实现此方法。
    ```swift
    func draw(_ rect: CGRect, 
      for formatter: UIViewPrintFormatter)

    如果希望视图的打印内容与显示内容的显示方式不同，则可以实现此方法。如果将视图打印格式化器添加到打印作业中，但未实现此方法，则调用视图的draw(_:)方法来提供打印的内容。
    有关如何为打印内容实现自定义绘图例程的更多信息，请参见iOS的绘图和打印指南。
    ```
  
- Layout and Constraints:
  
  - requiresConstraintBasedLayout 如果视图类需要约束才能正常工作，请使用此属性。
  - updateConstraints() - 如果您的视图需要在子视图之间创建自定义约束，请实现此方法。
  - alignmentRect(forFrame:), frame(forAlignmentRect:) - 实现这些方法以覆盖视图与其他视图的对齐方式。
  - `didAddSubview(_:), willRemoveSubview(_:)` - 根据需要实现这些方法来跟踪添加和删除子视图。
  - `willMove(toSuperview:), didMoveToSuperview()` - 根据需要实现这些方法来跟踪视图层次结构中当前视图的移动。

- Event Handling:
    - `gestureRecognizerShouldBegin(_:)` - 如果你的视图直接处理触摸事件，并且可能想要阻止附加的手势识别器触发额外的动作，那么就实现这个方法。
   - `touchesBegan(_:with:), touchesMoved(_:with:), touchesEnded(_:with:), touchesCancelled(_:with:)` - Implement these methods if you need to handle touch events directly. (For gesture-based input, use gesture recognizers.)如果你需要直接处理触摸事件，就实现这些方法。(对于基于手势的输入，使用手势识别器。)
  
**有关避免子类化的方法:**

许多视图行为可以在不需要子类化的情况下配置。在开始覆盖方法之前，请考虑修改以下属性或行为是否可以提供您需要的行为。

- **addConstraint(_:)** 
- **autoresizingMask** - Provides automatic layout behavior when the superview’s frame changes. These behaviors can be combined with constraints.
- **contentMode** - Provides layout behavior for the view’s content, as opposed to the frame of the view. This property also affects how the content is scaled to fit the view and whether it is cached or redrawn.
- **isHidden or alpha** - 
- **backgroundColor** -
- Subviews - 
- Gesture recognizers - Rather than subclass to intercept and handle touch events yourself, you can use gesture recognizers to send an Target-Action to a target object.
- Animations - Use the built-in animation support rather than trying to animate changes yourself. The animation support provided by Core Animation is fast and easy to use.使用内置的动画支持，而不是自己尝试动画更改。Core animation提供的动画支持快速且易于使用。

- Image-based backgrounds - For views that display relatively static content, consider using a UIImageView object with gesture recognizers instead of subclassing and drawing the image yourself. Alternatively, you can also use a generic UIView object and assign your image as the content of the view’s CALayer object.对于显示相对静态内容的视图，考虑使用带有手势识别器的UIImageView对象，而不是子类化并自己绘制图像。或者，你也可以使用通用的UIView对象，并分配你的图像作为视图的CALayer对象的内容。


## 主题

### 创建view

`init(frame: CGRect)`
`init?(coder: NSCoder)`

### view外观

`var backgroundColor: UIColor?`

`var isHidden: Bool`

`var alpha: CGFloat`

`var isOpaque: Bool`
一个布尔值，用于确定视图是否不透明。

`var tintColor: UIColor!`
`var tintAdjustmentMode: UIView.TintAdjustmentMode`
[详解 UIView 的 Tint Color 属性](TintColor/)

`var clipsToBounds: Bool`
一个布尔值，决定子视图是否被限制在视图的范围内。

`var clearsContextBeforeDrawing: Bool`
一个布尔值，确定在绘制之前是否应该自动清除视图的边界。
决定在视图重画之前是否先清理视图以前的内容，默认值为YES,如果你把这个属性设为NO，那么你要保证能在 drawRect：方法中正确的绘画。如果你的代码已经做了大量优化，那么设为NO可以提高性能，尤其是在滚动时可能只需要重新绘画视图的一部分


`var mask: UIView?`
An optional view whose alpha channel is used to mask a view’s content.
一个可选视图，其alpha通道用于屏蔽视图的内容。


class var layerClass: AnyClass
Returns the class used to create the layer for instances of this class.
var layer: CALayer
The view’s Core Animation layer used for rendering.

