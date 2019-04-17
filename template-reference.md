# imeta 模版参考手册
## 简介
imeta 模版主要有两个功能：
1. 支持设计态根据元数据生成代码、Sql脚本、单元测试代码、帮助文档等。
2. 支持运行时渲染数据，类似themeleaf等模版引擎，将数据按照模版格式输出。
## 模版解析语法
- 名称(name)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/name.png "name")
- 变量表达式(variable_expr)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/variable_expr.png "name")
- 条件表达式(condition)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/condition.png "name")
- 表达式语句(expression)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/expression.png "name")
- 外部调用语句(bean)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/bean.png "name")
- 条件分支语句(subbranch)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/subbranch.png "name")
- 条件语句(branch)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/branch.png "name")
- 自定义函数语句(function)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/function.png "name")
- 循环语句(loop)<br/>
![name](https://raw.githubusercontent.com/jonathanzhao/imeta-started-guides/master/images/tpl/e/loop.png "name")

## 模版示例
### 代码生成
- 模版内容
```java
package <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>;

<#?(dependencies!=null && dependencies._size>0){#>
<#*(depComp:dependencies)?(name!="base.entity"){#>
import <#=NAME_SPACE#>.<#=moduleName#>.<#=name#>.*;
<#}#>

<#}#>
<#?(parent==null || parent.name == "BizObject"){#>
import org.imeta.context.biz.BizObject;

<#}#>
/**
 * <#=title#>实体
 *
 * @author <#=AUTHOR#>
 * @version <#=VERSION#>
 * @createTime <#=CURRENT_DATE#>
 */
public class <#@GenericNameBuilder#><#?{#><#:(parent!=null){#> extends <#@GenericInheritNameBuilder,this,parent#><#}#><#:{#> extends BizObject<#}#><#}#><#?(suppliers._size>0)#> implements <#*(supplier:suppliers){#> <#@GenericInheritNameBuilder,_super,this#><#?(IS_LAST!=true)#>,<#}#><#}#><#}#> {
	// 实体全称
	public static final String ENTITY_NAME = "<#=owner.moduleName#>.<#=owner.name#>.<#=name#>";

    /**
     * 获取实体全称
     *
     * @return 实体全称
     */
    @Override
    public String getEntityName() {
        return ENTITY_NAME;
    }

<#?(keyProperty!=null && keyProperty.name != "id"){#>
    /**
     * 获取主键名称
     *
     * @return 主键名称
     */
    @Override
    public String getKeyName() {
        return "<#=keyProperty.name#>";
    }

	/**
	 * 获取<#=keyProperty.title#>
	 *
	 * @return <#=keyProperty.title#>
	 */
	public <#/javatype(keyProperty)#> getId() {
		return get("<#=keyProperty.name#>");
	}

	/**
	 * 设置<#=keyProperty.title#>
	 *
	 * @param <#=keyProperty.name#> <#=keyProperty.title#>
	 */
	public void setId(<#/javatype(keyProperty)#> <#=keyProperty.name#>) {
		set("<#=keyProperty.name#>", <#=keyProperty.name#>);
	}

	/**
	 * 获取<#=keyProperty.title#>
	 *
	 * @return <#=keyProperty.title#>
	 */
	public <#/javatype(keyProperty)#> get<#/capital(keyProperty.name)#>() {
		return get("<#=keyProperty.name#>");
	}

	/**
	 * 设置<#=keyProperty.title#>
	 *
	 * @param <#=keyProperty.name#> <#=keyProperty.title#>
	 */
	public void set<#/capital(keyProperty.name)#>(<#/javatype(keyProperty)#> <#=keyProperty.name#>) {
		set("<#=keyProperty.name#>", <#=keyProperty.name#>);
	}

<#}#>
<#*(property:properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isKey!=true && isDerived!=true && isDependencyProperty!=true){#>
<#?{#>
<#:(type.m1Type == "Enum"){#>
    /**
     * 获取<#=title#>
     *
     * @return <#=title#>
     */
	public <#/javatype(this)#> get<#/capital(name)#>() {
		Object v = get("<#=name#>");
		return <#/javatype(this)#>.find(v);
	}

    /**
     * 设置<#=title#>
     *
     * @param <#=name#> <#=title#>
     */
	public void set<#/capital(name)#>(<#/javatype(this)#> <#=name#>) {
		if (<#=name#> != null) {
			set("<#=name#>", <#=name#>.getValue());
		} else {
			set("<#=name#>", null);
		}
	}

<#}#>
<#:{#>
    /**
     * 获取<#=title#>
     *
     * @return <#=title#>
     */
	public <#/javatype(this)#> get<#/capital(name)#>() {
	    <#?(type.m1Type in "Short,Byte,Boolean"){#>
	    return get<#=type.m1Type#>("<#=name#>");
	    <#}#>
        <#?(type.m1Type ~in "Short,Byte,Boolean"){#>
		return get("<#=name#>");
        <#}#>
	}

    /**
     * 设置<#=title#>
     *
     * @param <#=name#> <#=title#>
     */
	public void set<#/capital(name)#>(<#/javatype(this)#> <#=name#>) {
		set("<#=name#>", <#=name#>);
	}

<#}#>
<#}#>
<#}#>
<#*(property:properties)?(isAggregationProperty==true && isAggrChildRole==true){#>
<#?{#>
<#:(aggregation.isChildRoleCollection==false){#>
    /**
     * 获取<#=type.title#>
     *
     * @return <#=type.title#>
     */
	public <#=type.name#> <#=name#>() {
		return getBizObject("<#=name#>", <#=type.name#>.class);
	}

    /**
     * 设置<#=type.title#>
     *
     * @param <#=name#> <#=type.title#>
     */
	public void set<#/capital(name)#>(<#=type.name#> <#=name#>) {
		setBizObject("<#=name#>", <#=name#>);
	}

<#}#>
<#:{#>
    /**
     * 获取<#=type.title#>集合
     *
     * @return <#=type.title#>集合
     */
	public java.util.List<<#=type.name#>> <#=name#>() {
		return getBizObjects("<#=name#>", <#=type.name#>.class);
	}

    /**
     * 设置<#=type.title#>集合
     *
     * @param <#=name#> <#=type.title#>集合
     */
	public void set<#/capital(name)#>(java.util.List<<#=type.name#>> <#=name#>) {
		setBizObjects("<#=name#>", <#=name#>);
	}

<#}#>
<#}#>
<#}#>
}

```  
- 生成代码示例
```java
package org.imeta.sample.model.cbo.base;

import org.imeta.sample.model.base.itf.*;

/**
 * 树型档案实体
 *
 * @author zhaoyanfeng
 * @version 1.0
 * @createTime 2019-04-17
 */
public class TreeArchive extends Archive implements Tree<Long, String> {
	// 实体全称
	public static final String ENTITY_NAME = "cbo.base.TreeArchive";

    /**
     * 获取实体全称
     *
     * @return 实体全称
     */
    @Override
    public String getEntityName() {
        return ENTITY_NAME;
    }

    /**
     * 获取上级分类
     *
     * @return 上级分类
     */
	public Long getParent() {
		return get("parent");
	}

    /**
     * 设置上级分类
     *
     * @param parent 上级分类
     */
	public void setParent(Long parent) {
		set("parent", parent);
	}

    /**
     * 获取路径
     *
     * @return 路径
     */
	public String getPath() {
		return get("path");
	}

    /**
     * 设置路径
     *
     * @param path 路径
     */
	public void setPath(String path) {
		set("path", path);
	}

    // 此处省略一些属性

}
```
### 文档生成
- 模版内容
```html
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>类型属性文档</title>
<link href="../css/main.css" type="text/css" rel="stylesheet">
</head>
<body>
<div class="menu">
[<a href="../index.html">HOME</a>]
</div>
<h1 class="center">类型属性</h1>
<div class="layer1">
<div class="layer2 hence">
<h2 class="center"><#=title#>(<#=owner.moduleName#>.<#=owner.name#>.<#=name#>)</h2>
<#?(m1Type!="Enum"){#>
<div class="description">
<#?(parent!=null)#>继承&nbsp;<#@JavaTypeBuilder,parent#>&nbsp;<#}#><#?(suppliers._size>0)#>实现接口&nbsp;<#*(supplier:suppliers){#><#@JavaTypeBuilder#>&nbsp;<#}#><#}#><br/>
<#?(children._size>0)#>子类&nbsp;<#*(child:children){#><#@JavaTypeBuilder#>&nbsp;<#}#><#}#><#?(clients._size>0)#>实现子类&nbsp;<#*(client:clients){#><#@JavaTypeBuilder#>&nbsp;<#}#><#}#><br/>
<#?(tableName!=null){#>
<!--<span class="title w100">JSON示例：</span><a href="../../json/<#=owner.moduleName#>_<#=owner.name#>_<#=name#>.json"><#=name#></a>-->
<span class="title"><#?(isView==true){#>视图<#}#><#?(isView!=true){#>表名<#}#></span><#=tableName#>
<#}#>
</div>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>类型</th><th>标题</th><th>列名</th><th>特性</th><th>关系</th></tr>
</thead>
<tbody>
	 <#*(property:properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isDependencyProperty!=true) {#>
	 <tr><td><#=INDEX#></td><td><#=name#></td><td><#@JavaTypeBuilder#></td><td><#=title#></td><td><#?(modeType!="None")#><#=columnName#><#}#><#?(isKey==true){#> <strong>主键</strong><#}#><#?(isSyncKey==true){#> <strong>同步</strong><#}#></td><td><#?(isRequired==true){#> <strong>必输</strong><#}#><#?(isUnique==true){#> <strong>唯一</strong><#}#><#?(isPartition==true){#> <strong>隔离</strong><#}#></td><td><#?(isDependencyProperty==true){#> <strong class="hence2">虚拟</strong><#}#><#?(isDerived==true){#> <strong>继承</strong><#}#><#?(isImplemented==true){#> <strong>实现</strong><#}#><#?(isOverride==true){#> <strong>重写</strong><#}#><#?(isRedundant==true){#> <strong>冗余</strong><#}#></td></tr>
	 <#}#>
	 <#*(property:properties)?(isAggregationProperty==true && isAggrChildRole==true){#>
	 <tr><td><#=INDEX#></td><td><#=name#></td><td><#@JavaTypeBuilder#></td><td><#=type.title#></td><td><#?(modeType!="None")#><#=columnName#><#}#><#?(isKey==true){#> <strong>主键</strong><#}#><#?(isSyncKey==true){#> <strong>同步</strong><#}#></td><td><#?(isRequired==true){#> <strong>必输</strong><#}#><#?(isUnique==true){#> <strong>唯一</strong><#}#><#?(isPartition==true){#> <strong>隔离</strong><#}#></td><td><#?(isDependencyProperty==true){#> <strong class="hence2">虚拟</strong><#}#><#?(isDerived==true){#> <strong>继承</strong><#}#><#?(isImplemented==true){#> <strong>实现</strong><#}#><#?(isOverride==true){#> <strong>重写</strong><#}#><#?(isRedundant==true){#> <strong>冗余</strong><#}#> <strong>组合</strong></td></tr>
	 <#}#>
</tbody>
</table>
<#?(properties._eq(isDependencyProperty==true)._size>0){#>
<p class="referenced">被引用（被其他实体关联）</p>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>类型</th><th>标题</th><th>列名</th><th>特性</th><th>关系</th></tr>
</thead>
<tbody>
	 <#*(property:properties)?(isDependencyProperty==true){#>
	 <tr><td><#=INDEX#></td><td><#=name#></td><td><#@JavaTypeBuilder#></td><td><#=title#></td><td></td><td></td><td><#?(isDependencyProperty==true){#> <strong class="hence2">虚拟</strong><#}#><#?(isDerived==true){#> <strong>继承</strong><#}#><#?(isImplemented==true){#> <strong>实现</strong><#}#><#?(isOverride==true){#> <strong>重写</strong><#}#></td></tr>
	 <#}#>
</tbody>
</table>
<#}#>
<#}#>
<#?(m1Type=="Enum"){#>
<table class="table-5">
<thead>
<tr><th>名称</th><th>枚举项</th><th>枚举值</th></tr>
</thead>
<tbody>
	 <#*(literal:literals){#>
	 <tr><td><#=name#></td><td><#=title#></td><td><#=value#></td></tr>
	 <#}#>
</tbody>
</table>
<#}#>
</div>
</div>
</body>
</html>
```
- 生成文档示例
```html
<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>类型属性文档</title>
<link href="../css/main.css" type="text/css" rel="stylesheet">
</head>
<body>
<div class="menu">
[<a href="../index.html">HOME</a>]
</div>
<h1 class="center">类型属性</h1>
<div class="layer1">
<div class="layer2 hence">
<h2 class="center">商品(cbo.product.Product)</h2>
<div class="description">
继承&nbsp;<a href="cbo_base_Archive.html">Archive</a>&nbsp;<br/>
<br/>
<!--<span class="title w100">JSON示例：</span><a href="../../json/cbo_product_Product.json">Product</a>-->
<span class="title">表名</span>cbo_product
</div>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>类型</th><th>标题</th><th>列名</th><th>特性</th><th>关系</th></tr>
</thead>
<tbody>
	 <tr><td>1</td><td>cate</td><td><a href="cbo_product_ProductCate.html">ProductCate</a></td><td>商品分类</td><td>cate_id</td><td> <strong>必输</strong></td><td></td></tr>
	 <tr><td>2</td><td>markPrice</td><td>java.math.BigDecimal</td><td>标价</td><td>mark_price</td><td></td><td></td></tr>
	 <tr><td>3</td><td>salePrice</td><td>java.math.BigDecimal</td><td>售价</td><td>sale_price</td><td></td><td></td></tr>
	 <tr><td>4</td><td>brand</td><td>String</td><td>品牌</td><td>brand</td><td></td><td></td></tr>
	 <tr><td>5</td><td>unit</td><td>String</td><td>单位</td><td>unit</td><td></td><td></td></tr>
	 <tr><td>6</td><td>barcode</td><td>String</td><td>条形码</td><td>barcode</td><td></td><td></td></tr>
	 <tr><td>7</td><td>imgUrl</td><td>String</td><td>图片地址</td><td>img_url</td><td></td><td></td></tr>
	 <tr><td>8</td><td>code</td><td>String</td><td>编码</td><td>code</td><td> <strong>唯一</strong></td><td> <strong>继承</strong></td></tr>
	 <tr><td>9</td><td>name</td><td>String</td><td>名称</td><td>name</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>10</td><td>id</td><td>Long</td><td>ID</td><td>id</td><td><strong>主键</strong></td><td> <strong>继承</strong></td></tr>
	 <tr><td>11</td><td>pubts</td><td>java.util.Date</td><td>时间戳</td><td>pubts <strong>同步</strong></td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>12</td><td>tenant</td><td>Long</td><td>租户</td><td>tenant_id</td><td> <strong>必输</strong> <strong>隔离</strong></td><td> <strong>继承</strong></td></tr>
	 <tr><td>13</td><td>createTime</td><td>java.util.Date</td><td>创建时间</td><td>create_time</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>14</td><td>createDate</td><td>java.util.Date</td><td>创建日期</td><td>create_date</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>15</td><td>modifyTime</td><td>java.util.Date</td><td>修改时间</td><td>modify_time</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>16</td><td>modifyDate</td><td>java.util.Date</td><td>修改日期</td><td>modify_date</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>17</td><td>creator</td><td>String</td><td>创建人</td><td>creator</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>18</td><td>modifier</td><td>String</td><td>修改人</td><td>modifier</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>19</td><td>isAvailable</td><td>Boolean</td><td>是否可用</td><td>is_available</td><td></td><td> <strong>继承</strong></td></tr>
	 <tr><td>1</td><td>skues</td><td>List&lt;<a href="cbo_product_ProductSKU.html">ProductSKU</a>&gt;</td><td>SKU</td><td></td><td></td><td> <strong>组合</strong></td></tr>
	 <tr><td>2</td><td>tags</td><td>List&lt;<a href="cbo_product_ProductTag.html">ProductTag</a>&gt;</td><td>商品标签</td><td></td><td></td><td> <strong>组合</strong></td></tr>
</tbody>
</table>
<p class="referenced">被引用（被其他实体关联）</p>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>类型</th><th>标题</th><th>列名</th><th>特性</th><th>关系</th></tr>
</thead>
<tbody>
	 <tr><td>1</td><td>stock_product_CurrentStock</td><td><a href="stock_currentstock_CurrentStock.html">CurrentStock</a></td><td>现存量</td><td></td><td></td><td> <strong class="hence2">虚拟</strong></td></tr>
	 <tr><td>2</td><td>sm_product_SaleOrderDetail</td><td><a href="sm_so_SaleOrderDetail.html">SaleOrderDetail</a></td><td>销售订单明细</td><td></td><td></td><td> <strong class="hence2">虚拟</strong></td></tr>
</tbody>
</table>
</div>
</div>
</body>
</html>
```
- 预览效果<br/>
**商品(cbo.product.Product)**<br/>
继承 [Archive]()<br/>
表名 cbo_product

|序号|名称|类型|标题|列名|特性|关系|
|---|---|---|---|---|---|---|
|1|cate|[ProductCate]('#')|商品分类|cate_id|必输||
|2|markPrice|java.math.BigDecimal|标价|mark_price|||
|3|salePrice|java.math.BigDecimal|售价|sale_price|||
|4|brand|String|品牌|brand|||
|5|unit|String|单位|unit|||
|6|barcode|String|条形码|barcode|||
|7|imgUrl|String|图片地址|img_url|||
|8|code|String|编码|code|唯一|继承|
|9|name|String|名称|name||继承|
|10|id|Long|ID|id|**主键**|继承|
|11|pubts|java.util.Date|时间戳|pubts 同步||继承|
|12|tenant|Long|租户|tenant_id|必输 隔离|继承|
|13|createTime|java.util.Date|创建时间|create_time||继承|
|14|createDate|java.util.Date|创建日期|create_date||继承|
|15|modifyTime|java.util.Date|修改时间|modify_time||继承|
|16|modifyDate|java.util.Date|修改日期|modify_date||继承|
|17|creator|String|创建人|creator||继承|
|18|modifier|String|修改人|modifier||继承|
|19|isAvailable|Boolean|是否可用|is_available||继承|
|1|skues|List<[ProductSKU]('#')>|SKU|||组合|
|2|tags|List<[ProductTag]('#')>|商品标签|||组合|
---
被引用（被其他实体关联）

|序号|名称|类型|标题|列名|特性|关系|
|---|---|---|---|---|---|---|
|1|stock_product_CurrentStock|[CurrentStock]('#')|现存量|||虚拟|
|2|sm_product_SaleOrderDetail|[SaleOrderDetail]('#')|销售订单明细|||虚拟|

### 数据渲染
- 模版内容
```java
{
    "success": true,
    "msg": "success",
    "status": 200,
    "data": {
        "goodsTotalCount": <#=totalProductQty.data[0].totalProductQty#>,
        "goodsMonthCount": <#=newProductQty.data[0].newProductQty#>,
        "goodsClassTotalCount": <#=productSummary.data[0].totalProductClassQty#>,
        "tradeTotalCountToB": <#=2bUdhTotal.data[0].totalOrderQty#>,
        "tradeMonthCountToB": <#=2bUdhNew.data[0].newOrderQty#>,
        "tradeTotalCountToC": <#/iadd(2cMallTotal.data[0].totalOrderQty, 2cRetailTotal.data[0].totalOrderQty)#>,
        "tradeMonthCountToC": <#/iadd(2cMallNew.data[0].newOrderQty, 2cRetailNew.data[0].newOrderQty)#>,
        "tradeTotalMoneyToB": <#=2bUdhTotal.data[0].totalOrderMoney#>,
        "tradeMonthMoneyToB": <#=2bUdhNew.data[0].newOrderMoney#>,
        "tradeTotalMoneyToC": <#/add(2cMallTotal.data[0].totalOrderMoney, 2cRetailTotal.data[0].totalOrderMoney)#>,
        "tradeMonthMoneyToC": <#/add(2cMallNew.data[0].newOrderMoney, 2cRetailNew.data[0].newOrderMoney)#>,
        "memberMonthCount": <#=newMemberQty.data[0].newMemberQty#>,
        "memberTotalCount": <#=totalMemberQty.data[0].totalMemberQty#>,
        "goodsGrowth": {
            "xAxis": {
                "data": [
                <#?(monthProductQty.totalCount>0){#>
                <#*(d:monthProductQty.data){#>
                   <#=monthProductQty#><#?(IS_LAST!=true)#>,<#}#>
                <#}#>

                <#}#>
                ]
            },
            "series": [
                {
                    "data": [
                        <#?(monthProductQty.totalCount>0){#>
                        <#*(d:monthProductQty.data){#>
                           "<#=yearMouth#>"<#?(IS_LAST!=true)#>,<#}#>
                        <#}#>

                        <#}#>
                    ],
                    "name": "商品增长量"
                }
            ],
            "name": "商品增长量"
        }
    }
}
```
- 聚合查询原始数据
```json
{
    "flag": 1,
    "success": true,
    "msg": "查询成功",
    "status": 200,
    "totalCount": "12",
    "data": {
        "2bUdhTotal": {
            "flag": 1,
            "data": [
                {
                    "totalOrderQty": 4010542,
                    "totalOrderMoney": 55229442657.15
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "totalProductQty": {
            "flag": 1,
            "data": [
                {
                    "totalProductQty": 158402
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "2cMallTotal": {
            "flag": 1,
            "data": [
                {
                    "totalOrderQty": 508850,
                    "totalOrderMoney": 459948772.6
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "newProductQty": {
            "flag": 1,
            "data": [
                {
                    "newProductQty": 20151
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "2cMallNew": {
            "flag": 1,
            "data": [
                {
                    "newOrderQty": 21007,
                    "newOrderMoney": 12658603.76
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "2cRetailTotal": {
            "flag": 1,
            "data": [
                {
                    "totalOrderQty": 358682,
                    "totalOrderMoney": 1042507645.01
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "newMemberQty": {
            "flag": 1,
            "data": [
                {
                    "newMemberQty": 132697
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "2cRetailNew": {
            "flag": 1,
            "data": [
                {
                    "newOrderQty": 75880,
                    "newOrderMoney": 21222540.01
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "productSummary": {
            "flag": 1,
            "data": [
                {
                    "totalProductClassQty": 12685
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "2bUdhNew": {
            "flag": 1,
            "data": [
                {
                    "newOrderQty": 273547,
                    "newOrderMoney": 2751528332.56
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "totalMemberQty": {
            "flag": 1,
            "data": [
                {
                    "totalMemberQty": 4106909
                }
            ],
            "totalCount": 1,
            "status": 200
        },
        "monthProductQty": {
            "flag": 1,
            "data": [
                {
                    "monthProductQty": 1884,
                    "yearMouth": "2018-05月"
                },
                {
                    "monthProductQty": 18353,
                    "yearMouth": "2018-06月"
                },
                {
                    "monthProductQty": 5249,
                    "yearMouth": "2018-07月"
                },
                {
                    "monthProductQty": 9872,
                    "yearMouth": "2018-08月"
                },
                {
                    "monthProductQty": 11997,
                    "yearMouth": "2018-09月"
                },
                {
                    "monthProductQty": 6800,
                    "yearMouth": "2018-10月"
                },
                {
                    "monthProductQty": 7781,
                    "yearMouth": "2018-11月"
                },
                {
                    "monthProductQty": 21391,
                    "yearMouth": "2018-12月"
                },
                {
                    "monthProductQty": 5032,
                    "yearMouth": "2019-01月"
                },
                {
                    "monthProductQty": 7250,
                    "yearMouth": "2019-02月"
                },
                {
                    "monthProductQty": 16404,
                    "yearMouth": "2019-03月"
                },
                {
                    "monthProductQty": 7150,
                    "yearMouth": "2019-04月"
                }
            ],
            "totalCount": 12,
            "status": 200
        }
    }
}
```

- 查询数据渲染结果
```json
{
    "success": true,
    "msg": "success",
    "status": 200,
    "data": {
        "goodsTotalCount": 158402,
        "goodsMonthCount": 20151,
        "goodsClassTotalCount": 12685,
        "tradeTotalCountToB": 4010542,
        "tradeMonthCountToB": 273547,
        "tradeTotalCountToC": 867532,
        "tradeMonthCountToC": 96887,
        "tradeTotalMoneyToB": 55229442657.15,
        "tradeMonthMoneyToB": 2751528332.56,
        "tradeTotalMoneyToC": 1502456417.61,
        "tradeMonthMoneyToC": 33881143.77,
        "memberMonthCount": 132697,
        "memberTotalCount": 4106909,
        "goodsGrowth": {
            "xAxis": {
                "data": [
                    1884,
                    18353,
                    5249,
                    9872,
                    11997,
                    6800,
                    7781,
                    21391,
                    5032,
                    7250,
                    16404,
                    7150
                ]
            },
            "series": [
                {
                    "data": [
                        "2018-05月",
                        "2018-06月",
                        "2018-07月",
                        "2018-08月",
                        "2018-09月",
                        "2018-10月",
                        "2018-11月",
                        "2018-12月",
                        "2019-01月",
                        "2019-02月",
                        "2019-03月",
                        "2019-04月"
                    ],
                    "name": "商品增长量"
                }
            ],
            "name": "商品增长量"
        }
    }
}
```
