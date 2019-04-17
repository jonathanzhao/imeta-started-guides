# imeta 模版参考手册
## 简介
imeta 模版支持设计态根据元数据生成代码、Sql脚本、单元测试代码、帮助文档等；还支持运行时格式化数据，类似themeleaf等模版引擎的功能。
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
### 数据格式化
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

- 查询结果模版格式化
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
