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
