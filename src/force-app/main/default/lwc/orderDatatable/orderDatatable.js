import LightningDatatable from "lightning/datatable";
import orderStatusTimeBadgeTemplate from "./orderStatusTimeBadgeTemplate.html";

export default class MyCustomTypeDatatable extends LightningDatatable {
  static customTypes = {
    orderStatusTimeBadge: {
      template: orderStatusTimeBadgeTemplate,
      typeAttributes: ["status", "lastStatusChanged"],
    }
  };
}