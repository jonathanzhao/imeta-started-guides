package meta;

import java.util.HashMap;

public class Meta {
	private static HashMap<String, Relation> metamap;
	static {
		metamap = new HashMap<String, Relation>();
	}
	static {
<#*(component:components){#>
	<#?(aggregations!=null) && (aggregations._size>0){#>
	<#*(aggregation:aggregations){#>
		metamap.put("<#=aggrChild.name#>.<#=parentRole.name#>", new Relation(RelationType.Association, "<#=aggrParent.name#>", "<#=aggrParent.keyProperty.name#>"));
		metamap.put("<#=aggrParent.name#>.<#=childRole.name#>", new Relation(RelationType.Composition, "<#=aggrChild.name#>", "<#=parentRole.name#>"));
	<#}#>
	<#}#>
	<#?(classes!=null) && (classes._size>0){#>
	<#*(class:classes){#>
		<#?(properties!=null) && (properties._size>0){#>
		<#*(property:properties){#>
			<#?(isAssociationProperty==true && (isAggregationProperty!=true || isAggrParentRole==true)){#>
		metamap.put("<#=owner.name#>.<#=name#>", new Relation(RelationType.Association, "<#=type.name#>", "<#=type.keyProperty.name#>"));
			<#}#>
		<#}#>
		<#}#>
	<#}#>
	<#}#>
<#}#>
	}

	public static Relation relation(String path) {
		return metamap.get(path);
	}
}
