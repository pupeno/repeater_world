module Exporters
  EXPORTER_FOR = {
    baofeng_uv_5r: BaofengUv5rExporter,
    csv: Exporter,
    icom_ic_705: IcomIc705Exporter,
    icom_id_51: IcomId51Exporter,
    icom_id_52: IcomId52Exporter,
    yaesu_ft5d: YaesuFt5dExporter
  }

  SUPPORTED_FORMATS = [["General", [["CSV", :csv]]]] +
    [
      ["Baofeng", [
        ["Baofeng UV-5R", :baofeng_uv5r]
      ].sort],
      ["Icom", [
        ["Icom IC-705", :icom_ic_705],
        ["Icom ID-51A (50th Anniversary/PLUS)", :icom_id_51],
        ["Icom ID-51A PLUS2", :icom_id_51],
        ["Icom ID-51A", :icom_id_51],
        ["Icom ID-51E (50th Anniversary/PLUS)", :icom_id_51],
        ["Icom ID-51E PLUS2", :icom_id_51],
        ["Icom ID-51E", :icom_id_51],
        ["Icom ID-52", :icom_id_52]
      ].sort],
      ["Yaesu", [
        ["Yaesu FT5DE", :yaesu_ft5d],
        ["Yaesu FT5DR", :yaesu_ft5d]
      ].sort]
    ].sort
end
