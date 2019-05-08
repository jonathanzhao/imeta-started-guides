# 商城演示模型元数据Metadata
Metadata是用户模型的数据表示，本文中为商城演示模型的完整元数据。
## 基础
基础元数据为所有用户模型共用。
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/schema/tool/imeta-2.0.xsd">
    <references/>
    <component name="lang" moduleName="java" title="系统类型组件">
        <datatype name="Integer" title="整数" m1Type="Integer" />
        <datatype name="Byte" title="字节" m1Type="Byte" />
        <datatype name="Short" title="短整数" m1Type="Short" />
        <datatype name="Long" title="长整数" m1Type="Long" />
        <datatype name="Decimal" title="十进制数" m1Type="Decimal" />
        <datatype name="Boolean" title="布尔" m1Type="Boolean" />
        <datatype name="Date" title="日期" m1Type="Date" />
        <datatype name="DateTime" title="日期时间" m1Type="Date" />
        <datatype name="Time" title="时间" m1Type="String" />
        <datatype name="IntDate" title="日期" m1Type="IntDate" />
        <datatype name="IntDateTime" title="日期时间" m1Type="IntDate" />
        <datatype name="String" title="字符串" m1Type="String" />
        <datatype name="Text" title="文本" m1Type="String" />
        <datatype name="Binary" title="二进制" m1Type="Bin" />
        <datatype name="T" title="泛型1" m1Type="Generic" />
        <datatype name="U" title="泛型2" m1Type="Generic" />
        <datatype name="V" title="泛型3" m1Type="Generic" />
        <datatype name="R" title="泛型4" m1Type="Generic" />
    </component>
</components>
```
## 公共
公共元数据是从用户模型中抽象出来的通用结构，一般包括接口、基类。
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
    </references>
    <!--common interfaces-->
    <component name="itf" moduleName="base" title="通用接口">
        <interface name="Audit" title="审计信息">
            <properties>
                <property name="createTime" columnName="create_time" title="创建时间" type="DateTime" modeType="Insert"/>
                <property name="creator" columnName="creator" title="创建人" type="String" length="50" modeType="Insert"/>
                <property name="modifyTime" columnName="modify_time" title="修改时间" type="DateTime" modeType="Update"/>
                <property name="modifier" columnName="modifier" title="修改人" type="String"  length="50" modeType="Update"/>
            </properties>
        </interface>
        <interface name="AutoCode" title="自动编号">
            <properties>
                <property name="code" columnName="code" title="编号" type="String" length="50" isRequired="true"/>
            </properties>
        </interface>
        <interface name="BarCode" title="条码">
            <properties>
                <property name="barCode" columnName="barcode" title="条码" type="String" length="20"/>
            </properties>
        </interface>
        <interface name="Tree" title="树型结构">
            <properties>
                <property name="parent" title="上级" type="T" columnName="parent_id" />
                <property name="level" title="级别" type="Integer" />
                <property name="path" title="路径" type="String" length="255" />
                <property name="isEnd" title="是否末级" type="Boolean" columnName="is_end" defaultValue="false" />
            </properties>
        </interface>
    </component>
    <!--base classes-->
    <component name="entity" title="通用基类" moduleName="base">
        <!--root entity-->
        <class name="BizObject" title="基类">
            <properties>
                <property name="id" title="ID" type="Long" isKey="true"/>
                <!--<property name="pubts" columnName="pubts" title="时间戳" type="DateTime" isSyncKey="true"/>-->
            </properties>
        </class>
        <class name="Archive" title="档案基类">
            <properties>
                <property name="code" columnName="code" title="编码" type="String" length="20" isCode="true" isRequired="true" isUnique="true"/>
                <property name="name" columnName="name" title="名称" type="String" length="20" isName="true" isGlobalization="true" isRequired="true"/>
            </properties>
        </class>
        <class name="Vouch" title="单据基类">
            <properties>
                <property name="vouchDate" columnName="vouch_date" title="制单日期" type="Date" isRequired="true"/>
            </properties>
        </class>
        <generalizations>
            <generalization parent="BizObject" child="Archive" />
            <generalization parent="BizObject" child="Vouch" />
        </generalizations>
        <realizations>
            <realization supplier="base.itf.Audit" client="Archive" />
            <realization supplier="base.itf.Audit" client="Vouch" />
            <realization supplier="base.itf.AutoCode" client="Vouch" />
        </realizations>
    </component>
</components>
```
## 客户
可以继承基类、实现接口，精简实体结构，还能方便编写统一处理程序。
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
        <reference file="base.xml"/>
    </references>
    <component name="customer" title="客户" moduleName="cbo" domain="customer">
        <class name="Customer" title="客户" tableName="cbo_customer">
            <properties>
                <property name="mobile" title="手机" type="String" length="20" isRequired="true" validate="phone" />
                <property name="card" title="会员卡" type="String" length="20" />
                <property name="address" title="地址" type="String" length="200" />
            </properties>
        </class>
        <generalizations>
            <generalization parent="base.entity.Archive" child="Customer" />
        </generalizations>
    </component>
</components>
```
## 商品
可以继承基类、实现接口，精简实体结构，还能方便编写统一处理程序。
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
        <reference file="base.xml"/>
    </references>
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
</components>
```
## 订单
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
        <reference file="base.xml"/>
        <reference file="customer.xml"/>
        <reference file="goods.xml"/>
    </references>
    <component name="order" moduleName="mall" title="订单组件" domain="order">
        <enum name="OrderStatus" title="单据状态" m1Type="Integer">
            <literal name="Paying" title="待支付" value="1" />
            <literal name="Conforming" title="已付款，待确认" value="2" />
            <literal name="Paid" title="已付款" value="3" />
            <literal name="Preparing" title="配货中" value="4" />
            <literal name="Prepared" title="配货完成，待发货" value="5" />
            <literal name="Shipping" title="已发货" value="6" />
            <literal name="Received" title="已收货" value="7" />
            <literal name="AutoComplete" title="已完成" value="8" />
            <literal name="Canceled" title="已取消" value="9" />
            <literal name="COD" title="货到付款" value="10" />
        </enum>
        <class name="Order" title="订单" tableName="mall_order">
            <properties>
                <property name="totalMoney" columnName="total_money" title="总金额" type="Decimal" precision="12" scale="2"/>
                <!--<property name="orderTime" columnName="order_time" title="下单时间" type="DateTime" isRequired="true"/>-->
                <property name="status" title="单据状态" type="OrderStatus" defaultValue="1" isRequired="true" />
                <property name="customer" columnName="customer_id" title="客户" type="cbo.customer.Customer" isRequired="true" />
            </properties>
        </class>
        <class name="OrderDetail" title="订单明细" tableName="mall_order_detail">
            <properties>
                <property name="order" columnName="order_id" title="订单" type="Order" isRequired="true"/>
                <property name="goodsCate" columnName="goods_cate_id" title="商品分类" type="cbo.goods.GoodsCate" isRequired="true" />
                <property name="goods" columnName="goods_id" title="商品" type="cbo.goods.Goods" isRequired="true" />
                <property name="sku" columnName="sku_id" title="SKU" type="cbo.goods.Sku" isRequired="true"/>
                <property name="qty" title="数量" type="Decimal" precision="12" scale="2"/>
                <property name="price" title="单价" type="Decimal" precision="12" scale="2"/>
            </properties>
        </class>
        <class name="OrderLogistics" title="订单物流" tableName="mall_order_logistics">
            <properties>
                <property name="order" columnName="order_id" title="订单" type="Order" isRequired="true"/>
                <property name="shipTime" columnName="ship_Time" title="发货时间" type="DateTime" isRequired="true"/>
                <property name="site" columnName="site" title="地点" type="String" length="100" isRequired="true"/>
            </properties>
        </class>
        <class name="OrderLogisticsAction" title="订单物流操作记录" tableName="mall_order_logistics_action">
            <properties>
                <property name="order" columnName="order_id" title="订单" type="Order" isRequired="true" isRedundant="true"/>
                <property name="logistics" columnName="logistics_id" title="订单物流" type="OrderLogistics" isRequired="true"/>
                <property name="action" title="操作记录" type="String" length="100" isRequired="true"/>
                <property name="user" title="负责人" type="String" length="50" isRequired="true"/>
            </properties>
        </class>
        <generalizations>
            <generalization parent="base.entity.Vouch" child="Order"/>
            <generalization parent="base.entity.BizObject" child="OrderDetail"/>
            <generalization parent="base.entity.BizObject" child="OrderLogistics"/>
            <generalization parent="base.entity.BizObject" child="OrderLogisticsAction"/>
        </generalizations>
        <aggregations>
            <aggregation type="composition" parentRole="order" aggrParent="Order" childRole="details" aggrChild="OrderDetail"
                         childRoleMulti="OneToMany"/>
            <aggregation type="composition" parentRole="order" aggrParent="Order" childRole="logistics" aggrChild="OrderLogistics"
                         childRoleMulti="ZeroToMany"/>
            <aggregation type="composition" parentRole="logistics" aggrParent="OrderLogistics" childRole="actions"
                         aggrChild="OrderLogisticsAction" childRoleMulti="ZeroToMany"/>
        </aggregations>
    </component>
</components>
```
## 统计
基于数据仓库思路设计统计模型，将业务表预先汇总到事实表，可以大幅减少的数据量，通过与维度表的关联，可以高效灵活的按照各种维度进行统计。
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
        <reference file="base.xml"/>
        <reference file="customer.xml"/>
        <reference file="goods.xml"/>
    </references>
    <component name="stat" moduleName="mall" title="订单组件" domain="stat">
        <class name="RegionDim" title="地区纬" tableName="dim_region">
            <properties>
                <property name="id" title="ID" type="Long" isKey="true" />
                <property name="nation" title="国家/地区" type="String" length="50" />
                <property name="province" title="省/地区" type="String" length="50" />
                <property name="city" title="市" type="String" length="50" />
            </properties>
        </class>
        <class name="DateDim" title="时间纬" tableName="dim_date">
            <properties>
                <property name="d" title="日期" type="Date" isKey="true" />
                <property name="year" title="年" type="Integer" isRequired="true" />
                <property name="month" title="月" type="Integer" isRequired="true" />
                <property name="day" title="日" type="Integer" isRequired="true" />
                <property name="week" title="周" type="Integer" isRequired="true" />
                <property name="quarter" title="季度" type="Integer" isRequired="true" />
            </properties>
        </class>
        <class name="OrderDailyActive" title="订单" tableName="stat_order_daily">
            <properties>
                <property name="goodsQty" columnName="goods_qty" title="商品数量" type="Decimal" precision="19" scale="2"/>
                <property name="orderQty" columnName="order_qty" title="下单数量" type="Integer" />
                <property name="orderMoney" columnName="order_money" title="订单金额" type="Decimal" precision="19" scale="2"/>
                <property name="statTime" columnName="stat_time" title="统计时间" type="DateDim"/>
                <property name="goodsCate" columnName="goods_cate_id" title="商品分类" type="cbo.goods.GoodsCate" />
                <property name="region" columnName="region" title="下单地区" type="RegionDim"/>
            </properties>
        </class>
        <generalizations>
            <generalization parent="base.entity.BizObject" child="OrderDailyActive"/>
        </generalizations>
    </component>
</components>
```
## 用户权限
可以根据业务需要，创建用户、功能权限、数据权限等元数据。
### 用户
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
    </references>
    <!--user-->
    <component name="user" moduleName="base" title="用户">
        <class name="User" title="用户" tableName="user">
            <properties>
                <property name="username" title="用户名" type="String" length="50" isKey="true" />
                <property name="password" title="密码" type="String" length="50" />
                <property name="salt" title="盐" type="String" length="20" />
                <property name="name" title="姓名" type="String" length="50" />
                <property name="userType" title="用户类型" type="Integer" defaultValue="2" />
                <property name="mobile" title="手机号" type="String" length="50" validate="phone" />
                <property name="email" title="邮箱" type="String" length="255" validate="email" />
                <property name="avatar" title="头像" type="String" length="255" />
            </properties>
        </class>
    </component>
</components>
```
### 数据权限
```xml
<?xml version="1.0" encoding="utf-8"?>
<components xmlns="http://www.imeta.org/meta"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.imeta.org/meta http://www.imeta.org/meta/meta.xsd">
    <references>
        <reference file="java.xml"/>
        <reference file="base.xml"/>
    </references>
    <component name="auth" title="权限组件" moduleName="base">
        <class name="DataAuth" title="数据权限" tableName="base_data_auth">
            <properties>
                <property name="type" title="类型" type="String" length="20" isRequired="true" />
                <property name="role" title="角色" type="String" length="20" isRequired="true" />
                <property name="key" columnName="obj_id" title="业务主键" type="Long" isRequired="true" />
            </properties>
        </class>
        <generalizations>
            <generalization parent="base.entity.BizObject" child="DataAuth"/>
        </generalizations>
    </component>
</components>
```