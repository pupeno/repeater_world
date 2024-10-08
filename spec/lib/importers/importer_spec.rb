# Copyright 2023-2024, Pablo Fernandez
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

require "rails_helper"

RSpec.describe Importer do
  it "should delegate an interface to subclasses" do
    expect { Importer.source }.to raise_error("Importer subclasses must implement this method")
    importer = Importer.new
    expect { importer.import }.to raise_error("Importer subclasses must implement this method")
    expect { importer.send(:import_all_repeaters) }.to raise_error("Importer subclasses must implement this method")
    expect { importer.send(:call_sign_and_tx_frequency, nil) }.to raise_error("Importer subclasses must implement this method")
    expect { importer.send(:import_repeater, nil, nil) }.to raise_error("Importer subclasses must implement this method")
  end

  it "should figure out us state" do
    importer = Importer.new
    expect(importer.send(:figure_out_us_state, "al")).to eq("Alabama")
    expect(importer.send(:figure_out_us_state, "Alabama")).to eq("Alabama")
    expect(importer.send(:figure_out_us_state, "ak")).to eq("Alaska")
    expect(importer.send(:figure_out_us_state, "Alaska")).to eq("Alaska")
    expect(importer.send(:figure_out_us_state, "az")).to eq("Arizona")
    expect(importer.send(:figure_out_us_state, "Arizona")).to eq("Arizona")
    expect(importer.send(:figure_out_us_state, "ar")).to eq("Arkansas")
    expect(importer.send(:figure_out_us_state, "Arkansas")).to eq("Arkansas")
    expect(importer.send(:figure_out_us_state, "ca")).to eq("California")
    expect(importer.send(:figure_out_us_state, "California")).to eq("California")
    expect(importer.send(:figure_out_us_state, "co")).to eq("Colorado")
    expect(importer.send(:figure_out_us_state, "Colorado")).to eq("Colorado")
    expect(importer.send(:figure_out_us_state, "ct")).to eq("Connecticut")
    expect(importer.send(:figure_out_us_state, "Connecticut")).to eq("Connecticut")
    expect(importer.send(:figure_out_us_state, "de")).to eq("Delaware")
    expect(importer.send(:figure_out_us_state, "Delaware")).to eq("Delaware")
    expect(importer.send(:figure_out_us_state, "fl")).to eq("Florida")
    expect(importer.send(:figure_out_us_state, "Florida")).to eq("Florida")
    expect(importer.send(:figure_out_us_state, "ga")).to eq("Georgia")
    expect(importer.send(:figure_out_us_state, "Georgia")).to eq("Georgia")
    expect(importer.send(:figure_out_us_state, "hi")).to eq("Hawaii")
    expect(importer.send(:figure_out_us_state, "Hawaii")).to eq("Hawaii")
    expect(importer.send(:figure_out_us_state, "id")).to eq("Idaho")
    expect(importer.send(:figure_out_us_state, "Idaho")).to eq("Idaho")
    expect(importer.send(:figure_out_us_state, "il")).to eq("Illinois")
    expect(importer.send(:figure_out_us_state, "Illinois")).to eq("Illinois")
    expect(importer.send(:figure_out_us_state, "in")).to eq("Indiana")
    expect(importer.send(:figure_out_us_state, "Indiana")).to eq("Indiana")
    expect(importer.send(:figure_out_us_state, "ia")).to eq("Iowa")
    expect(importer.send(:figure_out_us_state, "Iowa")).to eq("Iowa")
    expect(importer.send(:figure_out_us_state, "ks")).to eq("Kansas")
    expect(importer.send(:figure_out_us_state, "Kansas")).to eq("Kansas")
    expect(importer.send(:figure_out_us_state, "ky")).to eq("Kentucky")
    expect(importer.send(:figure_out_us_state, "Kentucky")).to eq("Kentucky")
    expect(importer.send(:figure_out_us_state, "la")).to eq("Louisiana")
    expect(importer.send(:figure_out_us_state, "Louisiana")).to eq("Louisiana")
    expect(importer.send(:figure_out_us_state, "me")).to eq("Maine")
    expect(importer.send(:figure_out_us_state, "Maine")).to eq("Maine")
    expect(importer.send(:figure_out_us_state, "md")).to eq("Maryland")
    expect(importer.send(:figure_out_us_state, "Maryland")).to eq("Maryland")
    expect(importer.send(:figure_out_us_state, "ma")).to eq("Massachusetts")
    expect(importer.send(:figure_out_us_state, "Massachusetts")).to eq("Massachusetts")
    expect(importer.send(:figure_out_us_state, "mi")).to eq("Michigan")
    expect(importer.send(:figure_out_us_state, "Michigan")).to eq("Michigan")
    expect(importer.send(:figure_out_us_state, "mn")).to eq("Minnesota")
    expect(importer.send(:figure_out_us_state, "Minnesota")).to eq("Minnesota")
    expect(importer.send(:figure_out_us_state, "ms")).to eq("Mississippi")
    expect(importer.send(:figure_out_us_state, "Mississippi")).to eq("Mississippi")
    expect(importer.send(:figure_out_us_state, "mo")).to eq("Missouri")
    expect(importer.send(:figure_out_us_state, "Missouri")).to eq("Missouri")
    expect(importer.send(:figure_out_us_state, "mt")).to eq("Montana")
    expect(importer.send(:figure_out_us_state, "Montana")).to eq("Montana")
    expect(importer.send(:figure_out_us_state, "ne")).to eq("Nebraska")
    expect(importer.send(:figure_out_us_state, "Nebraska")).to eq("Nebraska")
    expect(importer.send(:figure_out_us_state, "nv")).to eq("Nevada")
    expect(importer.send(:figure_out_us_state, "Nevada")).to eq("Nevada")
    expect(importer.send(:figure_out_us_state, "nh")).to eq("New Hampshire")
    expect(importer.send(:figure_out_us_state, "New Hampshire")).to eq("New Hampshire")
    expect(importer.send(:figure_out_us_state, "nj")).to eq("New Jersey")
    expect(importer.send(:figure_out_us_state, "New Jersey")).to eq("New Jersey")
    expect(importer.send(:figure_out_us_state, "nm")).to eq("New Mexico")
    expect(importer.send(:figure_out_us_state, "New Mexico")).to eq("New Mexico")
    expect(importer.send(:figure_out_us_state, "ny")).to eq("New York")
    expect(importer.send(:figure_out_us_state, "New York")).to eq("New York")
    expect(importer.send(:figure_out_us_state, "nc")).to eq("North Carolina")
    expect(importer.send(:figure_out_us_state, "North Carolina")).to eq("North Carolina")
    expect(importer.send(:figure_out_us_state, "nd")).to eq("North Dakota")
    expect(importer.send(:figure_out_us_state, "North Dakota")).to eq("North Dakota")
    expect(importer.send(:figure_out_us_state, "oh")).to eq("Ohio")
    expect(importer.send(:figure_out_us_state, "Ohio")).to eq("Ohio")
    expect(importer.send(:figure_out_us_state, "ok")).to eq("Oklahoma")
    expect(importer.send(:figure_out_us_state, "Oklahoma")).to eq("Oklahoma")
    expect(importer.send(:figure_out_us_state, "or")).to eq("Oregon")
    expect(importer.send(:figure_out_us_state, "Oregon")).to eq("Oregon")
    expect(importer.send(:figure_out_us_state, "pa")).to eq("Pennsylvania")
    expect(importer.send(:figure_out_us_state, "Pennsylvania")).to eq("Pennsylvania")
    expect(importer.send(:figure_out_us_state, "ri")).to eq("Rhode Island")
    expect(importer.send(:figure_out_us_state, "Rhode Island")).to eq("Rhode Island")
    expect(importer.send(:figure_out_us_state, "sc")).to eq("South Carolina")
    expect(importer.send(:figure_out_us_state, "South Carolina")).to eq("South Carolina")
    expect(importer.send(:figure_out_us_state, "sd")).to eq("South Dakota")
    expect(importer.send(:figure_out_us_state, "South Dakota")).to eq("South Dakota")
    expect(importer.send(:figure_out_us_state, "tn")).to eq("Tennessee")
    expect(importer.send(:figure_out_us_state, "Tennessee")).to eq("Tennessee")
    expect(importer.send(:figure_out_us_state, "tx")).to eq("Texas")
    expect(importer.send(:figure_out_us_state, "Texas")).to eq("Texas")
    expect(importer.send(:figure_out_us_state, "ut")).to eq("Utah")
    expect(importer.send(:figure_out_us_state, "Utah")).to eq("Utah")
    expect(importer.send(:figure_out_us_state, "vt")).to eq("Vermont")
    expect(importer.send(:figure_out_us_state, "Vermont")).to eq("Vermont")
    expect(importer.send(:figure_out_us_state, "va")).to eq("Virginia")
    expect(importer.send(:figure_out_us_state, "Virginia")).to eq("Virginia")
    expect(importer.send(:figure_out_us_state, "wa")).to eq("Washington")
    expect(importer.send(:figure_out_us_state, "Washington")).to eq("Washington")
    expect(importer.send(:figure_out_us_state, "wv")).to eq("West Virginia")
    expect(importer.send(:figure_out_us_state, "West Virginia")).to eq("West Virginia")
    expect(importer.send(:figure_out_us_state, "wi")).to eq("Wisconsin")
    expect(importer.send(:figure_out_us_state, "Wisconsin")).to eq("Wisconsin")
    expect(importer.send(:figure_out_us_state, "wy")).to eq("Wyoming")
    expect(importer.send(:figure_out_us_state, "Wyoming")).to eq("Wyoming")
    expect(importer.send(:figure_out_us_state, "DC")).to eq("District of Columbia")
    expect(importer.send(:figure_out_us_state, "District of Columbia")).to eq("District of Columbia")
    expect(importer.send(:figure_out_us_state, "na")).to eq(nil)
    expect(importer.send(:figure_out_us_state, "vi")).to eq("Virgin Islands, U.S.")
    expect(importer.send(:figure_out_us_state, "puerto rico")).to eq("Puerto Rico")
    expect { importer.send(:figure_out_us_state, "not a state") }.to raise_error("Invalid US state: not a state")
  end

  it "should figure out Canadian province" do
    importer = Importer.new
    expect(importer.send(:figure_out_canadian_province, "ab")).to eq("Alberta")
    expect(importer.send(:figure_out_canadian_province, ".canada-alberta")).to eq("Alberta")
    expect(importer.send(:figure_out_canadian_province, "bc")).to eq("British Columbia")
    expect(importer.send(:figure_out_canadian_province, ".canada-british columbia")).to eq("British Columbia")
    expect(importer.send(:figure_out_canadian_province, "mb")).to eq("Manitoba")
    expect(importer.send(:figure_out_canadian_province, ".canada-manitoba")).to eq("Manitoba")
    expect(importer.send(:figure_out_canadian_province, "nb")).to eq("New Brunswick")
    expect(importer.send(:figure_out_canadian_province, "nl")).to eq("Newfoundland and Labrador")
    expect(importer.send(:figure_out_canadian_province, ".canada-newfoundland")).to eq("Newfoundland and Labrador")
    expect(importer.send(:figure_out_canadian_province, "ns")).to eq("Nova Scotia")
    expect(importer.send(:figure_out_canadian_province, ".canada-nova scotia")).to eq("Nova Scotia")
    expect(importer.send(:figure_out_canadian_province, "on")).to eq("Ontario")
    expect(importer.send(:figure_out_canadian_province, ".canada-ontario")).to eq("Ontario")
    expect(importer.send(:figure_out_canadian_province, "pe")).to eq("Prince Edward Island")
    expect(importer.send(:figure_out_canadian_province, "qc")).to eq("Quebec")
    expect(importer.send(:figure_out_canadian_province, ".canada-quebec")).to eq("Quebec")
    expect(importer.send(:figure_out_canadian_province, "sk")).to eq("Saskatchewan")
    expect(importer.send(:figure_out_canadian_province, ".canada-saskatchewan")).to eq("Saskatchewan")
    expect(importer.send(:figure_out_canadian_province, "nt")).to eq("Northwest Territories")
    expect(importer.send(:figure_out_canadian_province, ".canada-northwest territories")).to eq("Northwest Territories")
    expect(importer.send(:figure_out_canadian_province, "nu")).to eq("Nunavut")
    expect(importer.send(:figure_out_canadian_province, ".canada-nunavut")).to eq("Nunavut")
    expect(importer.send(:figure_out_canadian_province, "yt")).to eq("Yukon")
    expect { importer.send(:figure_out_canadian_province, "not a province") }.to raise_error("Invalid Canadian province: not a province")
  end
end
