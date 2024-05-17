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

RSpec.describe ArtscipubImporter do
  before do
    Repeater.destroy_all
    files = {"http://www.artscipub.com/repeaters/" => "home.html",
             "http://www.artscipub.com/repeaters/search/index.asp?state=Alabama" => "Alabama_1.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23613&ln=N4PHP_repeater_information_on_224.500_in_Alabaster,_Alabama" => "23613.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27480&ln=KI4RYX_repeater_information_on_145.11_in_Albertville,_Alabama" => "27480.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20806&ln=WA4KIK_repeater_information_on_146.96_in_Alexander_City,_Alabama" => "20806.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23365&ln=N5ZUA_repeater_information_on_446.050_in_Alexandria,_Alabama" => "23365.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18430&ln=kb4fku_repeater_information_on_147.060_in_Allsboro,_Alabama" => "18430.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20909&ln=WC4M_repeater_information_on_147.260_in_Andalusia,_Alabama" => "20909.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27855&ln=KJ4JGK_repeater_information_on_145.280_in_Anniston,_Alabama" => "27855.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27854&ln=WX4CAL_repeater_information_on_146.780_in_Anniston,_Alabama" => "27854.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24807&ln=KIH58_repeater_information_on_162.475_in_Anniston,_ALABAMA" => "24807.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27856&ln=KJ4JGK_repeater_information_on_443.350_in_Anniston,_Alabama" => "27856.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23805&ln=KF4RGR_repeater_information_on_444.050_in_Anniston,_Alabama" => "23805.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11042&ln=KE4Y_repeater_information_on_146.920_in_Arab,_Alabama" => "11042.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24813&ln=WNG642_repeater_information_on_162.525_in_Arab,_ALABAMA" => "24813.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=10852&ln=KE4Y_repeater_information_on_443.225_in_Arab,_Alabama" => "10852.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26293&ln=KC4UG_repeater_information_on_444.400_in_Ashcraft_Corner_/_Gordo,_Alabama" => "26293.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16396&ln=KI4PSG_repeater_information_on_147.255_in_Ashland,_Alabama" => "16396.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22668&ln=KA4Y_repeater_information_on_147.060_in_Auburn,_Alabama" => "22668.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17502&ln=K4RY_repeater_information_on_147.240_in_Auburn,_Alabama" => "17502.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24817&ln=WWF54_repeater_information_on_162.525_in_Auburn,_ALABAMA" => "24817.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27476&ln=W4KEN_repeater_information_on_224.840_in_Auburn,_Alabama" => "27476.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22013&ln=K4RY_repeater_information_on_444.800_in_Auburn,_Alabama" => "22013.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17954&ln=K4RAW_repeater_information_on_147.090_in_Baldwin_County,_Alabama" => "17954.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31119&ln=W4CFI_repeater_information_on_147.415_in_Battleground,_Alabama" => "31119.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30358&ln=K4JIE_repeater_information_on_444.175_in_Bay_Minette,_Alabama" => "30358.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26686&ln=WB4YRJ_repeater_information_on_145.150_in_Bessemer,_Alabama" => "26686.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17127&ln=WB4TJX_repeater_information_on_145.230_in_Birmingham,_Alabama" => "17127.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16139&ln=K4TQR_repeater_information_on_145.57_in_Birmingham,_Alabama" => "16139.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=50873&ln=W4TCT_repeater_information_on_146.620_in_Birmingham,_Alabama" => "50873.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16145&ln=KK4BSK_repeater_information_on_146.760_in_Birmingham,_Alabama" => "16145.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12868&ln=w4cue_repeater_information_on_146.880_in_Birmingham,_Alabama" => "12868.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=29722&ln=W4TPA_repeater_information_on_147.28_in_Birmingham,_Alabama" => "29722.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24803&ln=KIH54_repeater_information_on_162.55_in_Birmingham,_ALABAMA" => "24803.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16140&ln=K4TQR_repeater_information_on_224.22_in_Birmingham,_Alabama" => "16140.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16141&ln=K4TQR/R_repeater_information_on_444.100_in_Birmingham,_Alabama" => "16141.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17010&ln=KE4ADV_repeater_information_on_444.425_in_BIRMINGHAM,_Alabama" => "17010.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18017&ln=KA5GET_repeater_information_on_444.650_in_Birmingham,_Alabama" => "18017.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22212&ln=AG4ZV_repeater_information_on_444.825_in_Birmingham,_Alabama" => "22212.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26621&ln=NA4SM_repeater_information_on_147.200_in_Boaz,_Alabama" => "26621.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22583&ln=KC0ONR_repeater_information_on_443.050_in_Boaz,_Alabama" => "22583.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31472&ln=NU4A_repeater_information_on_145.390_in_Brent,_Alabama" => "31472.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24388&ln=WB4ARU_repeater_information_on_146.970_in_Brewton,_Alabama" => "24388.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24814&ln=WNG646_repeater_information_on_162.475_in_Brewton,_ALABAMA" => "24814.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30744&ln=N5GEB_repeater_information_on_147.130_in_Camden,_Alabama" => "30744.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22395&ln=K4CR_repeater_information_on_146.685_in_Carrollton,_Alabama" => "22395.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18622&ln=kan654_repeater_information_on_158.805_in_chapman,_Alabama" => "18622.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27859&ln=WB4GNA_repeater_information_on_145.300_in_Cheaha_mtn,_Alabama" => "27859.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27857&ln=WB4GNA_repeater_information_on_147.090_in_Cheaha_Mtn,_Alabama" => "27857.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27861&ln=WB4GNA_repeater_information_on_442.425_in_Cheaha_Mtn,_Alabama" => "27861.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27858&ln=WB4GNA_repeater_information_on_444.750_in_Cheaha_Mtn,_Alabama" => "27858.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19476&ln=WB4GNA_repeater_information_on_147.090_in_Cheaha_Mtn.,_Alabama" => "19476.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21820&ln=WB4UQT_repeater_information_on_147.105_in_Clanton,_Alabama" => "21820.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=28562&ln=K9GOZ_repeater_information_on_443.875_in_Clio,_Alabama" => "28562.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24821&ln=WXM32_repeater_information_on_162.4_in_Columbus,_ALABAMA" => "24821.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=28813&ln=N5IV_repeater_information_on_147.390_in_Cordova,_Alabama" => "28813.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=43901&ln=KD4CIF_repeater_information_on_147.12_in_Corner,_Alabama" => "43901.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=44132&ln=w9kop_repeater_information_on_145.25_in_Courtland,_Alabama" => "44132.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26960&ln=N4TUN_repeater_information_on_145.310_in_Cullman,_Alabama" => "26960.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24819&ln=WWF66_repeater_information_on_162.45_in_Cullman,_ALABAMA" => "24819.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21978&ln=WA4TAL_repeater_information_on_444.525_in_Dadeville,_Alabama" => "21978.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21109&ln=N4VCN_repeater_information_on_145.21_in_Decatur,_Alabama" => "21109.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16990&ln=W9KOP_repeater_information_on_145.47_in_Decatur,_Alabama" => "16990.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17095&ln=W9KOP_repeater_information_on_146.72_in_Decatur,_Alabama" => "17095.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12606&ln=W4ATD_repeater_information_on_146.98_in_Decatur,_Alabama" => "12606.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12605&ln=W4ATD_repeater_information_on_147.00_in_Decatur,_Alabama" => "12605.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21108&ln=W9KOP_repeater_information_on_442.350_in_Decatur,_Alabama" => "21108.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24820&ln=WXL72_repeater_information_on_162.475_in_Demopolis,_ALABAMA" => "24820.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16839&ln=N4BWP/R_repeater_information_on_442.375_in_Demopolis,_Alabama" => "16839.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=28688&ln=W4WTG_repeater_information_on_147.080_in_Dixons_Mills,_Alabama" => "28688.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12997&ln=W4DHN-1_repeater_information_on_145.430_in_Dothan,_Alabama" => "12997.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31157&ln=WR4OG_repeater_information_on_146.85_in_Dothan,_Alabama" => "31157.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31301&ln=KC4JBF/R_repeater_information_on_147.140_in_Dothan,_Alabama" => "31301.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=13017&ln=N4RNU_repeater_information_on_147.340_in_Dothan,_Alabama" => "13017.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12998&ln=WR4OG-3_repeater_information_on_444.675_in_Dothan,_Alabama" => "12998.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31305&ln=W4DHN-2_repeater_information_on_444.775_in_Dothan,_Alabama" => "31305.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31684&ln=KK4CWX_repeater_information_on_442.450_in_Douglas,_Alabama" => "31684.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24808&ln=KIH59_repeater_information_on_162.55_in_Dozier,_ALABAMA" => "24808.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26134&ln=W4NQ_repeater_information_on_146.78_in_Elba,_Alabama" => "26134.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11566&ln=KD4BWM_repeater_information_on_145.390_in_Enterprise,_Alabama" => "11566.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21335&ln=WD4ROJ_repeater_information_on_147.240_in_Enterprise,_Alabama" => "21335.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=46208&ln=WD4ROJ_repeater_information_on_443.2500_in_Enterprise,_Alabama" => "46208.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24271&ln=WS4I_repeater_information_on_145.370_in_Eutaw,_Alabama" => "24271.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45160&ln=KK4QXJ_repeater_information_on_145.4000_in_Fayette,_Alabama" => "45160.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24559&ln=W4GLE_repeater_information_on_147.200_in_Fayette,_Alabama" => "24559.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45162&ln=KK4QXJ_repeater_information_on_443.075_in_Fayette,_Alabama" => "45162.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31088&ln=W4ZZK_repeater_information_on_145.410_in_Florence,_Alabama" => "31088.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18412&ln=K4NDL_repeater_information_on_147.32_in_Florence,_Alabama" => "18412.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24806&ln=KIH57_repeater_information_on_162.475_in_Florence,_ALABAMA" => "24806.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30942&ln=WA4FYN_repeater_information_on_442.250_in_Florence,_Alabama" => "30942.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24237&ln=KI4SP_repeater_information_on_444.200_in_Florence,_Alabama" => "24237.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30434&ln=KQ4RA_repeater_information_on_444.650_in_Florence,_Alabama" => "30434.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12754&ln=W4GBR_repeater_information_on_147.270_in_Fort_Payne,_Alabama" => "12754.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23111&ln=KF4FWZ_repeater_information_on_442.600_in_Fort_Payne,_Alabama" => "23111.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20263&ln=KE4SXC_repeater_information_on_443.075_in_Fort_Payne,_Alabama" => "20263.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23110&ln=KF4FWX_repeater_information_on_444.800_in_Fort_Payne,_ALABAMA" => "23110.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19352&ln=KE4LTT_repeater_information_on_147.200_in_Friendship,_Alabama" => "19352.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19375&ln=kE4LTT_repeater_information_on_444.575_in_Friendship,_Alabama" => "19375.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26454&ln=K4RBC_repeater_information_on_145.490_in_Gadsden,_Alabama" => "26454.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22271&ln=K4RBC_repeater_information_on_146.670_in_Gadsden,_Alabama" => "22271.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21418&ln=K4VMV_repeater_information_on_146.820_in_Gadsden,_Alabama" => "21418.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22001&ln=K4JMC_repeater_information_on_147.160_in_Gadsden,_Alabama" => "22001.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21370&ln=K4VMV_repeater_information_on_444.675_in_Gadsden,_Alabama" => "21370.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12676&ln=K4BWR_repeater_information_on_444.775_in_Gadsden,_Alabama" => "12676.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23730&ln=KK4YOE_repeater_information_on_444.850_in_Gadsden,_Alabama" => "23730.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18077&ln=K4JS_repeater_information_on_145.250_in_Gaylesville,_Alabama" => "18077.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45731&ln=W4GEN_repeater_information_on_145.160_in_Geneva,_Alabama" => "45731.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26002&ln=W4GEN_repeater_information_on_145.270_in_Geneva,_Alabama" => "26002.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45621&ln=WA4TAL_repeater_information_on_145.27_in_Goldville,_Alabama" => "45621.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24811&ln=WNG607_repeater_information_on_162.425_in_Greenville,_ALABAMA" => "24811.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23077&ln=K4WWN_repeater_information_on_145.17_in_Guntersville,_Alabama" => "23077.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26980&ln=K4DED_repeater_information_on_442.975_in_Gurley,_Alabama" => "26980.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30531&ln=W4ZZA_repeater_information_on_442.225_in_Haleyville,_Alabama" => "30531.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26294&ln=KJ4I_repeater_information_on_147.020_in_Hamilton,_Alabama" => "26294.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17543&ln=WB3EYB_repeater_information_on_145.210_in_Harrisburg,_Alabama" => "17543.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24815&ln=WWF44_repeater_information_on_162.5_in_Henagar,_ALABAMA" => "24815.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19444&ln=WG8S_repeater_information_on_1293.000_in_Huntsville,_Alabama" => "19444.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16180&ln=W4XE_repeater_information_on_145.23_in_Huntsville,_Alabama" => "16180.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27600&ln=KK4AI_repeater_information_on_145.29_in_Huntsville,_Alabama" => "27600.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16182&ln=W4ATV_repeater_information_on_145.33_in_Huntsville,_Alabama" => "16182.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26186&ln=W4DNR_repeater_information_on_145.390_in_Huntsville,_Alabama" => "26186.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19605&ln=W4TCL_repeater_information_on_146.860_in_Huntsville,_Alabama" => "19605.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16186&ln=N4HSV_repeater_information_on_146.94_in_Huntsville,_Alabama" => "16186.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16187&ln=KS4LU_repeater_information_on_147.10_in_Huntsville,_Alabama" => "16187.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16188&ln=N4AZY_repeater_information_on_147.14_in_Huntsville,_Alabama" => "16188.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16189&ln=WD4CPF_repeater_information_on_147.18_in_Huntsville,_Alabama" => "16189.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16190&ln=W4HMC_repeater_information_on_147.22_in_Huntsville,_Alabama" => "16190.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16191&ln=KB4CRG_repeater_information_on_147.24_in_Huntsville,_Alabama" => "16191.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16192&ln=N4VB_repeater_information_on_147.30_in_Huntsville,_Alabama" => "16192.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23576&ln=KC4HRX_repeater_information_on_147.505_in_Huntsville,_Alabama" => "23576.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24802&ln=KIH20_repeater_information_on_162.4_in_Huntsville,_ALABAMA" => "24802.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16193&ln=N4HSV_repeater_information_on_224.94_in_Huntsville,_Alabama" => "16193.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19606&ln=W4TCL_repeater_information_on_442.525_in_Huntsville,_Alabama" => "19606.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16194&ln=KB4CRG_repeater_information_on_442.775_in_Huntsville,_Alabama" => "16194.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23371&ln=W4DNR_repeater_information_on_443.000_in_Huntsville,_Alabama" => "23371.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16197&ln=W4SSW_repeater_information_on_443.250_in_Huntsville,_Alabama" => "16197.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16198&ln=KM4ON_repeater_information_on_443.325_in_Huntsville,_Alabama" => "16198.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16200&ln=KS4LU_repeater_information_on_443.475_in_Huntsville,_Alabama" => "16200.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16201&ln=W4HSV_repeater_information_on_443.500_in_Huntsville,_Alabama" => "16201.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16202&ln=N4HSV_repeater_information_on_443.800_in_Huntsville,_Alabama" => "16202.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16203&ln=KD4TFV_repeater_information_on_444.175_in_Huntsville,_Alabama" => "16203.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16204&ln=W4XE_repeater_information_on_444.300_in_Huntsville,_Alabama" => "16204.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19607&ln=W4TCL_repeater_information_on_444.350_in_Huntsville,_Alabama" => "19607.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16205&ln=KB4CRG_repeater_information_on_444.575_in_Huntsville,_Alabama" => "16205.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24818&ln=WWF55_repeater_information_on_162.5_in_Jackson,_ALABAMA" => "24818.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20947&ln=N4MYI_repeater_information_on_146.640_in_Jasper,_Alabama" => "20947.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11447&ln=wb4acn_repeater_information_on_146.90_in_Jasper,_Alabama" => "11447.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22882&ln=N4MYI_repeater_information_on_443.275_in_Jasper,_Alabama" => "22882.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=32137&ln=N4MYI_repeater_information_on_443.925_in_Jasper,_Alabama" => "32137.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=49587&ln=N4MYI_repeater_information_on_444.050_in_Jasper,_Alabama" => "49587.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26948&ln=wb4uqt_repeater_information_on_444.475_in_Jemison,_Alabama" => "26948.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31984&ln=AB4RC_repeater_information_on_442.475_in_Killen,_Alabama" => "31984.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26882&ln=KS4QF_repeater_information_on_444.425_in_Killen,_Alabama" => "26882.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11672&ln=N7CHN_repeater_information_on_441.475_in_Kirkland,_Alabama" => "11672.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27434&ln=Ac4eg_repeater_information_on_147.340_in_Leighton,_Alabama" => "27434.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24805&ln=KIH56_repeater_information_on_162.475_in_Louisville,_ALABAMA" => "24805.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21493&ln=KI4ELU_repeater_information_on_146.685_in_Magnolia_Springs,_Alabama" => "21493.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=43979&ln=KD4EXS_repeater_information_on_147.375_in_Marion,_Alabama" => "43979.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19445&ln=W4OZK_repeater_information_on_224.720_in_Mentone,_Alabama" => "19445.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19085&ln=W4OZK_repeater_information_on_443.400_in_Mentone,_Alabama" => "19085.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19084&ln=W4OZK_repeater_information_on_53.190_in_Mentone,_Alabama" => "19084.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45178&ln=KN4BOF_repeater_information_on_145.2400_in_Millport,_Alabama" => "45178.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11444&ln=W9QYQ_repeater_information_on_146.730_in_Mitchell,_Alabama" => "11444.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22243&ln=W4IAX_repeater_information_on_146.820_in_Mobile,_Alabama" => "22243.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11413&ln=K4AN_repeater_information_on_147.120_in_Mobile,_Alabama" => "11413.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20089&ln=W4IAX_repeater_information_on_147.345_in_Mobile,_Alabama" => "20089.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24801&ln=KEC61_repeater_information_on_162.55_in_Mobile,_ALABAMA" => "24801.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20087&ln=WB4QEV_repeater_information_on_444.50_in_Mobile,_Alabama" => "20087.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27066&ln=W4IAX_repeater_information_on_53.030_in_Mobile,_Alabama" => "27066.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18714&ln=WB4UFT_repeater_information_on_147.160_in_Monroeville,_Alabama" => "18714.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31705&ln=K8IDX_repeater_information_on_444.775_in_Monroeville,_Alabama" => "31705.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=44152&ln=KX4AA_repeater_information_on_146.940_in_Montevallo,_Alabama" => "44152.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21055&ln=W4AP_repeater_information_on_146.840_in_Montgomery,_Alabama" => "21055.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=25856&ln=W4AP_repeater_information_on_146.920_in_Montgomery,_Alabama" => "25856.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24804&ln=KIH55_repeater_information_on_162.4_in_Montgomery,_ALABAMA" => "24804.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18941&ln=WD4JRB_repeater_information_on_444.450_in_Montgomery,_Alabama" => "18941.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23310&ln=N4IDX_repeater_information_on_145.270_in_Moulton,_Alabama" => "23310.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11502&ln=N4IDX_repeater_information_on_146.96_in_Moulton,_Alabama" => "11502.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=29765&ln=K4CR_repeater_information_on_147.220_in_Moundville,_Alabama" => "29765.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16705&ln=W4JNB_repeater_information_on_146.61_in_Muscle_Shoals,_Alabama" => "16705.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19479&ln=W4BLT_repeater_information_on_146.700_in_Nectar,_Alabama" => "19479.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22004&ln=W4BLT_repeater_information_on_443.775_in_Nectar,_Alabama" => "22004.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31727&ln=N3AST_repeater_information_on_443.875_in_Nectar,_Alabama" => "31727.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=37689&ln=KD4NJA_repeater_information_on_145.260_in_Oneonta,_Alabama" => "37689.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31685&ln=KK4CWX_repeater_information_on_147.375_in_Oneonta,_Alabama" => "31685.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24810&ln=WNG606_repeater_information_on_162.425_in_Oneonta,_ALABAMA" => "24810.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=37690&ln=N3AST_repeater_information_on_442.750_in_Oneonta,_Alabama" => "37690.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=37687&ln=WPZU392_repeater_information_on_462.600_in_ONEONTA,_Alabama" => "37687.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17761&ln=W4LEE_repeater_information_on_147.12_in_Opelika,_Alabama" => "17761.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22028&ln=N4TKT_repeater_information_on_442.175_in_Opelika,_Alabama" => "22028.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22008&ln=W4ZBA_repeater_information_on_444.100_in_Opelika,_Alabama" => "22008.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26800&ln=W4ORC_repeater_information_on_146.640_in_Opp,_Alabama" => "26800.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=23424&ln=WR4OG-1_repeater_information_on_146.980_in_Ozark,_Alabama" => "23424.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22667&ln=KE4QCY_repeater_information_on_145.450_in_Palmerdale,_Alabama" => "22667.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=49586&ln=N4MYI_repeater_information_on_146.860_in_Parrish,_Alabama" => "49586.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21343&ln=W4SHL_repeater_information_on_146.980_in_Pelham,_Alabama" => "21343.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24024&ln=WA4JUM_repeater_information_on_147.14_in_Pelham,_Alabama" => "24024.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12838&ln=K4SCC_repeater_information_on_145.130_in_Pell_City,_Alabama" => "12838.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22009&ln=N4BRC_repeater_information_on_145.190_in_PELL_CITY,_Alabama" => "22009.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26775&ln=K4CVH_repeater_information_on_147.020_in_Pell_City,_Alabama" => "26775.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=43825&ln=N4BRC_repeater_information_on_444.725_in_Pell_City,_Alabama" => "43825.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12515&ln=W4CVY_repeater_information_on_146.610_in_Phenix_City,_Alabama" => "12515.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24337&ln=WX4RUS_repeater_information_on_147.320_in_Phenix_City,_Alabama" => "24337.html",
             "http://www.artscipub.com/repeaters/search/index.asp?state=Alabama&s=200" => "Alabama_2.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22007&ln=WA4QHN_repeater_information_on_444.200_in_Phenix_City,_Alabama" => "22007.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31681&ln=KJ4MTX_repeater_information_on_443.625_in_Piedmont,_Alabama" => "31681.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=29646&ln=KF4BCR_repeater_information_on_442.550_in_Rainsville,_Alabama" => "29646.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21956&ln=N4THM_repeater_information_on_146.865_in_Ranburne,_Alabama" => "21956.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21935&ln=N4THM_repeater_information_on_444.175_in_Ranburne,_Alabama" => "21935.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27421&ln=WX4FC_repeater_information_on_146.790_in_Red_Bay,_Alabama" => "27421.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26219&ln=KJ4JNX_repeater_information_on_1251.6_in_Roanoke,_Alabama" => "26219.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26218&ln=KJ4JNX_repeater_information_on_1283.0_in_Roanoke,_Alabama" => "26218.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26216&ln=KJ4JNX_repeater_information_on_145.400_in_Roanoke,_Alabama" => "26216.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=25964&ln=KA4KBX_repeater_information_on_145.430_in_Roanoke,_Alabama" => "25964.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22187&ln=WD4KTY_repeater_information_on_147.04_in_Roanoke,_Alabama" => "22187.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=25963&ln=KA4KBX_repeater_information_on_147.270_in_Roanoke,_Alabama" => "25963.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26214&ln=KA4KBX_repeater_information_on_224.920_in_Roanoke,_Alabama" => "26214.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26215&ln=KA4KBX_repeater_information_on_444.275_in_Roanoke,_Alabama" => "26215.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26217&ln=KJ4JNX_repeater_information_on_444.900_in_Roanoke,_Alabama" => "26217.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12112&ln=_repeater_information_on_146.685_in_Robertsdale,_Alabama" => "12112.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16637&ln=kj4gcw_repeater_information_on_146.740_in_Rogersville,_Alabama" => "16637.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16639&ln=KJ4GCW_repeater_information_on_442.500_in_Rogersville,_Alabama" => "16639.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=17999&ln=AE4HF_repeater_information_on_442.925_in_Rogersville,_Alabama" => "17999.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16640&ln=WA4III_repeater_information_on_53.23_in_Rogersville,_Alabama" => "16640.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27482&ln=ke4col_repeater_information_on_145.23_in_Roxana,_Alabama" => "27482.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30387&ln=WX4FC_repeater_information_on_147.160_in_Russellville,_Alabama" => "30387.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26088&ln=WX4FC_repeater_information_on_147.210_in_Russellville,_Alabama" => "26088.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=11503&ln=WX4FC_repeater_information_on_147.36_in_Russellville,_Alabama" => "11503.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27422&ln=KI4OKJ_repeater_information_on_444.675_in_Russellville,_Alabama" => "27422.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27475&ln=W4KEN_repeater_information_on_224.880_in_Santuck,_Alabama" => "27475.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31373&ln=K4GR_repeater_information_on_444.225_in_Santuck,_Alabama" => "31373.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22027&ln=N4SCO_repeater_information_on_146.900_in_Scottsboro,_Alabama" => "22027.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22016&ln=W4SBO_repeater_information_on_147.360_in_Section,_Alabama" => "22016.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24812&ln=WNG635_repeater_information_on_162.45_in_Selma,_ALABAMA" => "24812.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24621&ln=N4GLE_repeater_information_on_146.88_in_Sheffield,_Alabama" => "24621.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18645&ln=KD4KRP_repeater_information_on_147.030_in_SKIPPERVILLE,_Alabama" => "18645.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=22029&ln=KF4AEJ_repeater_information_on_145.350_in_Smiths_Station,_Alabama" => "22029.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26384&ln=KF4AEJ_repeater_information_on_444.850_in_Smiths_Station,_Alabama" => "26384.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=38960&ln=WR4JW_repeater_information_on_444.325_in_Somerville,_Alabama" => "38960.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=19036&ln=WF7N_repeater_information_on_147.120_in_Spanish_Fort,_Alabama" => "19036.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=27071&ln=N4FIV_repeater_information_on_444.600_in_Spanish_Fort,_Alabama" => "27071.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=28653&ln=KJ4SQP_repeater_information_on_144.100_in_Springville,_Alabama" => "28653.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=16707&ln=W4CUE_repeater_information_on_441.975_in_Steele,_Alabama" => "16707.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20544&ln=N5EY_repeater_information_on_146.97_in_sugar_land,_Alabama" => "20544.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21977&ln=AF4FN_repeater_information_on_146.655_in_Sylacauga,_Alabama" => "21977.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21420&ln=W4YH_repeater_information_on_442.500_in_Sylacauga,_Alabama" => "21420.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21954&ln=N4WNL_repeater_information_on_146.740_in_Talladega,_Alabama" => "21954.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=43830&ln=W4GVX_repeater_information_on_146.850_in_Tecumseh,_Alabama" => "43830.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=43971&ln=W4GVX_repeater_information_on_146.850_in_Tecumseh,_Alabama" => "43971.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21425&ln=W3NH_repeater_information_on_147.075_in_Trafford,_Alabama" => "21425.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24247&ln=W4NQ_repeater_information_on_146.820_in_Troy,_Alabama" => "24247.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=33550&ln=KK4YOE_repeater_information_on_145.040_in_Trussville,_Alabama" => "33550.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20636&ln=KK4YOE_repeater_information_on_442.100_in_Trussville,_Alabama" => "20636.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31625&ln=KF4IZY_repeater_information_on_144.980_in_TUSCALOOSA,_Alabama" => "31625.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24272&ln=WS4I_repeater_information_on_145.110_in_Tuscaloosa,_Alabama" => "24272.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=20227&ln=W4UAL_repeater_information_on_145.210_in_Tuscaloosa,_Alabama" => "20227.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=48698&ln=KX4I_repeater_information_on_145.350_in_TUSCALOOSA,_Alabama" => "48698.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18985&ln=KX4I_repeater_information_on_145.470_in_TUSCALOOSA,_Alabama" => "18985.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18366&ln=WX4I_repeater_information_on_146.820_in_TUSCALOOSA,_Alabama" => "18366.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24266&ln=WS4I_repeater_information_on_146.925_in_Tuscaloosa,_Alabama" => "24266.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=47873&ln=KR4ET_repeater_information_on_147.240_in_TUSCALOOSA,_Alabama" => "47873.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=10891&ln=W4WYN_repeater_information_on_147.300_in_TUSCALOOSA,_Alabama" => "10891.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24809&ln=KIH60_repeater_information_on_162.4_in_Tuscaloosa,_ALABAMA" => "24809.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=26344&ln=K4CR_repeater_information_on_442.375_in_Tuscaloosa,_Alabama" => "26344.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=47874&ln=KX4I_repeater_information_on_443.575_in_TUSCALOOSA,_Alabama" => "47874.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=18365&ln=WX4I_repeater_information_on_443.825_in_tuscaloosa,_Alabama" => "18365.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=47876&ln=KX4I_repeater_information_on_444.025_in_TUSCALOOSA,_Alabama" => "47876.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=30433&ln=W4ZZK_repeater_information_on_145.13_in_Tuscumbia,_Alabama" => "30433.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=31982&ln=W4ZZK_repeater_information_on_444.875_in_Tuscumbia,_Alabama" => "31982.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=44658&ln=WR4JW_repeater_information_on_440.6125_in_Union_Hill,_Alabama" => "44658.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12607&ln=W4RDB_repeater_information_on_443.85_in_Union_Hill,_Alabama" => "12607.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45172&ln=KC4UG_repeater_information_on_145.1200_in_Vernon,_Alabama" => "45172.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24730&ln=KC4UG_repeater_information_on_145.430_in_Vernon,_Alabama" => "24730.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24731&ln=KC4UG_repeater_information_on_444.250_in_Vernon,_Alabama" => "24731.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=45175&ln=KC4UG_repeater_information_on_444.5000_in_Vernon,_Alabama" => "45175.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=12737&ln=WA4SBC_repeater_information_on_147.045_in_Virginia_Beach,_Alabama" => "12737.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21419&ln=W4YH_repeater_information_on_145.270_in_Weogufka,_Alabama" => "21419.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21965&ln=W4AP_repeater_information_on_444.500_in_Wetumpka,_Alabama" => "21965.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=4708&ln=KT4JW_repeater_information_on_147.04_in_WINFIELD,_Alabama" => "4708.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=24816&ln=WWF53_repeater_information_on_162.525_in_Winfield,_ALABAMA" => "24816.html",
             "http://www.artscipub.com/repeaters/detail.asp?rid=21583&ln=K4QXT_repeater_information_on_147.000_in_York,_Alabama" => "21583.html"}
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec",
        "factories",
        "artscipub_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("ArtscipubImporter") do |dir|
      expect do
        ArtscipubImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(252)

      # Grab some repeaters and verify they were imported correctly.
      repeater = Repeater.find_by(call_sign: "N4PHP")
      expect(repeater.band).to eq(Repeater::BAND_1_25M)
      expect(repeater.tx_frequency).to eq(224_500_000)
    end
  end

  it "should not import anything new on a second pass" do
    Dir.mktmpdir("ArtscipubImporter") do |dir|
      ArtscipubImporter.new(working_directory: dir).import

      # The second time we call it, it shouldn't re-download any files, nor create new repeaters
      expect do
        ArtscipubImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
    end
  end

  it "should respect the source values during import" do
    Dir.mktmpdir("ArtscipubImporter") do |dir|
      ArtscipubImporter.new(working_directory: dir).import

      # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
      # delete it to avoid stale data.
      deleted = create(:repeater, :full, call_sign: "N4PHP", tx_frequency: 145_000_001, source: ArtscipubImporter.source)

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      changed = Repeater.find_by(call_sign: "KI4RYX")
      changed_rx_frequency_was = changed.rx_frequency
      changed.rx_frequency = 1_000_000
      changed.save!

      # This repeater represents one where a secondary source imported first, and this importer will override it.
      secondary_source = Repeater.find_by(call_sign: "WA4KIK")
      secondary_source_rx_frequency_was = secondary_source.rx_frequency
      secondary_source.rx_frequency = 1_000_000
      secondary_source.source = IrlpImporter.source
      secondary_source.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      independent = Repeater.find_by(call_sign: "N5ZUA")
      independent.rx_frequency = 1_000_000
      independent.source = nil
      independent.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        ArtscipubImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: deleted.call_sign, tx_frequency: deleted.tx_frequency).count }.by(-1)

      # This one got deleted
      expect { deleted.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # This got updated.
      changed.reload
      expect(changed.rx_frequency).to eq(changed_rx_frequency_was)

      # This got updated.
      secondary_source.reload
      expect(secondary_source.rx_frequency).to eq(secondary_source_rx_frequency_was)
      expect(secondary_source.source).to eq(ArtscipubImporter.source)

      # This one didn't change.
      independent.reload
      expect(independent.rx_frequency).to eq(1_000_000)
    end
  end
end
