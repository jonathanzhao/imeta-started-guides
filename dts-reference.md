# iMeta 数据转换服务参考手册
通过简单配置，实现Excel、csv等文档格式的导入导出功能。
## 导出
导出配置内容包括导出模版和导出母版，导出模版配置导出数据配置、样式，粒度为单元格；<br/>
导出母版为目标类型文件样例，可以设置模版行的格式、样式，导出的行继承该模版行的格式、样式。
### 导出模版数据配置
设置columns数组，里面每一项为导出数据的字段名称，和查询方案配合使用更加灵活；<br/>
当未配置导出母版时，captions为缺省列标题，反之，captions会被忽略。
```json
"columns":["code","customer_name","totalMoney","status","vouchDate"],
"captions":["编码","买家名称","买家手机号","订单金额","状态","下单日期"],
```
### 导出模版格式设置

|名称|含义|说明|
|---|---|---|
|format|格式|格式类型|
|items|枚举值|用于定义枚举显示值|
|formula|Excel公式|例如：C?/B?，?代表行号|
|scale|小数位数||
|styles|单元格样式|样式设置|

> 格式类型

|名称|含义|说明|
|---|---|---|
|date|短日期||
|datetime|日期时间||
|enum|枚举||
|math|四则运算||

> 样式设置

|名称|含义|说明|
|---|---|---|
|trigger|触发条件|包括比较符op和值v1、v2，例如：{"op":"eq","v1":9}|
|style|样式集合|单元格样式，例如：{"color":"RED","bold":true}|

> 比较符

|名称|含义|说明|
|---|---|---|
|eq|等于||
|neq|不等于||
|lt|小于||
|elt|小于等于||
|gt|大于||
|egt|大于等于||
|between|在..之间|需要给出v1和v2两个值|

> 单元格样式

|名称|含义|说明|
|---|---|---|
|foreColor|前景色|颜色范围，例如：LIGHT_ORANGE|
|backColor|后景色|颜色范围|
|color|字体颜色|颜色范围，例如：GREEN|
|italic|斜体|true,false|
|bold|加粗|true,false|

> 颜色范围
```
BLACK, WHITE, RED, BRIGHT_GREEN, BLUE, YELLOW, PINK, 
TURQUOISE, DARK_RED, GREEN, DARK_BLUE, DARK_YELLOW, 
VIOLET, TEAL, GREY_25_PERCENT, GREY_50_PERCENT, 
CORNFLOWER_BLUE, MAROON, LEMON_CHIFFON, ORCHID, CORAL, 
ROYAL_BLUE, LIGHT_CORNFLOWER_BLUE, SKY_BLUE, LIGHT_TURQUOISE, 
LIGHT_GREEN, LIGHT_YELLOW, PALE_BLUE, ROSE, LAVENDER, TAN, 
LIGHT_BLUE, AQUA, LIME, GOLD, LIGHT_ORANGE, ORANGE, BLUE_GREY, 
GREY_40_PERCENT, DARK_TEAL, SEA_GREEN, DARK_GREEN, OLIVE_GREEN, 
BROWN, PLUM, INDIGO, GREY_80_PERCENT, AUTOMATIC
```
> 导出模版配置示例
```json
[
  {
    "entityName":"Order",
    "columns":["code","customer_name","totalMoney","status","vouchDate"],
    "captions":["编码","买家名称","买家手机号","订单金额","状态","下单日期"],
    "formatter":{"status":{"format":"enum","items":{"0":"N/A","1":"待支付","2":"已付款，待确认","3":"已付款","4":"配货中","5":"配货完成，待发货","6":"已发货","7":"已收货","8":"已完成","9":"已取消","10":"货到付款"},"styles":[{"trigger":{"op":"eq","v1":1},"style":{"color":"ORANGE"}},{"trigger":{"op":"eq","v1":9},"style":{"color":"RED","bold":true}},{"trigger":{"op":"egt","v1":7},"style":{"color":"GREEN"}}]},"vouchDate":{"format":"date"}},
    "sheetTitle":"订单",
    "rowStart":"1",
    "sampleRow":"1"
  }
]
```
### 导出母版示例
![订单母版](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/f/excel-tpl.jpg)

### 导出结果示例
![订单导出](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/f/excel-result.jpg)

## 导入
### 导入数据配置
### 关联实体处理
### 组合实体处理
