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

xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
  end

  xml.url do
    xml.loc new_repeater_url
  end

  xml.url do
    xml.loc values_url
  end

  xml.url do
    xml.loc map_legend_url
  end

  xml.url do
    xml.loc data_limitations_ukrepeater_net_url
  end

  xml.url do
    xml.loc data_limitations_sral_fi_url
  end

  xml.url do
    xml.loc crawler_url
  end

  xml.url do
    xml.loc privacy_policy_url
  end

  xml.url do
    xml.loc cookie_policy_url
  end

  @repeaters.map do |repeater|
    xml.url do
      xml.loc repeater_url(repeater)
      xml.lastmod repeater.updated_at.to_date
    end
  end
end
