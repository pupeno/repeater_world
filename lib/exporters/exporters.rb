# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

module Exporters
  EXPORTER_FOR = {
    baofeng_uv_5r: BaofengUv5rExporter,
    csv: CsvExporter,
    icom_ic_705: IcomIc705Exporter,
    icom_id_51: IcomId51Exporter,
    icom_id_52: IcomId52Exporter,
    yaesu_ft5d: YaesuFt5dExporter
  }

  SUPPORTED_FORMATS =
    [["General", [["CSV", :csv]]]] + # At the beginning to avoid being sorted.
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
