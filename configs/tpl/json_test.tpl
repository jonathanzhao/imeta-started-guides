{
    "name":"<#=name#>","age":<#=age#>,
    <#?(educations._size>0){#>
    "educations":[
    <#*(edu:educations){#>
        "<#=INDEX#>":"<#=start#>,<#=school#>"
    <#}#>
    ]
    <#}#>
}