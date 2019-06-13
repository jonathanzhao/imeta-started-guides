# iMeta Framework 统一查询服务实现原理
## 概述
在微服务（micro-services）架构下，针对不同数据源查询提供统一的查询接口、对开发人员透明化查询细节是iMeta框架的一个核心功能。<br/>
统一查询的Facade为查询引擎，查询引擎结合元数据，通过解析查询方案，调用查询服务，最终输出查询数据，执行过程如下图。<br/>
![查询引擎执行过程](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-engine.png "UnifiedQueryEngine")

实际执行时，需要对微服务架构下多服务协同查询，下图为电子商城订单查询示例。<br/>
![电子商城订单查询](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-instance.png "Mall Order Query")

能够实现此功能主要得益于iMeta框架使用元数据（metadata）对用户模型（user model）进行描述，并扩展了面向服务所需的信息，下面结合电子商城示例对实现原理进行阐述。

## 用户模型参考
> [电子商城用户模型](https://github.com/jonathanzhao/imeta-started-guides/blob/master/mall-model.md)
- 电子商城类图
![电子商城类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall.png "Mall Model")

使用域（domain）对用户模型进行划分，划分粒度为微服务划分粒度。默认情况下，不同域间相互访问数据需要通过调用服务获取。<br/>
上例中有三个域：订单域、客户域、商品域，在微服务架构下，对应订单服务、客户服务、商品服务，这些服务都是单独部署，可以使用不同的存储方式，同一服务中也可以有多种存储方式。

## 查询方案
![查询方案](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-schema.png "QuerySchema")

![查询条件](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-condition.png "QueryCondition")
isolationLevel˚isolationLevelisolationLevelisolationLevel
查询方案为统一查询引擎对外开放的核心数据结构，所有的查询配置都要遵守查询方案的定义，详细内容参考 [查询参考手册](https://github.com/jonathanzhao/imeta-started-guides/blob/master/query-reference.md)。

## 查询原理分析isolationLevel
通过在元数据（metadata）的组件上设置domain以及实体上设置service属性，来标志查询实体的归属以及数据源。<br/>
域（domain）对应服务划分，因为组件是iMeta中的最小部署单元，所以domain均在组件上设置。

```xml
<!-- customer域 -->
<component name="customer" title="客户组件" moduleName="cbo" domain="customer">
    <!-- 客户实体... -->
</component>
```

```xml
<!-- order域 -->
<component name="order" title="订单组件" moduleName="mall" domain="order">
    <!-- 订单实体... -->
</component>
```

> 域（domain）的划分原则

- 按照微服务划分域（domain），即域与部署有映射关系；划分时要综合考虑数据存储形式、效率等诸多因素，但最先考虑的是业务需要。
- 一个域（doamin）可以对应多个组件，即多个组件共同构建一个完整的服务。
- 对于公共的组件（例如租户、用户），一般不设置domain，该组件可以在任何组件中使用。这些实体一般不需要联查，如果必须联查（例如：联查用户名称），通过冗余存储、缓存服务都可以实现。
- 对域的解释权不在iMeta中内置，而是通过profile解释，默认是不考虑域的概念的；iMeta给出了DomainIsolation、OneInstance两种默认实现，还可以自定义不同的profile实现。
  - 如果应用了DomainIsolationPropertyProfile，则所有domain不同的组件中的实体关联查询时，都要通过调用远程服务获取数据。
  - 如果应用了OneInstanceEntityProfile，则所有domain不同的组件中的实体关联查询时，通过本地查询服务进行，不同数据库实例名称附加到表名前面。
- 在当前域查询时，默认使用本地查询服务（数据源一般是关系数据库）进行。

> 服务协议（service）设置

```xml
<!-- 商品分类缓存服务协议描述 -->
<class name="GoodsCate" title="商品分类" tableName="cbo_goods_cate" service="cache:redis://1?key=goods-cate&amp;subKey=id&amp;type=json">
</class>
<!-- 商品缓存服务协议描述 -->
<class name="Goods" title="商品" tableName="cbo_goods" service="cache:redis://1?key=goods&amp;subKey=id&amp;type=json">
</class>
```

服务协议（service）格式为： **协议:驱动://服务器信息/数据源?参数列表** ，iMeta框架在服务定位时使用 **协议:驱动:** 部分，其余部分信息是提供给不同数据源驱动程序的，所以没有固定格式，但在同一个系统中，建议使用相似的格式；这些驱动程序通过扩展插件的形体提供，如果未找到合适的驱动程序，会尝试使用本地查询服务进行查询。

> 统一查询流程

![统一查询流程](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/query-flow.png "query flow")

> 统一查询时序

![统一查询时序](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/unified-query.png "unified query")

> 组合查询时序

![组合查询时序](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/composition-query.png "composition query")

下面按照同域关联查询、跨域关联查询、缓存关联查询、组合查询这4种场景对统一查询执行过程进行详细说明。

### 同域关联查询
查询方案

```json
{
  "fullname": "mall.order.Order",
  "fields": [
    {"name": "code"},
    {"name": "if status=1 then '待支付' elseif status=1 || status=2 then '已付款' else '后续流程' end","alias": "status"},
    {"name": "details.qty"}
  ],
  "conditions": [
    {"name": "vouchDate", "op": "between", "v1": "current_date-3m/min", "v2": "current_date/max"}
  ],
  "pager": {"pageIndex":1, "pageSize": 2}
}
```

首先进行查询方案解析，解析后形成查询树和物理树，查询树与查询方案间有直接映射关系，物理树用于查询层次结构。<br/>
查询树结构

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <String> code code [S-----] [L]
--BlockQueryNode	: <> '#' status [S-----] [L]
----CaseQueryNode	: <> case  [------] [L]
------WhenQueryNode	: <> when  [------] [L]
--------EqQueryNode	: <> =  [------] [L]
----------QueryNode	: <OrderStatus> status  [S-----] [L]
----------ValueQueryNode	: <> 1  [------] [L]
--------ValueQueryNode	: <> '待支付'  [------] [L]
------WhenQueryNode	: <> when  [------] [L]
--------LogicalQueryNode	: <> or  [------] [L]
----------EqQueryNode	: <> =  [------] [L]
------------QueryNode	: <OrderStatus> status  [S-----] [L]
------------ValueQueryNode	: <> 1  [------] [L]
----------EqQueryNode	: <> =  [------] [L]
------------QueryNode	: <OrderStatus> status  [S-----] [L]
------------ValueQueryNode	: <> 2  [------] [L]
--------ValueQueryNode	: <> '已付款'  [------] [L]
------ElseQueryNode	: <> else  [------] [L]
--------ValueQueryNode	: <> '后续流程'  [------] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
--QueryNode	: <OrderDetail> details  [------] [L]
----QueryNode	: <Decimal> details.qty details_qty [S-----] [L]
```

物理树结构

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <String> code code [S-----] [L]
--QueryNode	: <OrderDetail> details  [------] [L]
----QueryNode	: <Decimal> details.qty details_qty [S-----] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
--QueryNode	: <OrderStatus> status  [S-----] [L]
--QueryNode	: <OrderStatus> status  [S-----] [L]
--QueryNode	: <OrderStatus> status  [S-----] [L]
```

同一个组件内查询，直接使用本地查询服务进行查询<br/>
查询总数

```sql
select count(1) as totalCount from (
	select 1 as num
	from mall_order T0
	inner join mall_order_detail as T1 on T1.order_id=T0.id
	where T0.vouch_date between ? and ?
) t
```

分页查询

```sql
-- 根据元数据中属性设置来确定 inner join 或 left join。
select T0.code as `code`,case when (T0.status=1) then '待支付' when ((T0.status=1) or (T0.status=2)) then '已付款' else '后续流程' end as `status`,T1.qty as `details_qty`
from mall_order T0
inner join mall_order_detail as T1 on T1.order_id=T0.id
where T0.vouch_date between ? and ?
limit 0,2
```

查询结果

```json
{
	"totalCount": 57517,
	"data": [{
		"code": "DT201903121",
		"status": "后续流程",
		"details_qty": 97.00
	}, {
		"code": "DT201903121",
		"status": "后续流程",
		"details_qty": 4632.00
	}]
}
```

### 跨域关联查询
隔离级别profile设置为domainIsolation。<br/>
查询方案

```json
{
  "fullname": "mall.order.Order",
  "fields": [
    {"name": "code"},
    {"name": "status"},
    {"name": "customer.name"}
  ],
  "conditions": [
    {"name": "vouchDate", "op": "between", "v1": "current_date-3m/min", "v2": "current_date/max"}
  ],
  "pager": {"pageIndex":1, "pageSize": 2}
}
```

由于Order与Customer在不同的域中，对customer.name进行查询需要调用远程服务查询。<br/>
首先进行查询方案解析，解析后形成查询树和物理树，查询树与查询方案间有直接映射关系，物理树用于查询层次结构。<br/>
查询树结构

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <String> code code [S-----] [L]
--QueryNode	: <OrderStatus> status status [S-----] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
--QueryNode	: <Customer> customer customer [S-----] [L]
----QueryNode	: <String> customer.name customer_name [S-----] [R]
```

物理树结构

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <String> code code [S-----] [L]
--QueryNode	: <OrderStatus> status status [S-----] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
--QueryNode	: <Customer> customer customer [S-----] [L]
----QueryNode	: <String> customer.name customer_name [S-----] [R]
```

由于没有公式等特殊结构，物理树与查询树结构相同。由查询树中服务标志位可以看出，对customer.name（标识位是[R]）进行查询需要调用Remote服务。

跨域关联查询需要拆分查询方案，拆分后的主查询方案

```json
{
  "fullname": "mall.order.Order",
  "fields": [
    {"name": "code"},
    {"name": "status"},
    // 补充缺少的customer字段，后续通过该字段生成远程查询方案的条件，并通过它合并主数据与远程数据
    {"name": "customer"}
  ],
  "conditions": [
    {"name": "vouchDate", "op": "between", "v1": "current_date-3m/min", "v2": "current_date/max"}
  ],
  "pager": {"pageIndex":1, "pageSize": 2}
}
```

查询总数

```sql
select count(1) as totalCount from (
select 1 as num
from mall_order T0
where T0.vouch_date between ? and ?
) t
```

分页查询主数据

```sql
select T0.code as `code`,T0.status as `status`,T0.customer_id as `customer`
from mall_order T0
where T0.vouch_date between ? and ?
limit 0,10
```

分页查询结果

```json
[{
	"code": "DT201903111",
	"status": 3,
	"customer": 51387
}, {
	"code": "DT201903112",
	"status": 2,
	"customer": 50854
}]
```

构造远程查询方案，查询条件根据主数据中customer字段的值构建

```json
[
    {
        "name":"customer",
        "fullname":"cbo.customer.Customer","sourceFullName":"mall.order.Order",
        "fieldAlias":"customer",
        "fields":[
            {"name":"id","alias":"customer"},
            {"name":"name","alias":"customer_name"}
        ],
        "conditions":[
            {"op":"and","items":[{"op":"and","items":[{"name":"id","op":"in","v1":[50854,51387]}]}]}
        ]
    }
]
```

解析后的查询树

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Customer>   [------] [L]
--QueryNode	: <Long> id customer [S-W---] [L]
--QueryNode	: <String> name customer_name [S-----] [L]
--QueryNode	: <Long> tenant  [--W---] [L]
```

查询远程数据

```sql
-- 远程数据也可能通过缓存服务获取数据，原理是一样的
select T0.id as `customer`,T0.name as `customer_name`
from cbo_customer T0
where T0.id in (?,?)
```

远程查询结果

```json
[{
	"customer": 51387,
	"customer_name": "买家51387"
}, {
	"customer": 50854,
	"customer_name": "买家50854"
}]
```

最终将主数据和远程数据通过customer字段的值进行合并

```json
{
	"totalCount": 29749,
	"data": [{
		"code": "DT201903111",
		"status": 3,
		"customer": 51387,
		"customer_name": "买家51387"
	}, {
		"code": "DT201903112",
		"status": 2,
		"customer": 50854,
		"customer_name": "买家50854"
	}]
}
```

### 缓存关联查询
隔离级别profile设置为cacheIsolation。<br/>
与其它服务不同的是，缓存服务一般需要提供数据补充查询，即将无法命中缓存的键值通过查询方案本地查询，将查询结果补充到缓存中。<br/>
查询方案

```json
{
  "fullname": "mall.order.Order",
  "fields": [
    {"name": "code"},
    {"name": "status"},
    {"name": "customer.name"}
  ],
  "conditions": [
    {"name": "vouchDate", "op": "between", "v1": "current_date-3m/min", "v2": "current_date/max"}
  ],
  "pager": {"pageIndex":1, "pageSize": 2}
}
```

查询树

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <String> code code [S-----] [L]
--QueryNode	: <OrderStatus> status status [S-----] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
--QueryNode	: <Customer> customer customer [S-----] [L]
----QueryNode	: <String> customer.name customer_name [S-----] [C]
```

查询字段customer.name的查询服务标识为[C]，需要调用查询服务获取数据。<br/>
查询方案会拆分成两部分，先查询主数据，再根据主数据构造查询条件，调用缓存服务查询关联数据。

查询总数

```sql
select count(1) as totalCount from (
select 1 as num
from mall_order T0
where T0.vouch_date between ? and ?
) t
```

分页查询主数据

```sql
select T0.code as `code`,T0.status as `status`,T0.customer_id as `customer`
from mall_order T0
where T0.vouch_date between ? and ?
limit 0,2
```

主数据查询结果

```json
[{
	"code": "DT201903121",
	"status": 7,
	"customer": 54785
}, {
	"code": "DT201903122",
	"status": 1,
	"customer": 51912
}]
```

Redis缓存查询

```shell
hmget customer 54785 51912
```

如果查询的结果数量少于预期个数，创建一个补充查询方案查询数据再补充缺少的数据。

```json
{
	"fields":[
		{"name":"*"}
	],
	"conditions":[
		{"op":"and","items":[
			{"name":"id","op":"in","v1":[54785,51912]}
		]}
	]
}
```

补充查询

```sql
select T0.mobile as `mobile`,T0.card as `card`,T0.address as `address`,T0.code as `code`,T0.name as `name`,T0.id as `id`,T0.create_time as `createTime`,T0.creator as `creator`,T0.modify_time as `modifyTime`,T0.modifier as `modifier`,T0.tenant_id as `tenant`
from cbo_customer T0
where T0.id in (54785,51912)
```

补充查询方案查询结果

```json
[
	{"mobile":"18910774786","card":"金卡","code":"54785","name":"买家54785","id":"54785","tenant":1001},
	{"mobile":"18910771913","card":"金卡","code":"51912","name":"买家51912","id":"51912","tenant":1001}
]
```

将查询数据补充到缓存中

```shell
hmset customer 54785 '{"mobile":"18910774786","card":"金卡","code":"54785","name":"买家54785","id":"54785","tenant":1001}' 51912 '{"mobile":"18910771913","card":"金卡","code":"51912","name":"买家51912","id":"51912","tenant":1001}'
```

将缓存查找出得数据与主数据合并，最终查询结果

```json
{
	"totalCount": 28760,
	"data": [{
		"code": "DT201903121",
		"status": 7,
		"customer": 54785,
		"customer_name": "买家54785"
	}, {
		"code": "DT201903122",
		"status": 1,
		"customer": 51912,
		"customer_name": "买家51912"
	}]
}
```

### 组合查询
查询方案

```json
{
  "fullname": "mall.order.Order",
  "fields": [
    {"name": "id"},
    {"name": "code"},
    {"name": "status"}
  ],
  "conditions": [
    {"name": "vouchDate", "op": "between", "v1": "current_date-3m/min", "v2": "current_date/max"}
  ],
  "pager": {"pageIndex":1, "pageSize": 2},
  "compositions": [
    {
      "name": "details",
      "fields": [
        {"name": "goods"},
        {"name": "qty"},
        {"name": "price"}
      ]
    }
  ]
}
```

查询树

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <Order>   [------] [L]
--QueryNode	: <Long> id id [S-----] [L]
--QueryNode	: <String> code code [S-----] [L]
--QueryNode	: <OrderStatus> status status [S-----] [L]
--QueryNode	: <Date> vouchDate  [--W---] [L]
```

查询总数

```sql
select count(1) as totalCount from (
select 1 as num
from mall_order T0
where T0.vouch_date between ? and ?
) t
```

分页查询主数据

```sql
select T0.id as `id`,T0.code as `code`,T0.status as `status`
from mall_order T0
where T0.vouch_date between ? and ?
limit 0,2
```

主数据查询结果

```json
[{
	"id": 1197123381367049,
	"code": "DT201903111",
	"status": 3
}, {
	"id": 1197123381383424,
	"code": "DT201903112",
	"status": 2
}]
```

组合查询方案根据主数据设置查询条件

```json
{
    "name":"details",
    "fields":[
        {"name":"goods","alias":"goods"},
        {"name":"qty","alias":"qty"},
        {"name":"price","alias":"price"},
        {"name":"order","alias":"order"}
    ],
    "conditions":[
        {"op":"and","items":[
            {"name":"order","op":"in","v1":[1197123381383424,1197123381367049]}
        ]}
    ]
}
```

查询树

```shell
# 格式：<类型> 名称 别名 [SJWGHO] [L/C/R]
# SJWGHO 分别为 Select Join Where Group Having Order
# L/C/R 分别为 Local/Cache/Remote
QueryNode	: <OrderDetail>   [------] [L]
--QueryNode	: <Goods> goods goods [S-----] [L]
--QueryNode	: <Decimal> qty qty [S-----] [L]
--QueryNode	: <Decimal> price price [S-----] [L]
--QueryNode	: <Order> order order [S-W---] [L]
```

组合查询方案查询

```sql
select T0.goods_id as `goods`,T0.qty as `qty`,T0.price as `price`,T0.order_id as `order`
from mall_order_detail T0
where T0.order_id in (?,?)
```

组合查询方案查询结果

```json
[{
	"goods": 3276,
	"qty": 1503.00,
	"price": 691.78,
	"order": 1197123381367049
}, {
	"goods": 1461,
	"qty": 87.00,
	"price": 308.58,
	"order": 1197123381367049
}, {
	"goods": 3745,
	"qty": 564.00,
	"price": 790.60,
	"order": 1197123381383424
}, {
	"goods": 3110,
	"qty": 3.00,
	"price": 656.59,
	"order": 1197123381383424
}]
```

根据组合路由映射关系整合主数据和组合查询数据（详细规则参考 [查询参考手册/组合查询/路由策略](https://github.com/jonathanzhao/imeta-started-guides/blob/master/query-reference.md) ）。<br/>
合并结果

```json
{
	"totalCount": 29749,
	"data": [{
		"id": 1197123381367049,
		"code": "DT201903111",
		"status": 3,
		"details": [{
			"goods": 3276,
			"qty": 1503.00,
			"price": 691.78,
			"order": 1197123381367049
		}, {
			"goods": 1461,
			"qty": 87.00,
			"price": 308.58,
			"order": 1197123381367049
		}]
	}, {
		"id": 1197123381383424,
		"code": "DT201903112",
		"status": 2,
		"details": [{
			"goods": 3745,
			"qty": 564.00,
			"price": 790.60,
			"order": 1197123381383424
		}, {
			"goods": 3110,
			"qty": 3.00,
			"price": 656.59,
			"order": 1197123381383424
		}]
	}]
}
```

借助组合查询方案，可以灵活实现很多功能：
- 查询效率提升：当需要关联查询的两个或多个数据表中数据量很大，关联查询会很慢，如果关联查询的字段不在条件、分组、排序、聚合函数中，可以将关联查询的字段构建成组合查询方案，这样查询总数、分页查询主数据时，均不会关联对应的数据库表。
- 分组查询topN：将组合查询方案的查询指令（directives）设置为topN（其中N为一个正整数，例如：top5），directives可以不断扩展（实现QueryResultFilter接口），默认有：list、first、last、topN、merge。
- 关联查询结果以树型结构形式呈现：递归设置组合查询方案。
- 自定义关联查询：通过设置组合查询方案的rel属性定义路由映射关系。

## 一些建议
- 不要在条件、Join、分组、排序中使用公式，不管是关系数据库还是No-Sql存储，查询条件中的公式都会极大降低查询效率。最好通过其它手段避免公式出现，例如冗余计算字段等。
- 查询条件最好不要跨域，会导致id in (...)的问题出现，当id过多时，查询会缓慢甚至失败。最好在查询前给定明确较小的（小于1000个）外键范围。
- 避免使用聚合函数(count、sum、max、min等)对原始数据进行汇总统计，最好通过ETL先加工再进行统计查询。数据仓库解决统计查询更为专业，统一查询服务也可以将数据仓库作为数据来源，前提是对数据仓库数据建模
  ![电子商城统计分析](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-stat.png "Mall Statistic Model")
- 通过查询模版功能，可以获得更加强大的公式解析功能。
