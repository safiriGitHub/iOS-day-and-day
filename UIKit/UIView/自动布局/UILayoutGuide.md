### UILayoutGuide

`@MainActor class UILayoutGuide : NSObject` 
A rectangular area that can interact with Auto Layout.


使用布局指南来替换可能已创建的占位符视图，以表示用户界面中的内部视图空间或封装。传统上，有许多自动布局技术需要占位符视图。占位符视图是一个空视图，它自己没有任何可视元素，只用于在视图层次结构中定义一个矩形区域。例如，如果希望使用约束来定义视图之间空白空间的大小或位置，则需要使用占位符视图来表示该空间。如果要将一组对象居中，则需要一个占位符视图来包含这些对象。类似地，占位符视图可用于包含和封装部分用户界面。占位符视图允许您将一个大型的、复杂的用户界面分解为自包含的、模块化的块。如果使用得当，它们可以极大地简化自动布局约束逻辑。
在视图层次结构中添加占位符视图有许多相关的代价。首先，有创建和维护视图本身的成本。其次，占位符视图是视图层次结构的一个完整成员，这意味着它给层次结构执行的每个任务都增加了开销。最糟糕的是，不可见的占位符视图可能拦截为其他视图准备的消息，从而导致难以发现的问题。
UILayoutGuide类被设计用来执行之前占位符视图执行的所有任务，但是是以一种更安全、更有效的方式来执行的。布局指南不定义新视图。它们不参与视图层次结构。相反，它们只是在其所属视图的坐标系统中定义一个可以与Auto Layout交互的矩形区域。

Creating Layout Guides
To create a layout guide, you must perform the following steps:
1、Instantiate a new layout guide.
2、Add the layout guide to a view by calling the view’s `addLayoutGuide(_:)` method.
3、Define the position and size of the layout guide using Auto Layout.

下面的示例显示了用于在一系列视图之间定义相等间距的布局指南。
```
let space1 = UILayoutGuide()
view.addLayoutGuide(space1)
 
let space2 = UILayoutGuide()
view.addLayoutGuide(space2)
 
space1.widthAnchor.constraintEqualToAnchor(space2.widthAnchor).active = true
saveButton.trailingAnchor.constraintEqualToAnchor(space1.leadingAnchor).active = true
cancelButton.leadingAnchor.constraintEqualToAnchor(space1.trailingAnchor).active = true
cancelButton.trailingAnchor.constraintEqualToAnchor(space2.leadingAnchor).active = true
clearButton.leadingAnchor.constraintEqualToAnchor(space2.trailingAnchor).active = true
```


布局指南还可以充当包含其他视图和控件的不透明框，让你封装视图的部分并将布局分解为模块。
```
let container = UILayoutGuide()
view.addLayoutGuide(container)
 
// Set interior constraints
label.lastBaselineAnchor.constraintEqualToAnchor(textField.lastBaselineAnchor).active = true
label.leadingAnchor.constraintEqualToAnchor(container.leadingAnchor).active = true
textField.leadingAnchor.constraintEqualToAnchor(label.trailingAnchor, constant: 8.0).active = true
textField.trailingAnchor.constraintEqualToAnchor(container.trailingAnchor).active = true
textField.topAnchor.constraintEqualToAnchor(container.topAnchor).active = true
textField.bottomAnchor.constraintEqualToAnchor(container.bottomAnchor).active = true
 
// Set exterior constraints
// The contents of the container can be treated as an opaque box
let margins = view.layoutMarginsGuide
 
container.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
container.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
container.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20.0).active = true
```
