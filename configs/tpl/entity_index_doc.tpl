<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>类型文档</title>
<link href="css/main.css" type="text/css" rel="stylesheet">
</head>
<body>
<div class="menu">
[<a href="api.html">API</a>]
</div>
<h1 class="center">类型</h1>
<#*(component:components){#>
<#?(dataTypes._size>0 || classes._size>0){#>
<div class="layer1">
<div class="layer2 hence">
<h2 class="center"><#=title#>(<#/capital(name)#>)</h2>
<#?((dataTypes!=null) && (dataTypes._size>0)){#>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>标题</th><th>类型</th><th></th></tr>
</thead>
<tbody>
	 <#*(dataType:dataTypes)?(m1Type=="Enum"){#>
	 <tr><td><#=INDEX#></td><td><#@JavaTypeBuilder#></td><td><#=title#></td><td>枚举</td><td></td></tr>
	 <#}#>
</tbody>
</table>
<#}#>
<#?((classes!=null) && (classes._size>0)){#>
<table class="table-5">
<thead>
<tr><th>序号</th><th>名称</th><th>标题</th><th>类型</th><th>表名</th></tr>
</thead>
<tbody>
	 <#*(class:classes){#>
	 <tr><td><#=INDEX#></td><td><#@JavaTypeBuilder#></td><td><#=title#></td><td>实体</td><td><#/lower(tableName)#></td></tr>
	 <#}#>
</tbody>
</table>
<#}#>
</div>
</div>
<#}#>
<#}#>
</body>
</html>
