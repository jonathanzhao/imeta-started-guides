{
    "flag": 1,
    "success": true,
    "msg": "<#/ifnull(msg,"")#>",
    "status": 200
    <#?(json!=null){#>
    <#?(totalCount!=null){#>
    ,"totalCount": "<#/ifnull(totalCount, "0")#>"
    <#}#>
    ,"data": <#=json#>
    <#}#>
}