ROUTINE ExtremeAPI.general [Type=INC]
#Define E(%arg) %arg

///
#Define CollectSortedClassProperties(%props,%comClass) d $$$E(##class(ExtremeAPI.Functions).CollectSortedClassProperties(%props,%comClass))

///
#Define IsSupportedObjectTypeProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsSupportedObjectTypeProperty(%arg))

///
#Define IsSupportedObjectType(%arg) $$$E(##class(ExtremeAPI.Functions).IsSupportedObjectType(%arg))

///
#Define IsListType(%arg) $$$E(##class(ExtremeAPI.Functions).IsListType(%arg))

///
#Define IsDataType(%arg) $$$E(##class(ExtremeAPI.Functions).IsDataType(%arg))

///
#Define IsDataTypeProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsDataTypeProperty(%arg))

///
#Define IsCollectionProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsCollectionProperty(%arg))

///
#Define IsCollectionAsList(%arg) $$$E(##class(ExtremeAPI.Functions).IsCollectionAsList(%arg))

///
#Define GetCompiledClass(%arg) $$$E(##class(ExtremeAPI.Functions).GetCompiledClass(%arg))

///
#Define UnsupportedTypeExeption(%type) $$$E(##class(ExtremeAPI.Exception.UnsupportedTypeException).%New(%type))

///
#Define NormalizeClassName(%arg) $$$E(##class(ExtremeAPI.Functions).NormalizeClassName(%arg))

///
#Define GetMethodName(%arg) ##safeexpression(""""_$e("%arg",3,*)_"""")

///
#Define Wrap(%arg) ##safeexpression("""""""""_%arg_""""""""")
