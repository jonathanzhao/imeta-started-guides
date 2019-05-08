{<#*(property:properties)?(isAggregationProperty!=true && isKey!=true && (isDerived!=true || isCode==true || isName==true) && isDependencyProperty!=true && isRedundant!=true){#>

    "<#=name#>":<#/next#><#?(IS_LAST!=true)#>,<#}#>
<#}#>
<#*(property:properties)?(isAggregationProperty==true && isAggrChildRole==true){#><#?{#>
<#:(aggregation.isChildRoleCollection==false){#>,
    "<#=name#>": <#@EntityTestBuilder,type#>
<#}#>
<#:{#>,
    "<#=name#>": [
        <#@EntityTestBuilder,type#>,
        <#@EntityTestBuilder,type#>
    ]
<#}#>
<#}#><#}#>
}