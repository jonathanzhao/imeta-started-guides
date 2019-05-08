{
	"fields":[
<#*(property:properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isDerived!=true && isDependencyProperty!=true){#>
		{"name":"<#=name#>"},
<#?(isAssociationProperty==true){#>
		<#*(property:type.properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isDerived!=true  && isDependencyProperty!=true && isKey!=true){#>
		{"name":"<#=_super.name#>.<#=name#>"},
<#?(isAssociationProperty==true){#>
		<#*(property:type.properties)?((isAggregationProperty!=true || isAggrChildRole!=true) && isDerived!=true  && isDependencyProperty!=true && isKey!=true){#>
		{"name":"<#=_super._super.name#>.<#=_super.name#>.<#=name#>"},
		<#}#>
<#}#>
		<#}#>
<#}#>
<#}#>
<#?(syncProperty!=null){#>
		{"name":"<#=syncProperty.name#>"}
<#}#>
<#?(syncProperty==null){#>
		{"name":"1","alias":"_placeholder"}
<#}#>
	],
	"conditions":[
		{"name":"id","v1":<#/key#>,"op":"eq"}
	],
	"orders":[
		{"name":"id","order":"desc"}
	],
	"pager":{"pageIndex":1,"pageSize":10}
}
