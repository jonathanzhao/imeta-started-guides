# iMeta Framework Boot-Starter 参考手册
iMeta是一个基于JAVA语言开发的模型驱动（MDD）开发框架，以元数据为基础，与微服务架构（Micro-Services）天然融合，配置文件为主要开发方式，适用于以关系数据库和No-Sql数据库为数据存储介质、以数据查询、持久化为主要操作方式、面向微服务的、部署在云（Cloud）中的应用程序。

Boot-Stareter基于config>coding的开发模式，可以零JAVA代码快速构建微服务应用程序。
## 商城演示模型
- 包
![电子商城包](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-package.png "Mall Design Model")
- 类图
![电子商城类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall.png "Mall Design Model")
- 统计分析
![电子商城统计分析类图](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/imeta/e/mall-stat.png "Mall Statistic Model")

- 用户模型中的静态类图可以认为是iMeta的原材料。
- 用户模型通常包含以下几个UML元素：包、类、属性、关系，关系有继承、实现、关联、组合。用户模型与元数据映射关系：

    |用户模型|元数据模型|示例|
    |---|---|---|
    | 包 | Component | order,goods |
    | 包间依赖 | Component.dependencies | |
    | 基本类型 | DataType | Integer,DateTime,String |
    | 枚举类型 | Enumeration | OrderStatus |
    | 实体 | Entity | Order,OderDetail,Goods |
    | 接口 | Interface | Code,Autditable |
    | 组合关系 | Association | Order -> OrderDetail |
    | 关联关系 | Association | OrderDetail -> Goods |
    | 继承关系 | Generalization| Goods -> Archive |
    |实现关系|Realization| OrderBase -> Auditable |
    |属性|Property|code,details,createTime|
    |方法|Operation||
    |方法参数|Parameter||
- iMeta结合数据仓库模型，能够提供极为灵活的统计查询。

## 应用开发过程
1. 使用元数据描述用户模型
2. 配置查询方案
3. 配置导入导出模版
4. 配置数据库、Redis密码等
5. 运行应用程序

### 配置元数据
商城演示模型转换为元数据，将包转换为component，将类和属性转换为class和property，将继承、实现、组合关系转换为generalization、realization和aggregation，请查看[商城演示模型完整元数据](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/configs/mall-metadata.md)。

*注：可以通过调用api动态刷新运行期元数据缓存。*

- 商品元数据示例
```xml
<component name="goods" title="商品组件" moduleName="cbo" domain="goods">
    <class name="GoodsCate" title="商品分类" tableName="cbo_goods_cate" service="cache:redis://1?key=goods-cate&amp;subKey=id&amp;type=json">
        <properties>
            <property name="parent" title="上级" type="GoodsCate" />
        </properties>
    </class>
    <class name="Goods" title="商品" tableName="cbo_goods" service="cache:redis://1?key=goods&amp;subKey=id&amp;type=json">
        <properties>
            <property name="cate" columnName="cate_id" title="商品分类" type="GoodsCate" isRequired="true"/>
            <property name="price" title="价格" type="Decimal" precision="12" scale="2"/>
        </properties>
    </class>
    <class name="GoodsDescription" title="商品描述" tableName="cbo_goods_description">
        <properties>
            <property name="goods" columnName="goods_id" title="商品" type="Goods" isKey="true"/>
            <property name="text" title="描述内容" type="Text" isGlobalization="true" />
        </properties>
    </class>
    <class name="Sku" title="Sku" tableName="cbo_sku" service="cache:redis://1?key=sku&amp;subKey=id&amp;type=json">
        <properties>
            <property name="goods" columnName="goods_id" title="商品" type="Goods" isRequired="true"/>
            <property name="price" title="价格" type="Decimal" precision="12" scale="2"/>
            <property name="spec1" title="规格1" type="String" length="50" />
            <property name="value1" title="规格值1" type="String" length="50" />
            <property name="spec2" title="规格2" type="String" length="50" />
            <property name="value2" title="规格值2" type="String" length="50" />
            <property name="spec3" title="规格3" type="String" length="50" />
            <property name="value3" title="规格值3" type="String" length="50" />
        </properties>
    </class>
    <generalizations>
        <generalization parent="base.entity.Archive" child="GoodsCate"/>
        <generalization parent="base.entity.Archive" child="Goods"/>
        <generalization parent="base.entity.Archive" child="Sku"/>
    </generalizations>
    <realizations>
        <realization supplier="base.itf.Tree" client="GoodsCate"/>
        <realization supplier="base.itf.BarCode" client="Goods"/>
        <realization supplier="base.itf.BarCode" client="Sku"/>
    </realizations>
    <aggregations>
        <aggregation type="composition" parentRole="goods" aggrParent="Goods" childRole="skues" aggrChild="Sku" childRoleMulti="ZeroToMany"/>
        <aggregation type="composition" parentRole="goods" aggrParent="Goods" childRole="description" aggrChild="GoodsDescription" childRoleMulti="ZeroToOne"/>
    </aggregations>
</component>
```
### 配置查询方案
查询方案有三种来源：
1. 完全通过参数传入，这种方式最灵活，但调用方需要了解更多模型细节。
2. 使用预先配置缓存好的查询方案，查询条件不易更改，调用方需要了解较少模型细节。
3. 使用预先配置缓存好的查询方案+参数传入的查询条件，这种方式也很灵活，调用方需要了解一些模型细节。

*注：可以通过调用api动态刷新运行期查询方案缓存。*

了解更多查询方案内容[查询方案参考手册](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/query-reference.md)。
> 查询方案示例
```json
{
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
}
```
### 配置导入导出模版
可以通过简单配置，实现Excel等导入导出功能。

*注：可以通过调用api动态刷新运行期模版缓存。*
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
> 导出母版示例

![订单母版](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/f/mall-package.jpg)
> 导出结果示例

![订单导出](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/f/mall-package.jpg)

## 商城演示安装步骤
1. 下载部署程序
假设在路径/data/release下执行
```bash
git clone https://github.com/jonathanzhao/imeta-boot-starter-service.git mall
```
2. 导入演示数据库
```bash
cd /data/release/mall/data
tar xzvf mall.sql.zip
mysql --max_allowed_packet=16777216 --net_buffer_length=16384 -u'数据库用户名' -p'数据库密码' -h'数据库服务器地址' 数据库名 < mall.sql
```
3. 启动应用程序
```bash
cd /data/release/mall
# extend/lib/*中为扩展jar包，登录等扩展功能在此jar包中。
# service/lib/*中为boot-starter依赖jar包
java -cp .:extend/lib/*:service/lib/*:service/* \
-Dfile.encoding=utf-8 \
-Dport=9001 \
-Dstatic.path=file:/data/release/mall/configs \
-Ddb.host=数据库服务器地址 \
-Ddb.port=数据库端口号 \
-Ddb.username=数据库用户名 \
-Ddb.pwd=数据库密码 \
-Ddb.database=数据库名称 \
-Dredis.pwd=Redis密码 \
-Dredis.db=Redis数据库编号 \
-Dauth.enabled=true \
-Dcors.enabled=true \
-Dapi.skip.check=true \
-Dauth.session.id=mallsessionid \
-Dapi.header.key=X-MALL-TOKEN \
org.imeta.boot.starter.service.BootStarterServiceApplication \
> mall.service.log &
```
