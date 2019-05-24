# iMeta Framework 查询参考手册
## 概述
跨服务统一查询是iMeta的一个核心功能，通过查询方案结合元数据，可以实现常见的数据跨查询、缓存查询、远程服务调用查询，通过配置即可完成代码开发工作。<br/>
统一查询服务还可以为数据导出等功能提供数据查询支持，也是通过配置完成。<br/>
本文档将以查询方案为核心，介绍如何根据用户模型来配置查询方案，给出了常见应用场景下的配置方式。

## 用户模型参考
> [电子商城用户模型](mall-model.md)
- 电子商城类图
![电子商城类图](/images/imeta/e/mall.png "Mall Model")
- 电子商城统计分析
![电子商城统计分析](/images/imeta/e/mall-stat.png "Mall Statistic Model")

## 查询方案
![查询方案](/images/imeta/e/query-schema.png "QuerySchema")

![查询条件](/images/imeta/e/query-condition.png "QueryCondition")

查询方案为统一查询引擎对外开发的核心数据结构，所有的查询配置都要遵守查询方案的定义。

> 查询方案示例<br/>
```json
{
  "fullname":"mall.stat.OrderDailyActive",
  "fields":[
    {"name":"statTime.year","alias":"year"},
    {"name":"statTime.month","alias":"aggvalue"},
    {"name":"orderQty","alias":"totalOrderQty","aggr":"sum"},
    {"name":"orderMoney","alias":"totalOrderMoney","aggr":"sum"}
  ],
  "conditions":[
    {"name":"statTime","op":"between","v1":"current_date-11m/min_m","v2":"current_date|max"}
  ],
  "groups":[
    {"name":"statTime.year"},{"name":"statTime.month"}
  ],
  "orders":[
    {"name":"year"},{"name":"aggvalue"}
  ]
}
```
> 术语
- 查询实体：查询方案以哪个实体为参照物展开，不一定为聚合根实体。
> 几种查询形态
- 简单查询<br/>
  - 查询一个实体及关联实体的数据，例如：查询订单Order数据，并一起查询客户Customer名称。
  - 查询方案形如：
    ```json
    {
        "fields": [
            {"name":"code"},{"name":"vouchDate"},{"name":"customer.name"}
        ]
    }
    ```
  - 查询数据形态：查询实体的数据条数等于最终数据条数
- 关联查询
  - 查询一个实体及组合实体的数据，例如：查询订单Order及其子实体OrderDetail数据。
  - 查询方案形如：
    ```json
    {
        "fields": [
            {"name":"code"},{"name":"vouchDate"},{"name":"details.price"},{"name":"details.goods.name"}
        ]
    }
    ```
  - 查询数据形态：查询实体的数据条数一般小于最终数据条数，产生的笛卡尔积中，查询实体的数据会重复
- 组合查询
  - 查询其它实体的数据，该实体可以与查询实体没有直接的实体关系。
  - 查询方案形如：
    查询订单Order和子实体OrderDetail
    ```json
    {
        "fields": [
            {"name":"code"},{"name":"vouchDate"}
        ],
        "compositions":[
            {
                "name": "details",
                "fields": [
                    {"name":"goods.name"},{"name":"price"}
                ]
            }
        ]
    }
    ```
    查询订单和客户Order和Customer
    ```json
    {
        "fields": [
            {"name":"code"},{"name":"vouchDate"}
        ],
        "compositions":[
            {
                "name": "customer",
                "directives": "merge",
                "fields": [
                    {"name":"code"},{"name":"name"}
                ]
            }
        ]
    }
    ```
  - 查询数据形态：查询实体的数据条数为最终数据条数；相关实体数据默认以对象的形式挂载在父数据下面，通过设置directives指令改变数据形态，例如：merge，则子对象数据会合并到父对象中。
    - default
    ```json
    // Order customer
    {
      "code": "DT201805011",
      "customer": {
        "code": "53568",
        "name": "买家53568",
        "id": 53568
      }
    }
    ```
    - merge
    ```json
    // Order customer
    {
      "code": "DT201805011",
      "customer": 53568,
      "customer_code": "53568",
      "customer_name": "买家53568",
      "customer_id": 53568
    }
    ```
    - list
    ```json
    // Order customer
    {
      "code": "DT201805011",
      "customer": [{
        "code": "53568",
        "name": "买家53568",
        "id": 53568
      }]
    }
    ```
    - topN
    ```json
    // Order details
    {
      "id": 1197121333285120,
      "code": "DT201805011",
      "details": [{
        "goods": 1602,
        "price": 338.26,
        "order": 1197121333285120
      }, {
        "goods": 3229,
        "price": 681.74,
        "order": 1197121333285120
      }]
    }
    ```
    - first
    ```json
    // Order details
    {
      "id": 1197121333285120,
      "code": "DT201805011",
      "details": {
        "goods": 1602,
        "price": 338.26,
        "order": 1197121333285120
      }
    }
    ```
    - last
    ```json
    // Order details
    {
      "id": 1197121333285120,
      "code": "DT201805011",
      "details": {
        "goods": 3229,
        "price": 681.74,
        "order": 1197121333285120
      }
    }
    ```
    - merge
    ```json
    // Order details
    // 注意，仅合并第一行
    {
      "id": 1197121333285120,
      "code": "DT201805011",
      "details_goods": 1602,
      "details_price": 338.26,
      "details_order": 1197121333285120
    }
    ```
  - 精确路由策略与名称推断路由策略
    - 精确路由策略<br/>
      *rel不为空，fullname或者name有值，使用精确路径。*

      |类型|来源实体|rel|来源属性|来源字段|目标实体|目标字段|集合|别名|
      |---| ---  | --- | ---  | ---   | ---   | ---  |---|---|
      |asso|Order|id=customer|customer|customer|Customer|id|false|customer|
      |comp|Order|order=id|id|id|OrderDetail|order|true|details|
      |compb|OrderDetail|id=order|order|order|Order|id|false|order|
      |dep|Goods|goods=id|id|id|OrderDetail|goods|true|mallgoodsOrderDetail|
      |asso-asso|OrderDetail|cbocateGoods.id=goods|goods|goods|GoodsCate|cbocateGoods_id|false|goods_cate|
      |comp-comp|Order|logistics.order=id|id|id|OrderLogisticsAction|logistics_order|true|logistics_actions|
      |dep-dep|GoodsCate|goods.cate=id|id|id|OrderDetail|goods_cate|true|cbocateGoods_mallgoodsOrderDetail|
      |asso-comp|OrderDetail|goods=goods|goods|goods|Sku|goods|true|goods_skues|
      |asso-dep|OrderDetail|cate=goodsCate|goodsCate|goodsCate|Goods|cate|true|goodsCate_cbocateGoods|
      |comp-asso|Order|mallgoodsOrderDetail.order=id|id|id|Goods|mallgoodsOrderDetail_order|true|details_goods|
      |comp-dep|Goods|sku.goods=id|id|id|OrderDetail|sku_goods|true|skues_mallskuOrderDetail|
      |dep-asso|GoodsCate|mallgoodsOrderDetail.goodsCate=id|id|id|Goods|mallgoodsOrderDetail_goodsCate|true|mallgoodsCateOrderDetail_goods|
      |dep-comp|GoodsCate|goods.cate=id|id|id|Sku|goods_cate|true|cbocateGoods_skues|
      |comp-asso-comp|Order|goods.mallgoodsOrderDetail.order=id|id|id|Sku|goods_mallgoodsOrderDetail_order|true|details_goods_skues|
      |dep-comp-dep|GoodsCate|sku.goods.cate=id|id|id|OrderDetail|sku_goods_cate|true|cbocateGoods_skues_mallskuOrderDetail|
      |asso-dep-comp|OrderDetail|goods.cate=goodsCate|goodsCate|goodsCate|Sku|goods_cate|true|goodsCate_cbocateGoods_skues|
      |comp-dep-compb|Goods|details.sku.goods=id|id|id|Order|details_sku_goods|true|skues_mallskuOrderDetail_order|
      |compb-compb-comp|OrderLogisticsAction|order.logistics.id=logistics|logistics|logistics|OrderDetail|order_logistics_id|true|logistics_order_details|
      |compb-compb-comp-asso-dep-com|OrderLogisticsAction|goods.cate.mallgoodsCateOrderDetail.order.logistics.id=logistics|logistics|logistics|Sku|goods_cate_mallgoodsCateOrderDetail_order_logistics_id|true|logistics_order_details_goodsCate_cbocateGoods_skues|

    - 名称推断路由策略<br/>
      *rel为空，name有值，使用名称推断。*

      |类型|来源实体|name|来源属性|来源字段|目标实体|目标字段|集合|
      |---| ---  | --- | ---  | ---   | ---   | ---  |---|
      |asso|Order|customer|customer|customer|Customer|id |false|
      |comp|Order|details|details|id|OrderDetail|order |true|
      |compb|OrderDetail|order|order|order|Order|id |false|
      |dep|Goods|mallgoodsOrderDetail|mallgoodsOrderDetail|id|OrderDetail|goods |true|
      |asso-asso|OrderDetail|goods.cate|goods|goods|GoodsCate|cbocateGoods_id |false|
      |comp-comp|Order|logistics.actions|logistics|id|OrderLogisticsAction|logistics_order |true|
      |dep-dep|GoodsCate|cbocateGoods.mallgoodsOrderDetail|cbocateGoods|id|OrderDetail|goods_cate |true|
      |asso-comp|OrderDetail|goods.skues|goods|goods|Sku|goods |true|
      |asso-dep|OrderDetail|goodsCate.cbocateGoods|goodsCate|goodsCate|Goods|cate |true|
      |comp-asso|Order|details.goods|details|id|Goods|mallgoodsOrderDetail_order |true|
      |comp-dep|Goods|skues.mallskuOrderDetail|skues|id|OrderDetail|sku_goods |true|
      |dep-asso|GoodsCate|mallgoodsCateOrderDetail.goods|mallgoodsCateOrderDetail|id|Goods|mallgoodsOrderDetail_goodsCate |true|
      |dep-comp|GoodsCate|cbocateGoods.skues|cbocateGoods|id|Sku|goods_cate |true|
      |comp-asso-comp|Order|details.goods.skues|details|id|Sku|goods_mallgoodsOrderDetail_order |true|
      |dep-comp-dep|GoodsCate|cbocateGoods.skues.mallskuOrderDetail|cbocateGoods|id|OrderDetail|sku_goods_cate |true|
      |asso-dep-comp|OrderDetail|goodsCate.cbocateGoods.skues|goodsCate|goodsCate|Sku|goods_cate |true|
      |comp-dep-compb|Goods|skues.mallskuOrderDetail.order|skues|id|Order|details_sku_goods |true|
      |compb-compb-comp|OrderLogisticsAction|logistics.order.details|logistics|logistics|OrderDetail|order_logistics_id |true|
      |compb-compb-comp-asso-dep-com|OrderLogisticsAction|logistics.order.details.goodsCate.cbocateGoods.skues|logistics|logistics|Sku|goods_cate_mallgoodsCateOrderDetail_order_logistics_id |true|

- 子查询
  - 查询一个实体，条件来源于其它查询方案，例如：订单明细OrderDetail的商品来自数据权限范围的商品
  - 查询方案形如：
    ```js
    {
        "fields": [
            {"name":"goods.name"},{"name":"price"}
        ],
        "conditions": [
            {"name":"goods","op":"in","v1":"@#goods_auth"}
        ],
        "references": [
            {
                "name":"goods_auth",
                "fullname":"base.auth.DataAuth",
                "fields": [
                    {"name":"key"}
                ],
                "conditions": [
                    {"name":"type","op":"eq","v1":"goods"}
                    // 运行期框架会自动增加user等隔离字段的条件
                    // 例如：{"name":"role","op":"in","v1":[当前user的role列表]}
                ]
            }
        ]
    }
    ```
  - 查询数据形态：与其它查询方式查询结果相同，主要是查询条件不同
- 聚合查询
  - 查询数据源来自多个实体，例如：按月查询OrderDailyActive的汇总数据，同时查询商品总数、商品分类总数
  - 查询方案形如：<br/>
    一个聚合查询可以有多个查询方案，分别查询不同数据源数据。
    ```json
    [
        {
            "name": "orderStat",
            "fullname": "mall.stat.OrderDailyActive",
            "fields": [
                {"name":"statTime.year","alias":"year"},
                {"name":"statTime.month","alias":"aggvalue"},
                {"name":"orderQty","alias":"totalOrderQty","aggr":"sum"}
            ]
        },
        {
            "name": "goodsStat",
            "fullname": "cbo.goods.Goods",
            "fields": [
                {"name":"1","alias":"totalCount","aggr":"count"}
            ]
        },
        {
            "name": "goodsCateStat",
            "fullname": "cbo.goods.GoodsCate",
            "fields": [
                {"name":"1","alias":"totalCount","aggr":"count"}
            ]
        }
    ]
    ```
  - 查询数据形态：根据name区分不同数据源的数据。
### 自身属性
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
| name | 查询方案名称 | 否 | 查询组或组合查询时必须<br/>1、子查询时，主查询方案条件根据此标志符定位该方案；<br/>2、组合查询时，是实体属性路径，可以由"."符号连接，<br/>没有rel时根据name推测与主查询的实体关系；<br/>3、应用于查询组，用于区分不同数据源的数据。|
| alias | 组合查询数据别名 | 否 | 组合查询最好使用<br/>应用于组合查询，子查询结果合并到主结果集中的字段名。|
| fullname | 查询实体 | 否 | 查询组、子查询时必须<br/>由现有数据无法推断查询方案的查询实体时，需要指定查询实体名称 |
| rel | 组合查询数据关系 | 否 | 应用于组合查询，表示主子查询方案间的数据关系。<br/>为空时，由name推断主子方案间的数据关系。<br/>rel格式为：子方案查询字段=主方案查询字段|

### 查询字段
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 是 | 使用"."操作符计算关联路径，例如：customer.name，可以是公式表达式|
|alias|别名| 否 | 最终数据结构字段，默认是将"."符号替换成"_"符号 |
|format|格式| 否 | |
|aggr|聚集函数| 否 | sum,count 等聚合函数的简便写法 |
> 示例
```json
{
    "fields": [
        {"name":"code"},
        {"name":"customer.name"},
        {"name":"details.goods.goodsCate.name","alias":"goodsCate_name"}
    ]
}
```
### 查询条件
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 是 | 使用"."操作符计算关联路径 |
|join|关联语句| 是 | 如果join中字段名与name有相同的内容，可以将name部分省略，例如：.qty>100 |
|joinType|关联类型| 否 | inner,left,alone，其中alone和inner或left组合使用，alone表示仅使用join中的<br/>过滤条件，不再与默认条件and运算 |
> 示例
```json
{
    "joins":[
        {"name":"details","join":".order=id && .goods=1001","joinType":"left,alone"}
    ]
}
```
#### 简单条件
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 是 | 使用"."操作符计算关联路径，可以是公式表达式 |
|op|操作符| 否 |默认为eq，参见下面的操作符说明 |
|v1|值1| 否 | 操作符为in或nin时，v1为数组或集合 |
|v2|值2| 否 | 在操作符为between时有效 |

> 操作符说明

| 操作符 | 含义 |
| --- | --- |
| eq | 等于 |
| neq | 不等于 |
| lt | 小于 |
| gt | 大于 |
| elt | 小于等于 |
| egt | 大于等于 |
| leftlike | 左包含 |
| rightlike | 右包含 |
| like | 包含 |
| in | 在…之内 |
| nin | 不在…之内 |
| between | 在…和…之间，结合v2 |
| is_null | 空，字符串null和''都是空 |
| is_not_null | 非空，字符串null和''之外的是非空 |

操作符可以为两个，其中一个操作符为is_null或者is_not_null，构成and和or关系，or关系格式为op1 || op2，and关系格式为op1 && op2。

> 示例
```json
{
    "conditions": [
        {"name":"statTime","op":"between","v1":"current_date-11m/min_m","v2":"current_date|max"},
        {"name":"orderMoney","op":"lt||is_null","v1":10000}
    ]
}
```
```json
{
    "conditions": [
        {"name":"status","op":"in","v1":[1,2,3]}
    ]
}
```
#### 组合条件
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|名称| 否 | 组合条件名称 |
|op|字段名称| 否 | 默认为 and |
|items|子查询条件| 是 | 子查询条件可以为简单条件、组合条件 |

> 示例
```json
{
    "conditions": [
        {
            "op":"or","items":[
                {"name":"statTime","op":"between","v1":"current_date-11m/min_m","v2":"current_date|max"},
                {"name":"orderMoney","op":"lt||is_null","v1":10000}
            ]
        }
    ]
}
```

### 查询分组
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 是 | 使用"."操作符计算关联路径 |

> 示例
```json
{
    "groups":[
        {"name":"goodsCate"}
    ]
}
```

#### 分组条件
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 否 | 分组条件名称 |
|op|字段名称| 否 | 默认为 and |
|items|子查询条件| 是 | 子查询条件可以为简单条件、组合条件 |

> 示例
```json
{
    "conditions": [
        {"name":"count(1)","op":"gt","v1":1}
    ]
}
```
```json
{
    "conditions": [
        {"name":"sum(totalMoney)","op":"gt","v1":0}
    ]
}
```

### 查询排序
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|name|字段名称| 是 | 使用"."操作符计算关联路径 |
|order|排序方式| 否 | asc 升序，desc 降序 |

> 示例
```json
{
    "orders":[
        {"name":"vouchDate","order":"desc"}
    ]
}
```
### 查询分页
| 字段 | 含义 | 必须 | 说明 |
| --- | --- | --- | --- |
|pageIndex| 页码| 否 | 默认为1 |
|pageSize| 页大小| 否 | 默认为10 |
> 示例
```json
{
    "pager": {"pageIndex":1, "pageSize": 100}
}
```

### 公式表达式语法
- 常量(const)<br/>
![const](/images/field/e/const.png "const")
- 名称(name)<br/>
![name](/images/field/e/name.png "name")
- 字段名称(field)<br/>
![field](/images/field/e/field.png "field")
- 表达式(expression)<br/>
![expression](/images/field/e/expression.png "expression")
- 函数(function)<br/>
![function](/images/field/e/function.png "function")
- 条件(condition)<br/>
![condition](/images/field/e/condition.png "condition")
- 条件语句(statement)<br/>
![statement](/images/field/e/statement.png "statement")

## 查询方案示例
以下所有示例均在域隔离级别为**非隔离**的环境中进行。
### 简单查询
- 查询方案示例
```json
{
  "fullname": "mall.order.Order",
  "fields":[
    {"name":"code"},{"name":"vouchDate"},{"name":"customer.name"}
  ],
  "conditions":[
    {"name":"vouchDate","op":"between","v1":"current_date-1m/min_m","v2":"current_date/max"}
  ],
  "orders":[
    {"name":"vouchDate","order":"desc"}
  ],
  "pager":{"pageIndex":1, "pageSize":2}
}
```
- 查询SQL
```sql
select T0.code as `code`,T0.vouch_date as `vouchDate`,T1.name as `customer_name`
from mall_order T0
inner join cbo_customer as T1 on T1.id=T0.customer_id
where T0.vouch_date between ? and ?
order by T0.vouch_date desc
limit 0,2
```
参数：'2019-03-01 00:00:00', '2019-04-29 23:59:59'
- 查询结果
```json
{
	"totalCount": 31212,
	"data": [{
		"code": "mall20190429115949",
		"vouchDate": "2019-04-28 13:00:00",
		"customer_name": "买家59158"
	}, {
		"code": "mall20190429120119",
		"vouchDate": "2019-04-28 13:00:00",
		"customer_name": "买家59158"
	}]
}
```

### 关联查询
- 查询方案示例
```json
{
  "fullname": "mall.order.Order",
  "fields":[
    {"name":"code"},
    {"name":"vouchDate"},
    {"name":"details.goods.name","alias":"goods_name"},
    {"name":"details.price","alias":"price"}
  ],
  "conditions":[
    {"name":"vouchDate","op":"between","v1":"current_date-1m/min_m","v2":"current_date/max"}
  ],
  "orders":[
    {"name":"vouchDate","order":"desc"}
  ],
  "pager":{"pageIndex":1, "pageSize":2}
}
```
- 查询SQL
```sql
select T0.code as `code`,T0.vouch_date as `vouchDate`,T1.price as `price`,T2.name as `goods_name`
from mall_order T0
inner join mall_order_detail as T1 on T1.order_id=T0.id
inner join cbo_goods as T2 on T2.id=T1.goods_id
where T0.vouch_date between ? and ?
order by T0.vouch_date desc
limit 0,2
```
参数：'2019-03-01 00:00:00', '2019-04-29 23:59:59'
- 查询结果
```json
{
	"totalCount": 62424,
	"data": [{
		"code": "mall20190429115949",
		"vouchDate": "2019-04-28 13:00:00",
		"price": 96.53,
		"goods_name": "商品1229"
	}, {
		"code": "mall20190429115949",
		"vouchDate": "2019-04-28 13:00:00",
		"price": 9.17,
		"goods_name": "商品2069"
	}]
}
```

### 组合查询
- 查询方案示例
```json
{
  "fullname": "mall.order.Order",
  "fields":[
    {"name":"id"},
    {"name":"code"},
    {"name":"vouchDate"}
  ],
  "conditions":[
    {"name":"vouchDate","op":"between","v1":"current_date-1m/min_m","v2":"current_date/max"}
  ],
  "orders":[
    {"name":"vouchDate","order":"desc"}
  ],
  "pager":{"pageIndex":1, "pageSize":2},
  "compositions":[
    {
      "name":"details",
      "fields":[
        {"name":"goods.name"},
        {"name":"price"}
      ]
    }
  ]
}
```
- 查询SQL
> 主查询方案
```sql
select T0.id as `id`,T0.code as `code`,T0.vouch_date as `vouchDate`
from mall_order T0
where T0.vouch_date between ? and ?
order by T0.vouch_date desc
limit 0,2
```
参数：'2019-03-01 00:00:00', '2019-04-29 23:59:59'
> 组合查询方案
```sql
select T0.price as `price`,T0.order_id as `order`,T1.name as `goods_name`
from mall_order_detail T0
inner join cbo_goods as T1 on T1.id=T0.goods_id
where T0.order_id in (?,?)
```
参数：由主查询方案查询结果自动提供

- 查询结果<br/>
组合查询方案查询结果挂在主查询方案查询结果下。
```json
{
	"totalCount": 31212,
	"data": [{
		"id": 1201117416395008,
		"code": "mall20190429115949",
		"vouchDate": "2019-04-28 13:00:00",
		"details": [{
			"price": 96.53,
			"order": 1201117416395008,
			"goods_name": "商品1229"
		}, {
			"price": 9.17,
			"order": 1201117416395008,
			"goods_name": "商品2069"
		}]
	}, {
		"id": 1201118892282112,
		"code": "mall20190429120119",
		"vouchDate": "2019-04-28 13:00:00",
		"details": [{
			"price": 96.53,
			"order": 1201118892282112,
			"goods_name": "商品1229"
		}, {
			"price": 9.17,
			"order": 1201118892282112,
			"goods_name": "商品2069"
		}]
	}]
}
```

### 子查询
- 查询方案示例
```json
{
  "fullname": "mall.order.OrderDetail",
  "fields":[
    {"name":"order.code","alias":"code"},
    {"name":"order.vouchDate","alias":"vouchDate"},
    {"name":"goods.name"},
    {"name":"price"}
  ],
  "conditions":[
    {"name":"goods","op":"in","v1":"@#goods_auth"}
  ],
  "orders":[
    {"name":"order.vouchDate","order":"desc"}
  ],
  "pager":{"pageIndex":1, "pageSize":2},
  "references":[
    {
      "name":"goods_auth",
      "fullname":"base.auth.DataAuth",
      "fields":[
        {"name":"key"}
      ],
      "conditions":[
        {"name":"type","op":"eq","v1":"goods"}
      ]
    }
  ]
}
```
- 查询SQL
```sql
select T0.price as `price`,T1.name as `goods_name`,T2.code as `code`,T2.vouch_date as `vouchDate`
from mall_order_detail T0
inner join cbo_goods as T1 on T1.id=T0.goods_id
inner join mall_order as T2 on T2.id=T0.order_id
where T0.goods_id in (select T0.obj_id as `key`
from base_data_auth T0
where (T0.type=? and T0.role in (?,?))
)
order by T2.vouch_date desc
limit 0,2
```
参数：'goods', 'role1', 'role2'
- 查询结果
```json
{
	"totalCount": 634,
	"data": [{
		"price": 723.70,
		"goods_name": "商品3428",
		"code": "DT20190424841",
		"vouchDate": "2019-04-24 13:00:00"
	}, {
		"price": 588.91,
		"goods_name": "商品2789",
		"code": "DT20190424924",
		"vouchDate": "2019-04-24 13:00:00"
	}]
}
```

### 聚合查询
- 查询方案示例<br/>
有3个查询方案分别查询不同的数据源。
```json
[
  {
    "name": "orderStat",
    "fullname": "mall.stat.OrderDailyActive",
    "fields": [
      {"name":"statTime.year","alias":"year"},
      {"name":"statTime.month","alias":"aggvalue"},
      {"name":"orderQty","alias":"totalOrderQty","aggr":"sum"}
    ],
    "conditions":[
      {"name":"statTime","op":"between","v1":"current_date-3m/min_m","v2":"current_date/max"}
    ],
    "groups":[
      {"name":"statTime.year"},{"name":"statTime.month"}
    ],
    "orders":[
      {"name":"statTime.year"},{"name":"statTime.month"}
    ]
  },
  {
    "name": "goodsStat",
    "fullname": "cbo.goods.Goods",
    "fields": [
      {"name":"1","alias":"totalCount","aggr":"count"}
    ]
  },
  {
    "name": "goodsCateStat",
    "fullname": "cbo.goods.GoodsCate",
    "fields": [
      {"name":"1","alias":"totalCount","aggr":"count"}
    ]
  }
]
```
- 查询SQL
> 查询方案1
```sql
select sum(T0.order_qty) as `totalOrderQty`,T1.year as `year`,T1.month as `aggvalue`
from stat_order_daily T0
left join dim_date as T1 on T1.d=T0.stat_time
where T0.stat_time between ? and ?
group by T1.year,T1.month
order by T1.year,T1.month
```
参数：'2019-01-01 00:00:00', '2019-04-29 23:59:59'
> 查询方案2
```sql
select count(1) as `totalCount`
from cbo_goods T0
```
> 查询方案3
```sql
select count(1) as `totalCount`
from cbo_goods_cate T0
```
- 查询结果
```js
{
    // 查询方案3结果
	"goodsCateStat": {
		"flag": 1,
		"data": [{
			"totalCount": 300
		}],
		"totalCount": 1,
		"status": 200
	},
    // 查询方案2结果
	"goodsStat": {
		"flag": 1,
		"data": [{
			"totalCount": 3000
		}],
		"totalCount": 1,
		"status": 200
	},
    // 查询方案1结果
	"orderStat": {
		"flag": 1,
		"data": [{
			"totalOrderQty": 30123,
			"year": 2019,
			"aggvalue": 1
		}, {
			"totalOrderQty": 31798,
			"year": 2019,
			"aggvalue": 2
		}, {
			"totalOrderQty": 32893,
			"year": 2019,
			"aggvalue": 3
		}, {
			"totalOrderQty": 29329,
			"year": 2019,
			"aggvalue": 4
		}],
		"totalCount": 4,
		"status": 200
	}
}
```
### 模版渲染查询
- 查询方案示例
```json
[
  {
    "name": "orderStat",
    "fullname": "mall.stat.OrderDailyActive",
    "fields": [
      {"name":"statTime.year","alias":"year"},
      {"name":"statTime.month","alias":"aggvalue"},
      {"name":"orderQty","alias":"totalOrderQty","aggr":"sum"}
    ],
    "conditions":[
      {"name":"statTime","op":"between","v1":"current_date-11m/min_m","v2":"current_date/max"}
    ],
    "groups":[
      {"name":"statTime.year"},{"name":"statTime.month"}
    ],
    "orders":[
      {"name":"statTime.year"},{"name":"statTime.month"}
    ]
  },
  {
    "name": "goodsStat",
    "fullname": "cbo.goods.Goods",
    "fields": [
      {"name":"1","alias":"totalCount","aggr":"count"}
    ]
  },
  {
    "name": "goodsCateStat",
    "fullname": "cbo.goods.GoodsCate",
    "fields": [
      {"name":"1","alias":"totalCount","aggr":"count"}
    ]
  }
]
```
- 查询SQL
> 查询方案1
```sql
select sum(T0.order_qty) as `totalOrderQty`,T1.year as `year`,T1.month as `aggvalue`
from stat_order_daily T0
left join dim_date as T1 on T1.d=T0.stat_time
where T0.stat_time between ? and ?
group by T1.year,T1.month
order by T1.year,T1.month
```
参数：'2018-06-01 00:00:00', '2019-05-07 23:59:59'
> 查询方案2
```sql
select count(1) as `totalCount`
from cbo_goods T0
```
> 查询方案3
```sql
select count(1) as `totalCount`
from cbo_goods_cate T0
```
- 查询原始结果
```json
{
	"flag": 1,
	"msg": "查询成功",
	"data": {
		"goodsCateStat": {
			"flag": 1,
			"data": [{
				"totalCount": 300
			}],
			"totalCount": 1,
			"status": 200
		},
		"goodsStat": {
			"flag": 1,
			"data": [{
				"totalCount": 3000
			}],
			"totalCount": 1,
			"status": 200
		},
		"orderStat": {
			"flag": 1,
			"data": [{
				"totalOrderQty": 29568,
				"year": 2018,
				"aggvalue": 6
			}, {
				"totalOrderQty": 30520,
				"year": 2018,
				"aggvalue": 7
			}, {
				"totalOrderQty": 29475,
				"year": 2018,
				"aggvalue": 8
			}, {
				"totalOrderQty": 23738,
				"year": 2018,
				"aggvalue": 9
			}, {
				"totalOrderQty": 35170,
				"year": 2018,
				"aggvalue": 10
			}, {
				"totalOrderQty": 29898,
				"year": 2018,
				"aggvalue": 11
			}, {
				"totalOrderQty": 32235,
				"year": 2018,
				"aggvalue": 12
			}, {
				"totalOrderQty": 30123,
				"year": 2019,
				"aggvalue": 1
			}, {
				"totalOrderQty": 31798,
				"year": 2019,
				"aggvalue": 2
			}, {
				"totalOrderQty": 32893,
				"year": 2019,
				"aggvalue": 3
			}, {
				"totalOrderQty": 33687,
				"year": 2019,
				"aggvalue": 4
			}],
			"totalCount": 11,
			"status": 200
		}
	},
	"status": 200
}
```
- 查询渲染模版
> [模版参考手册](template-reference.md "模版参考手册")
```java
{
    "flag": 1,
    "msg": "success",
    "status": 200,
    "data": {
        "goodsCateTotalCount": <#=goodsCateStat.data[0].totalCount#>,
        "goodsTotalCount": <#=goodsStat.data[0].totalCount#>,
        "orderGrowth": {
            <#& orderStat.data,_with1 { #>
            "axis": {
                "data": [
                <#*(item:_with1){#>
                   <#=totalOrderQty#><#?(IS_LAST!=true)#>,<#}#>
                <#}#>
                ]
            },
            "series": {
                "data": [
                <#*(item:_with1){#>
                    "<#=year#>-<#=aggvalue#>"<#?(IS_LAST!=true)#>,<#}#>
                <#}#>
                ]
            },
            "name": "订单增长趋势"
            <#}#>
        }
    }
}
```
- 查询渲染结果
```json
{
	"flag": 1,
	"msg": "success",
	"status": 200,
	"data": {
		"goodsCateTotalCount": 300,
		"goodsTotalCount": 3000,
		"orderGrowth": {
			"axis": {
				"data": [29568, 30520, 29475, 23738, 35170, 29898, 32235, 30123, 31798, 32893, 33687]
			},
			"series": {
				"data": ["2018-6", "2018-7", "2018-8", "2018-9", "2018-10", "2018-11", "2018-12", "2019-1", "2019-2", "2019-3", "2019-4"]
			},
			"name": "订单增长趋势"
		}
	}
}
```
