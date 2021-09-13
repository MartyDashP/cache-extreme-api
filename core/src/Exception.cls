Class ExtremeAPI.Exception Extends %Exception.General
{

Method %OnNew(cause As %String, code As %String = "") As %Status [ Private ]
{
	ret ##super("", code, "", cause, "")
}

}

