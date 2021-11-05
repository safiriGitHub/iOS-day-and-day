
## iOS国际化原理分析 TODO

## 配置语言

首先点击`项目->PROJECT->Info->Localizations`中添加要支持的语言.
![](20211105162130.jpg)

>此处Use Base Internationalization开启状态下，每个国际化资源文件会有个Base选项，主要针对String，Storyboard，Xib作为一个基础的模板，像后述storyboard国际化中方案二就是基于Base StoryBoard进行改动。

在点击`+`添加相应语言时会弹出以下对话框，意思是为现有的资源添加语言文件，选择要支持的语言然后点击`Finish`就行了

## 文字国际化

### 创建默认 Localizabel.strings
新建文件 `New File -> Strings File ，取名为Localizabel` 如下图所示
![](20211105162827.jpg)

我们通过一个`Localizable.strings`文件来存储每个语言的文本，它是iOS默认加载的文件，如果想用自定义名称命名，在使用`NSLocalizedString`方法时指定tableName为自定义名称就好了，但你的应用规模不是很大就不要分模块搞特殊了。

每个资源文件如果想为一种语言添加支持，通过其属性面板中的`Localization`添加相应语言就行了，此时`Localizable.strings`处于可展开状态，子级有着相应语言的副本。我们把相应语言的文本放在副本里面就行了


>此处Base与前面提过到的开启`Use Base Internationalization`是有关联的，只有开启了全局`Use Base Internationalization`此处才会显示。那为什么这里没有勾选Base？Base做为一个基础模板，作用于Strings文件是没有太大意义的，另外去掉Base意义着在Base.lproj中少了一个strings文件，APP大小也所有下降，这点对于图片的Base更是如此 **Xcode13.1中已经无此选项, 已经废弃？**

**文件内容举例**

![](20211105165617.jpg)
![](20211105165608.jpg)

**代码使用**
```
NSLocalizedString("首页",comment: "")
NSLocalizedString("好友",comment: "")
NSLocalizedString("我",comment: "")
```
另外中文`strings【Localizable.strings(Simplified)】`可以不要的(可以理解为中文为APP的默认语言)，因为key就是value，当找不到相应的语言strings或value时会直接返回key。nice！这样一来我们做文本的国际化就只要维护一个英文副本strings就O了

## 图片的国际化

方案一 利用Localizable.strings自定义文本

代码：`UIImage(named: NSLocalizedString("search_logo",comment: ""))`

方案二 Assets 支持国际化
选中`Image Set` 点击 `Localize...` 选择支持的语言，如下图
![](20211105170256.jpg)


## Storyboard 、Xib 国际化  未测试

前面的两种资源国际化比较简单，但Storyboard国际化就稍微麻烦了点。同样它也有二种方案

方案一：每种语言定制一套Storyboard
![](http://api.cocoachina.com/uploads/20151117/1447754229173889.png)
在上图我们可以看到，每种语言都可以切换为strings或Storyboard（默认为strings）。如果选用Interface Builder Storyboard方案，那么每种语言都有一套相应的Storyboard，各个语言Storyboard间的界面改动不关联.

在上图我们可以看到，每种语言都可以切换为strings或Storyboard（默认为strings）。如果选用Interface Builder Storyboard方案，那么每种语言都有一套相应的Storyboard，各个语言Storyboard间的界面改动不关联.
![](http://api.cocoachina.com/uploads/20151117/1447754250549237.png)
基于一个基础的Storyboard，可以看作是一个基础的模板，Storyboard里面所有的文本类资源(如UILabel的text)都会被放在相应语言的strings里面。此时我们为Storyboard里的字符类资源作国际化只需要编辑相应语言的strings就行了

首选方案二。因为采用方案一，意义着你每改动一个界面元素就得去相应语言Storyboard一一改动，那跟为每个语言新起一个项目是一样的道理。但是采用方案二，我们只需改动Base Storyboard就行了.

注意，方案二中相应语言的strings一旦生成后，Base Storyboard有任何编辑都不会影响到strings，这就意味着如果我们删除或添加了一个UILabel的text，strings也不能同步改动。

还好，Xcode为我们提供了ibtool工具来生成Storyboard的strings文件。
`ibtool Main.storyboard --generate-strings-file ./NewTemp.string`
但是ibtool生成的strings文件是BaseStoryboard的strings(默认语言的strings)，且会把我们原来的strings替换掉。所以我们要做的就是把新生成的strings与旧的strings进行冲突处理(新的附加上，删除掉的注释掉)，这一切可以用这个pythoy脚本来实现，见[AutoGenStrings.py](https://raw.githubusercontent.com/mokai/iOS-i18n/master/i18n/RunScript/AutoGenStrings.py)。然后我们将借助Xcode 中 Run Script来运行这段脚本。这样每次Build时都会保证语言strings与Base Storyboard保持一致。
![](http://api.cocoachina.com/uploads/20151117/1447754312265308.png)

## 应用内语言切换
## 增加

#### 关于 NSLocalizedString 方法的解释
```swift

/// Returns the localized version of a string.
///
/// - parameter key: An identifying value used to reference a localized string.
///   Don't use the empty string as a key. Values keyed by the empty string will
///   not be localized.
/// - parameter tableName: The name of the table containing the localized string
///   identified by `key`. This is the prefix of the strings file—a file with
///   the `.strings` extension—containing the localized values. If `tableName`
///   is `nil` or the empty string, the `Localizable` table is used.
/// - parameter bundle: The bundle containing the table's strings file. The main
///   bundle is used by default.
/// - parameter value: A user-visible string to return when the localized string
///   for `key` cannot be found in the table. If `value` is the empty string,
///   `key` would be returned instead.
/// - parameter comment: A note to the translator describing the context where
///   the localized string is presented to the user.
///
/// - returns: A localized version of the string designated by `key` in the
///   table identified by `tableName`. If the localized string for `key` cannot
///   be found within the table, `value` is returned. However, `key` is returned
///   instead when `value` is the empty string.
///
/// Export Localizations with Xcode
/// -------------------------------
///
/// Xcode can read through a project's code to find invocations of
/// `NSLocalizedString(_:tableName:bundle:value:comment:)` and automatically
/// generate the appropriate strings files for the project's base localization.
///
/// In Xcode, open the project file and, in the `Edit` menu, select
/// `Export for Localization`. This will generate an XLIFF bundle containing
/// strings files derived from your code along with other localizable assets.
/// `xcodebuild` can also be used to generate the localization bundle from the
/// command line with the `exportLocalizations` option.
///
///     xcodebuild -exportLocalizations -project <projectname>.xcodeproj \
///                                     -localizationPath <path>
///
/// These bundles can be sent to translators for localization, and then
/// reimported into your Xcode project. In Xcode, open the project file. In the
/// `Edit` menu, select `Import Localizations...`, and select the XLIFF
/// folder to import. You can also use `xcodebuild` to import localizations with
/// the `importLocalizations` option.
///
///     xcodebuild -importLocalizations -project <projectname>.xcodeproj \
///                                     -localizationPath <path>
///
/// Choose Meaningful Keys
/// ----------------------
///
/// Words can often have multiple different meanings depending on the context
/// in which they're used. For example, the word "Book" can be used as a noun—a
/// printed literary work—and it can be used as a verb—the action of making a
/// reservation. Words with different meanings which share the same spelling are
/// heteronyms.
///
/// Different languages often have different heteronyms. "Book" in English is
/// one such heteronym, but that's not so in French, where the noun translates
/// to "Livre", and the verb translates to "Réserver". For this reason, it's
/// important make sure that each use of the same phrase is translated
/// appropriately for its context by assigning unique keys to each phrase and
/// adding a description comment describing how that phrase is used.
///
///     NSLocalizedString("book-tag-title", value: "Book", comment: """
///     noun: A label attached to literary items in the library.
///     """)
///
///     NSLocalizedString("book-button-title", value: "Book", comment: """
///     verb: Title of the button that makes a reservation.
///     """)
///
/// Use Only String Literals
/// ------------------------
///
/// String literal values must be used with `key`, `tableName`, `value`, and
/// `comment`.
///
/// Xcode does not evaluate interpolated strings and string variables when
/// generating strings files from code. Attempting to localize a string using
/// those language features will cause Xcode to export something that resembles
/// the original code expression instead of its expected value at runtime.
/// Translators would then translate that exported value—leaving
/// international users with a localized string containing code.
///
///     // Translators will see "1 + 1 = (1 + 1)".
///     // International users will see a localization "1 + 1 = (1 + 1)".
///     let localizedString = NSLocalizedString("string-interpolation",
///                                             value: "1 + 1 = \(1 + 1)"
///                                             comment: "A math equation.")
///
/// To dynamically insert values within localized strings, set `value` to a
/// format string, and use `String.localizedStringWithFormat(_:_:)` to insert
/// those values.
///
///     // Translators will see "1 + 1 = %d" (they know what "%d" means).
///     // International users will see a localization of "1 + 1 = 2".
///     let format = NSLocalizedString("string-literal",
///                                    value: "1 + 1 = %d",
///                                    comment: "A math equation.")
///     let localizedString = String.localizedStringWithFormat(format, (1 + 1))
///
/// Multiline string literals are technically supported, but will result in
/// unexpected behavior during internationalization. A newline will be inserted
/// before and after the body of text within the string, and translators will
/// likely preserve those in their internationalizations.
///
/// To preserve some of the aesthetics of having newlines in the string mirrored
/// in their code representation, string literal concatenation with the `+`
/// operator can be used.
///
///     NSLocalizedString("multiline-string-literal",
///                       value: """
///     This multiline string literal won't work as expected.
///     An extra newline is added to the beginning and end of the string.
///     """,
///                       comment: "The description of a sample of code.")
///
///     NSLocalizedString("string-literal-contatenation",
///                       value: "This string literal concatenated with"
///                            + "this other string literal works just fine.",
///                       comment: "The description of a sample of code.")
///
/// Since comments aren't localized, multiline string literals can be safely
/// used with `comment`.
///
/// Work with Manually Managed Strings
/// ----------------------------------
///
/// If having Xcode generate strings files from code isn't desired behavior,
/// call `Bundle.localizedString(forKey:value:table:)` instead.
///
///     let greeting = Bundle.localizedString(forKey: "program-greeting",
///                                           value: "Hello, World!",
///                                           table: "Localization")
///
/// However, this requires the manual creation and management of that table's
/// strings file.
///
///     /* Localization.strings */
///
///     /* A friendly greeting to the user when the program starts. */
///     "program-greeting" = "Hello, World!";
///
/// - note: Although `NSLocalizedString(_:tableName:bundle:value:comment:)`
/// and `Bundle.localizedString(forKey:value:table:)` can be used in a project
/// at the same time, data from manually managed strings files will be
/// overwritten by Xcode when their table is also used to look up localized
/// strings with `NSLocalizedString(_:tableName:bundle:value:comment:)`.
public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String) -> String

```