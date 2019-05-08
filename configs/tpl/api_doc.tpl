<!DOCTYPE html>
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>API文档</title>
<link href="css/main.css" type="text/css" rel="stylesheet">
</head>
<body>
<div class="menu">
[<a href="index.html">HOME</a>]
</div>
<h1 class="center">API</h1>
<#*(component:components){#>
<#*(class:classes)?(operations._size>0 && tableName!=null){#>
<#?(IS_FIRST==true)#><h2 class="hence center">※<#=owner.title#>(<#/capital(owner.name)#>)※</h2><#}#>
<div class="layer1">
<#*(operation:operations){#>
<div class="layer2 hence">
<h3><#=INDEX#>、<#=title#>(<#=name#>)</h3>
<div class="description">
<span class="title">方法：</span><#=method#><#?((method==PATCH) || (method==DELETE)){#>&nbsp;(<i>POST is also ok</i>)<#}#><br />
<span class="title">地址：</span><#=?srv#><#?(srv==null){#>/<#=owner.owner.name#>/<#=owner.name#>/<#=name#>.do<#}#><br />
<span class="title">实现：</span>by&nbsp;<#@JavaTypeBuilder,impl#>
</div>
<table class="table-5">
<thead>
<tr><th>参数</th><th>类型</th><th>入/出</th><th>说明</th></tr>
</thead>
<tbody>
	 <#*(parameter:tplParams)?(kind==In){#>
	 <tr><td><#=name#></td><td><#@JavaTypeBuilder#></td><td>入</td><td><#=title#>
	 <#?(name==schemaJson){#>
	 &nbsp;<a href="../json/query/<#=owner.impl.owner.moduleName#>_<#=owner.impl.owner.name#>_<#=owner.impl.name#>.json">示例</a>
	 <#}#>
	 <#?(name!=schemaJson && name$=Json){#>
	 &nbsp;<a href="../json/<#=owner.impl.owner.moduleName#>_<#=owner.impl.owner.name#>_<#=owner.impl.name#>.json">示例</a>
	 <#}#>
	 </td></tr>
	 <#}#>
	 <#*(parameter:tplParams)?(kind==Return){#>
	 <tr><td><#=name#></td><td><#@JavaTypeBuilder#></td><td>返回值</td><td><#=title#></td></tr>
	 <#}#>
</tbody>
</table>
</div>
<#}#>
</div>
<#}#>
<#}#>
</body>
</html>
