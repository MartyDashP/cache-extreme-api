Class JetAPI.Util.General Extends %RegisteredObject
{

ClassMethod LBToListOfDT(list As %List) As %ListOfDataTypes
{
	s listOfDT = ##class(%ListOfDataTypes).%New()
	
	f i=1:1:$ll(list)
	{
		s item = $lg(list, i)
		$$$TOE(sc, listOfDT.Insert(item))
	}
	
	ret listOfDT
}

ClassMethod GetCannonicalPath(path As %String) As %String
{
	if $$$isWINDOWS
	{
		ret $replace($tr(path, "\","/"),"//","/")
	}

	ret $replace($tr(path, "/","\"),"\\","\")
}

}

