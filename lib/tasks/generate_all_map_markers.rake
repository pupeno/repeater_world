# Copyright 2023, Pablo Fernandez
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

desc "Generate all map markers"
task generate_all_map_markers: :environment do
  body = "#EA4335"
  dot = "#B21511"

  bands = {RepeaterSearch::BAND_10M[:symbol] => "#eabd35",
           RepeaterSearch::BAND_6M[:symbol] => "#d3ea35",
           RepeaterSearch::BAND_4M[:symbol] => "#86ea35",
           RepeaterSearch::BAND_2M[:symbol] => "#ea4335",
           RepeaterSearch::BAND_1_25M[:symbol] => "#36e8a4",
           RepeaterSearch::BAND_70CM[:symbol] => "#36e8df",
           RepeaterSearch::BAND_33CM[:symbol] => "#36a0e8",
           RepeaterSearch::BAND_23CM[:symbol] => "#3660e8",
           RepeaterSearch::BAND_13CM[:symbol] => "#4636e8",
           RepeaterSearch::BAND_9CM[:symbol] => "#aa36e8",
           RepeaterSearch::BAND_6CM[:symbol] => "#e836c6",
           RepeaterSearch::BAND_3CM[:symbol] => "#e8367a"}
  modes = {:multi => "#420a0a",
           RepeaterSearch::FM[:symbol] => "#b21511",
           RepeaterSearch::DSTAR[:symbol] => "#1b7209",
           RepeaterSearch::FUSION[:symbol] => "#12afa7",
           RepeaterSearch::DMR[:symbol] => "#2812af",
           RepeaterSearch::NXDN[:symbol] => "#ab12af",
           RepeaterSearch::P25[:symbol] => "#6f0f93",
           RepeaterSearch::TETRA[:symbol] => "#09724c"}
  File.open(Rails.root.join("design/map_marker/marker.svg"), "r") do |orig_marker|
    orig_marker_content = orig_marker.read
    bands.each do |band, band_color|
      modes.each do |mode, mode_color|
        puts "Generating marker-#{band}-#{mode}.svg"
        new_marker = orig_marker_content.gsub(body, band_color).gsub(dot, mode_color)
        File.write(Rails.root.join("app/assets/images/map_markers/marker-#{band}-#{mode}.svg"), new_marker)
      end
    end
  end
end
