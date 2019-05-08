package <#=NAME_SPACE#>.<#=owner.moduleName#>.<#=owner.name#>;

import java.util.HashMap;

/**
 * <#=title#>枚举
 *
 * @author <#=AUTHOR#>
 * @version <#=VERSION#>
 * @createTime <#=CURRENT_DATE#>
 */
public enum <#=name#> {
<#?{#>
<#:(m1DataType=="String"){#>
<#*(literal:literals){#>
	<#=name#>("<#=title#>", "<#=value#>")<#?(IS_LAST==false){#>,<#}#><#?(IS_LAST==true){#>;<#}#>

<#}#>
<#}#>
<#:(m1DataType=="Short"){#>
<#*(literal:literals){#>
	<#=name#>("<#=title#>", (short) <#=value#>)<#?(IS_LAST==false){#>,<#}#><#?(IS_LAST==true){#>;<#}#>

<#}#>
<#}#>
<#:(m1DataType=="Integer"){#>
<#*(literal:literals){#>
	<#=name#>("<#=title#>", <#=value#>)<#?(IS_LAST==false){#>,<#}#><#?(IS_LAST==true){#>;<#}#>

<#}#>
<#}#>
<#}#>

	private String name;
	private <#=m1DataType#> value;

	<#=name#>(String name, <#=m1DataType#> value) {
		this.name = name;
		this.value = value;
	}

	public String getName() {
		return name;
	}

	public <#=m1DataType#> getValue() {
		return value;
	}

	private static HashMap<String, <#=name#>> map = new HashMap<>();

    static {
<#*(literal:literals){#>
        map.put("<#=value#>", <#=owner.name#>.<#=name#>);
<#}#>
    }

	public static <#=name#> find(Object value) {
		if (value == null) {
			return null;
		}
		return map.get(value.toString().intern());
	}
}
