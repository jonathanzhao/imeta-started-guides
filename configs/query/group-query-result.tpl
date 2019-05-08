{
    "flag": 1,
    "msg": "success",
    "status": 200,
    "data": {
        "goodsCateTotalCount": <#=goodsCateStat.data[0].totalCount#>,
        "goodsTotalCount": <#=goodsStat.data[0].totalCount#>,
        "orderGrowth": {
            <#& orderStat.data,_with { #>
            "axis": {
                "data": [
                <#*(item:_with){#>
                   <#=totalOrderQty#><#?(IS_LAST!=true)#>,<#}#>
                <#}#>
                ]
            },
            "series": {
                "data": [
                <#*(item:_with){#>
                    "<#=year#>-<#=aggvalue#>"<#?(IS_LAST!=true)#>,<#}#>
                <#}#>
                ]
            },
            "name": "订单增长趋势"
            <#}#>
        }
    }
}