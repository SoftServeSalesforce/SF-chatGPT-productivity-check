public with sharing class Debug {
    public Debug() {

    }
    
    public static Map<String, Id> getRecordTypeIds(String objName, List<String> rTypeNames){
        Map<String,Schema.RecordTypeInfo> rtMapByName = getDescribe(objName).getDescribe().getRecordTypeInfosByName();
        Map<String, Id> mapToReturn = new Map<String, Id>();
        for ( String recordTypeName : rTypeNames ) {
            mapToReturn.put( recordTypeName, rtMapByName.get(recordTypeName).getRecordTypeId() );
        }
        return mapToReturn;
    }
}