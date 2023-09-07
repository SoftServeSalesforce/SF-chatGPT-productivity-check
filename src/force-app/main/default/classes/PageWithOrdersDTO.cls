public with sharing class PageWithOrdersDTO {
    @AuraEnabled
    public List<OrderDTO> orders;
    @AuraEnabled
    public Integer pageNumber;
    @AuraEnabled
    public Integer pageSize;
    @AuraEnabled
    public Integer totalPages;
    @AuraEnabled
    public Integer totalOrders;
    @AuraEnabled
    public Boolean hasPreviousPage;
    @AuraEnabled
    public Boolean hasNextPage;


    public PageWithOrdersDTO() {
        this.orders = new List<OrderDTO>();
    }

    public void addPageDetails(ApexPages.StandardSetController ssc) {
        if (null == ssc) {
            throw new IllegalArgumentException(Constants.EXCEPTION_SSC_CANNOT_BE_NULL);
        }
        this.pageNumber = ssc.getPageNumber();
        this.pageSize = ssc.getPageSize();
        this.hasPreviousPage = ssc.getHasPrevious();
        this.hasNextPage = ssc.getHasNext();
        this.totalOrders = ssc.getResultSize();
        this.totalPages = ((this.totalOrders / (Decimal) this.pageSize)).round(System.RoundingMode.CEILING).intValue();
    }
}