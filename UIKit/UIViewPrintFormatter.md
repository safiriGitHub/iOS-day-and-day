**用于显示视图中绘制的内容(可以跨越多个页面)以供打印的对象。**

`@MainActor class UIViewPrintFormatter : UIPrintFormatter`

有三个系统类为应用程序提供了可用的视图打印格式化器:UIKit框架的**UIWebView**和**UITextView**，以及MapKit框架的**MKMapView**。要获取打印作业的视图打印格式化器，调用UIView方法viewPrintFormatter()并初始化打印格式化器继承的布局属性。

