# Get the current DB connection:
connection = ActiveRecord::Base.connection

# Default roles:
Role.create(:name => 'client')
Role.create(:name => 'supplier')
Role.create(:name => 'advisor')
Role.create(:name => 'admin')
Role.create(:name => 'superadmin')

puts 'Roles - OK'

# Default user:
@first_user = User.create!({
                 :first_name => 'Jakub',
                 :last_name => 'Borys',
                 :email => 'jakub.borys@gmail.com',
                 :mobile => '07718225201',
                 :password => 'Wines1234',
                 :password_confirmation => 'Wines1234',
                 :stripe_id => 'cus_58fCEwXl68Xknn'
             })

@first_user
@first_user.add_role(:superadmin)
@first_user.active = true
@first_user.save

Payment.create!({
                    :user => @first_user,
                    :brand => 1,
                    :number => '1111',
                    :stripe_card_id => 'card_14yNrx242nQKOZxvq4IBG6qB'
                })

user_address = Address.create!(
    :line_1 => '8a Pickfords Wharf',
    :line_2 => 'Wharf Road',
    :postcode => 'N1 7RJ'
)

AddressesUsers.create!(
    :user => @first_user,
    :address => user_address
)

puts 'Admin - OK'

# Default order statuses:
Status.create(:label => 'pending')
Status.create(:label => 'paid')
Status.create(:label => 'payment failed')
Status.create(:label => 'pickup')
Status.create(:label => 'delivery')
Status.create(:label => 'delivered')
Status.create(:label => 'cancelled')

puts 'Statuses - OK'

Category.create(
    :id => 1,
    :name => 'House',
    :price => 15,
    :restaurant_price => '20-40',
    :description => "<p>Producers with much higher quality than mass-produced wines you'll find in supermarkets.</p>",
    :summary => 'Entry-point to best wine regions'
)

Category.create(
    :id => 2,
    :name => 'Reserve',
    :price => 20,
    :restaurant_price => '40-55',
    :description => "<p>An introduction to producers from the most sought after locations in the world's best wine regions, with the most rigorous and premium production.</p>",
    :summary => 'Premium production, best vineyards'
)

Category.create(
    :id => 3,
    :name => 'Fine',
    :price => 30,
    :restaurant_price => '55-75',
    :description => '<p>The most cherished  locations in wine, producing critically acclaimed wines. Discover clarity of flavours unique to the finest wines.</p>',
    :summary => 'Top producers from famed vineyards'
)

Category.create(
    :id => 4,
    :name => 'Cellar',
    :price => 50,
    :restaurant_price => '75-120',
    :description => "<p>The best producers from wine's most sacred vineyards</p><p>Cellar wines are chosen at the perfect age to fully experience greatness in winemaking</p>",
    :summary => 'Great vintages of the top producers'
)

puts 'Categories - OK'


# Execute a sql statement:
connection.execute "
  INSERT INTO countries (name, alpha_2, alpha_3) VALUES
  ('Afghanistan', 'af', 'afg'),
  ('Aland Islands', 'ax', 'ala'),
  ('Albania', 'al', 'alb'),
  ('Algeria', 'dz', 'dza'),
  ('American Samoa', 'as', 'asm'),
  ('Andorra', 'ad', 'and'),
  ('Angola', 'ao', 'ago'),
  ('Anguilla', 'ai', 'aia'),
  ('Antarctica', 'aq', ''),
  ('Antigua and Barbuda', 'ag', 'atg'),
  ('Argentina', 'ar', 'arg'),
  ('Armenia', 'am', 'arm'),
  ('Aruba', 'aw', 'abw'),
  ('Australia', 'au', 'aus'),
  ('Austria', 'at', 'aut'),
  ('Azerbaijan', 'az', 'aze'),
  ('Bahamas', 'bs', 'bhs'),
  ('Bahrain', 'bh', 'bhr'),
  ('Bangladesh', 'bd', 'bgd'),
  ('Barbados', 'bb', 'brb'),
  ('Belarus', 'by', 'blr'),
  ('Belgium', 'be', 'bel'),
  ('Belize', 'bz', 'blz'),
  ('Benin', 'bj', 'ben'),
  ('Bermuda', 'bm', 'bmu'),
  ('Bhutan', 'bt', 'btn'),
  ('Bolivia, Plurinational State of', 'bo', 'bol'),
  ('Bonaire, Sint Eustatius and Saba', 'bq', 'bes'),
  ('Bosnia and Herzegovina', 'ba', 'bih'),
  ('Botswana', 'bw', 'bwa'),
  ('Bouvet Island', 'bv', ''),
  ('Brazil', 'br', 'bra'),
  ('British Indian Ocean Territory', 'io', ''),
  ('Brunei Darussalam', 'bn', 'brn'),
  ('Bulgaria', 'bg', 'bgr'),
  ('Burkina Faso', 'bf', 'bfa'),
  ('Burundi', 'bi', 'bdi'),
  ('Cambodia', 'kh', 'khm'),
  ('Cameroon', 'cm', 'cmr'),
  ('Canada', 'ca', 'can'),
  ('Cape Verde', 'cv', 'cpv'),
  ('Cayman Islands', 'ky', 'cym'),
  ('Central African Republic', 'cf', 'caf'),
  ('Chad', 'td', 'tcd'),
  ('Chile', 'cl', 'chl'),
  ('China', 'cn', 'chn'),
  ('Christmas Island', 'cx', ''),
  ('Cocos (Keeling) Islands', 'cc', ''),
  ('Colombia', 'co', 'col'),
  ('Comoros', 'km', 'com'),
  ('Congo', 'cg', 'cog'),
  ('Congo, The Democratic Republic of the', 'cd', 'cod'),
  ('Cook Islands', 'ck', 'cok'),
  ('Costa Rica', 'cr', 'cri'),
  ('Cote d''Ivoire', 'ci', 'civ'),
  ('Croatia', 'hr', 'hrv'),
  ('Cuba', 'cu', 'cub'),
  ('Curacao', 'cw', 'cuw'),
  ('Cyprus', 'cy', 'cyp'),
  ('Czech Republic', 'cz', 'cze'),
  ('Denmark', 'dk', 'dnk'),
  ('Djibouti', 'dj', 'dji'),
  ('Dominica', 'dm', 'dma'),
  ('Dominican Republic', 'do', 'dom'),
  ('Ecuador', 'ec', 'ecu'),
  ('Egypt', 'eg', 'egy'),
  ('El Salvador', 'sv', 'slv'),
  ('Equatorial Guinea', 'gq', 'gnq'),
  ('Eritrea', 'er', 'eri'),
  ('Estonia', 'ee', 'est'),
  ('Ethiopia', 'et', 'eth'),
  ('Falkland Islands (Malvinas)', 'fk', 'flk'),
  ('Faroe Islands', 'fo', 'fro'),
  ('Fiji', 'fj', 'fji'),
  ('Finland', 'fi', 'fin'),
  ('France', 'fr', 'fra'),
  ('French Guiana', 'gf', 'guf'),
  ('French Polynesia', 'pf', 'pyf'),
  ('French Southern Territories', 'tf', ''),
  ('Gabon', 'ga', 'gab'),
  ('Gambia', 'gm', 'gmb'),
  ('Georgia', 'ge', 'geo'),
  ('Germany', 'de', 'deu'),
  ('Ghana', 'gh', 'gha'),
  ('Gibraltar', 'gi', 'gib'),
  ('Greece', 'gr', 'grc'),
  ('Greenland', 'gl', 'grl'),
  ('Grenada', 'gd', 'grd'),
  ('Guadeloupe', 'gp', 'glp'),
  ('Guam', 'gu', 'gum'),
  ('Guatemala', 'gt', 'gtm'),
  ('Guernsey', 'gg', 'ggy'),
  ('Guinea', 'gn', 'gin'),
  ('Guinea-Bissau', 'gw', 'gnb'),
  ('Guyana', 'gy', 'guy'),
  ('Haiti', 'ht', 'hti'),
  ('Heard Island and McDonald Islands', 'hm', ''),
  ('Holy See (Vatican City State)', 'va', 'vat'),
  ('Honduras', 'hn', 'hnd'),
  ('Hong Kong', 'hk', 'hkg'),
  ('Hungary', 'hu', 'hun'),
  ('Iceland', 'is', 'isl'),
  ('India', 'in', 'ind'),
  ('Indonesia', 'id', 'idn'),
  ('Iran, Islamic Republic of', 'ir', 'irn'),
  ('Iraq', 'iq', 'irq'),
  ('Ireland', 'ie', 'irl'),
  ('Isle of Man', 'im', 'imn'),
  ('Israel', 'il', 'isr'),
  ('Italy', 'it', 'ita'),
  ('Jamaica', 'jm', 'jam'),
  ('Japan', 'jp', 'jpn'),
  ('Jersey', 'je', 'jey'),
  ('Jordan', 'jo', 'jor'),
  ('Kazakhstan', 'kz', 'kaz'),
  ('Kenya', 'ke', 'ken'),
  ('Kiribati', 'ki', 'kir'),
  ('Korea, Democratic People''s Republic of', 'kp', 'prk'),
  ('Korea, Republic of', 'kr', 'kor'),
  ('Kuwait', 'kw', 'kwt'),
  ('Kyrgyzstan', 'kg', 'kgz'),
  ('Lao People''s Democratic Republic', 'la', 'lao'),
  ('Latvia', 'lv', 'lva'),
  ('Lebanon', 'lb', 'lbn'),
  ('Lesotho', 'ls', 'lso'),
  ('Liberia', 'lr', 'lbr'),
  ('Libyan Arab Jamahiriya', 'ly', 'lby'),
  ('Liechtenstein', 'li', 'lie'),
  ('Lithuania', 'lt', 'ltu'),
  ('Luxembourg', 'lu', 'lux'),
  ('Macao', 'mo', 'mac'),
  ('Macedonia, The former Yugoslav Republic of', 'mk', 'mkd'),
  ('Madagascar', 'mg', 'mdg'),
  ('Malawi', 'mw', 'mwi'),
  ('Malaysia', 'my', 'mys'),
  ('Maldives', 'mv', 'mdv'),
  ('Mali', 'ml', 'mli'),
  ('Malta', 'mt', 'mlt'),
  ('Marshall Islands', 'mh', 'mhl'),
  ('Martinique', 'mq', 'mtq'),
  ('Mauritania', 'mr', 'mrt'),
  ('Mauritius', 'mu', 'mus'),
  ('Mayotte', 'yt', 'myt'),
  ('Mexico', 'mx', 'mex'),
  ('Micronesia, Federated States of', 'fm', 'fsm'),
  ('Moldova, Republic of', 'md', 'mda'),
  ('Monaco', 'mc', 'mco'),
  ('Mongolia', 'mn', 'mng'),
  ('Montenegro', 'me', 'mne'),
  ('Montserrat', 'ms', 'msr'),
  ('Morocco', 'ma', 'mar'),
  ('Mozambique', 'mz', 'moz'),
  ('Myanmar', 'mm', 'mmr'),
  ('Namibia', 'na', 'nam'),
  ('Nauru', 'nr', 'nru'),
  ('Nepal', 'np', 'npl'),
  ('Netherlands', 'nl', 'nld'),
  ('New Caledonia', 'nc', 'ncl'),
  ('New Zealand', 'nz', 'nzl'),
  ('Nicaragua', 'ni', 'nic'),
  ('Niger', 'ne', 'ner'),
  ('Nigeria', 'ng', 'nga'),
  ('Niue', 'nu', 'niu'),
  ('Norfolk Island', 'nf', 'nfk'),
  ('Northern Mariana Islands', 'mp', 'mnp'),
  ('Norway', 'no', 'nor'),
  ('Oman', 'om', 'omn'),
  ('Pakistan', 'pk', 'pak'),
  ('Palau', 'pw', 'plw'),
  ('Palestinian Territory, Occupied', 'ps', 'pse'),
  ('Panama', 'pa', 'pan'),
  ('Papua New Guinea', 'pg', 'png'),
  ('Paraguay', 'py', 'pry'),
  ('Peru', 'pe', 'per'),
  ('Philippines', 'ph', 'phl'),
  ('Pitcairn', 'pn', 'pcn'),
  ('Poland', 'pl', 'pol'),
  ('Portugal', 'pt', 'prt'),
  ('Puerto Rico', 'pr', 'pri'),
  ('Qatar', 'qa', 'qat'),
  ('Reunion', 're', 'reu'),
  ('Romania', 'ro', 'rou'),
  ('Russian Federation', 'ru', 'rus'),
  ('Rwanda', 'rw', 'rwa'),
  ('Saint Barthelemy', 'bl', 'blm'),
  ('Saint Helena, Ascension and Tristan Da Cunha', 'sh', 'shn'),
  ('Saint Kitts and Nevis', 'kn', 'kna'),
  ('Saint Lucia', 'lc', 'lca'),
  ('Saint Martin (French Part)', 'mf', 'maf'),
  ('Saint Pierre and Miquelon', 'pm', 'spm'),
  ('Saint Vincent and The Grenadines', 'vc', 'vct'),
  ('Samoa', 'ws', 'wsm'),
  ('San Marino', 'sm', 'smr'),
  ('Sao Tome and Principe', 'st', 'stp'),
  ('Saudi Arabia', 'sa', 'sau'),
  ('Senegal', 'sn', 'sen'),
  ('Serbia', 'rs', 'srb'),
  ('Seychelles', 'sc', 'syc'),
  ('Sierra Leone', 'sl', 'sle'),
  ('Singapore', 'sg', 'sgp'),
  ('Sint Maarten (Dutch Part)', 'sx', 'sxm'),
  ('Slovakia', 'sk', 'svk'),
  ('Slovenia', 'si', 'svn'),
  ('Solomon Islands', 'sb', 'slb'),
  ('Somalia', 'so', 'som'),
  ('South Africa', 'za', 'zaf'),
  ('South Georgia and The South Sandwich Islands', 'gs', ''),
  ('South Sudan', 'ss', 'ssd'),
  ('Spain', 'es', 'esp'),
  ('Sri Lanka', 'lk', 'lka'),
  ('Sudan', 'sd', 'sdn'),
  ('Suriname', 'sr', 'sur'),
  ('Svalbard and Jan Mayen', 'sj', 'sjm'),
  ('Swaziland', 'sz', 'swz'),
  ('Sweden', 'se', 'swe'),
  ('Switzerland', 'ch', 'che'),
  ('Syrian Arab Republic', 'sy', 'syr'),
  ('Taiwan, Province of China', 'tw', ''),
  ('Tajikistan', 'tj', 'tjk'),
  ('Tanzania, United Republic of', 'tz', 'tza'),
  ('Thailand', 'th', 'tha'),
  ('Timor-Leste', 'tl', 'tls'),
  ('Togo', 'tg', 'tgo'),
  ('Tokelau', 'tk', 'tkl'),
  ('Tonga', 'to', 'ton'),
  ('Trinidad and Tobago', 'tt', 'tto'),
  ('Tunisia', 'tn', 'tun'),
  ('Turkey', 'tr', 'tur'),
  ('Turkmenistan', 'tm', 'tkm'),
  ('Turks and Caicos Islands', 'tc', 'tca'),
  ('Tuvalu', 'tv', 'tuv'),
  ('Uganda', 'ug', 'uga'),
  ('Ukraine', 'ua', 'ukr'),
  ('United Arab Emirates', 'ae', 'are'),
  ('United Kingdom', 'gb', 'gbr'),
  ('United States', 'us', 'usa'),
  ('United States Minor Outlying Islands', 'um', ''),
  ('Uruguay', 'uy', 'ury'),
  ('Uzbekistan', 'uz', 'uzb'),
  ('Vanuatu', 'vu', 'vut'),
  ('Venezuela, Bolivarian Republic of', 've', 'ven'),
  ('Viet Nam', 'vn', 'vnm'),
  ('Virgin Islands, British', 'vg', 'vgb'),
  ('Virgin Islands, U.S.', 'vi', 'vir'),
  ('Wallis and Futuna', 'wf', 'wlf'),
  ('Western Sahara', 'eh', 'esh'),
  ('Yemen', 'ye', 'yem'),
  ('Zambia', 'zm', 'zmb'),
  ('Zimbabwe', 'zw', 'zwe'),
  ('England', 'en', 'eng')"

puts 'Countries - OK'


# food types

Food.create(
    :id => 1,
    :name => "meat",
    :parent => 0
)
Food.create(
    :id => 2,
    :name => "fish",
    :parent => 0
)
Food.create(
    :id => 3,
    :name => "dairy",
    :parent => 0
)

Food.create(
    :id => 5,
    :name => "vegetables & fungi",
    :parent => 0
)
Food.create(
    :id => 6,
    :name => "herb & spice",
    :parent => 0
)
Food.create(
    :id => 7,
    :name => "carbs",
    :parent => 0
)
Food.create(
    :id => 8,
    :name => "sweet",
    :parent => 0
)
Food.create(
    :id => 9,
    :name => "beef",
    :parent => 1
)
Food.create(
    :id => 10,
    :name => "cured meat",
    :parent => 1
)
Food.create(
    :id => 11,
    :name => "pork",
    :parent => 1
)
Food.create(
    :id => 12,
    :name => "chicken",
    :parent => 1
)
Food.create(
    :id => 13,
    :name => "lobster & shellfish",
    :parent => 2
)
Food.create(
    :id => 14,
    :name => "fish",
    :parent => 2
)
Food.create(
    :id => 15,
    :name => "mussels & oysters",
    :parent => 2
)
Food.create(
    :id => 16,
    :name => "soft cheese & cream",
    :parent => 3
)
Food.create(
    :id => 17,
    :name => "pungent cheese",
    :parent => 3
)
Food.create(
    :id => 18,
    :name => "hard cheese",
    :parent => 3
)

Food.create(
    :id => 24,
    :name => "onion & garlic",
    :parent => 5
)
Food.create(
    :id => 25,
    :name => "green vegetables",
    :parent => 5
)
Food.create(
    :id => 26,
    :name => "root vegetables",
    :parent => 5
)
Food.create(
    :id => 27,
    :name => "tomato & pepper",
    :parent => 5
)
Food.create(
    :id => 28,
    :name => "mushroom",
    :parent => 5
)
Food.create(
    :id => 29,
    :name => "nuts & seeds",
    :parent => 5
)
Food.create(
    :id => 30,
    :name => "beans & peas",
    :parent => 5
)
Food.create(
    :id => 31,
    :name => "red pepper & chilli",
    :parent => 6
)
Food.create(
    :id => 32,
    :name => "pepper",
    :parent => 6
)
Food.create(
    :id => 33,
    :name => "baking spices",
    :parent => 6
)
Food.create(
    :id => 34,
    :name => "curry & hot sauce",
    :parent => 6
)
Food.create(
    :id => 35,
    :name => "herbs",
    :parent => 6
)
Food.create(
    :id => 36,
    :name => "exotic & aromatic",
    :parent => 6
)
Food.create(
    :id => 37,
    :name => "white bread",
    :parent => 7
)
Food.create(
    :id => 38,
    :name => "pasta",
    :parent => 7
)
Food.create(
    :id => 39,
    :name => "rice",
    :parent => 7
)
Food.create(
    :id => 40,
    :name => "white potato",
    :parent => 5
)
Food.create(
    :id => 41,
    :name => "sweet potato",
    :parent => 5
)
Food.create(
    :id => 42,
    :name => "fruit & berries",
    :parent => 8
)
Food.create(
    :id => 43,
    :name => "chocolate & coffee",
    :parent => 8
)
Food.create(
    :id => 44,
    :name => "vanilla & caramel",
    :parent => 8
)
Food.create(
    :id => 45,
    :name => "duck & game",
    :parent => 1
)
Food.create(
    :id => 46,
    :name => "lamb",
    :parent => 1
)

puts 'Foods - OK'

# Preparations created as a part of rake migration

puts 'Preparations - OK'

types = ['Bold Red', 'Medium Red', 'Light Red', 'Rosé', 'Rich White', 'Dry White', 'Sparkling', 'Sweet White', 'Dessert', 'Fortified']
types.each_with_index do |t, index|
  Type.create(:id => index + 1, :name => t)
end

puts 'Types - OK'

# 5 producers

include ActionDispatch::TestProcess
include GenericImporter
include CompositionImporter
include WineImporter


data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/producers.csv", 'application/csv')

import_data(data_file, :producers, %w(producer_id name country_id note))

puts 'Producers - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/regions.csv", 'application/csv')

import_data(data_file, :regions, %w(region_id name country_id))

puts 'Regions - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/subregions.csv", 'application/csv')

import_data(data_file, :subregions, %w(subregion_id name region_id))

puts 'Sub-regions - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/locales.csv", 'application/csv')

import_data(data_file, :locales, %w(locale_id name subregion_id note))

puts 'Locale - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/appellations.csv", 'application/csv')

import_data(data_file, :appellations, %w(appellation_id name classification region_id))

puts 'Appellations - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/maturations.csv", 'application/csv')

import_data(data_file, :maturations, %w(maturation_id description bottling_id))

puts 'Maturation - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/vinifications.csv", 'application/csv')

import_data(data_file, :vinifications, %w(vinification_id method name))

puts 'Vinifications - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/grapes.csv", 'application/csv')

import_data(data_file, :grapes, %w(grape_id name))

puts 'Grapes - OK'

data_file = fixture_file_upload("#{Rails.root}/test/fixtures/files/compositions.csv", 'application/csv')

import_compositions(data_file, %w(composition_id grape1_id))

puts 'Compositions - OK'

wine_path = "#{Rails.root}/test/fixtures/files/wine_seed.csv"
inventory_path = "#{Rails.root}/test/fixtures/files/inventory_seed.csv"

import_wines(wine_path)

puts 'Wines - OK'

warehouse_address1 = Address.create!(
    :line_1 => '7-19 Leadenhall Market',
    :postcode => 'EC3V 1LR',
    :coordinates => 'POINT(-0.0833929593813316 51.5126800326757)'
)

warehouse_one = Warehouse.create!(
    :title => 'Amathus City',
    :email => 'AmathusCity@vyne.london',
    :phone => '0207 283 0638',
    :shutl => true,
    :address => warehouse_address1,
    :active => true
)

warehouse_address2 = Address.create!(
    :line_1 => 'Hammer House',
    :line_2 => '113-117 Wardour Street',
    :postcode => 'W1F 0UN',
    :coordinates => 'POINT(-0.134273349439967 51.5132307523215)'
)

warehouse_two = Warehouse.create!(
    :title => 'Amathus Soho',
    :email => 'AmathusSoho@vyne.london',
    :phone => '0207 287 5769',
    :shutl => true,
    :address => warehouse_address2,
    :active => true
)

warehouse_address3 = Address.create!(
    :line_1 => '203 Brompton Road',
    :postcode => 'SW3 1LA',
    :coordinates => 'POINT(-0.166813218038706 51.4974944810043)'
)

warehouse_three = Warehouse.create!(
    :title => 'Amathus Knightsbridge',
    :email => 'AmathusKnightsbridge@vyne.london',
    :phone => '0207 745 7477',
    :shutl => true,
    :address => warehouse_address3,
    :active => true
)

puts 'Warehouses - OK'

include InventoryImporter

import_inventory(inventory_path, warehouse_one)
import_inventory(inventory_path, warehouse_two)
import_inventory(inventory_path, warehouse_three)

puts 'Inventories - OK'


Occasion.create(
    :id => 1,
    :name => 'Solo'
)

Occasion.create(
    :id => 2,
    :name => 'With Friends'
)

Occasion.create(
    :id => 3,
    :name => 'Party'
)

Occasion.create(
    :id => 4,
    :name => 'Date'
)

Occasion.create(
    :id => 5,
    :name => 'Dining'
)

Occasion.create(
    :id => 6,
    :name => 'Outdoors'
)

Occasion.create(
    :id => 7,
    :name => 'Gift'
)

puts 'Occasions - OK'
