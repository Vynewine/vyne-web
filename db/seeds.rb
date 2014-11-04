
# Get the current DB connection:
connection = ActiveRecord::Base.connection();

# Cleaning all:

# Country.delete_all
# Role.delete_all
# Status.delete_all
# User.delete_all
# Category.delete_all
# Appellation.delete_all
# Producer.delete_all
# Wine.delete_all

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

puts "Countries ---- OK"

# Default roles:
Role.create(:name => 'client')
Role.create(:name => 'supplier')
Role.create(:name => 'advisor')
Role.create(:name => 'admin')
Role.create(:name => 'superadmin')

puts "Roles -------- OK"

# Default order statuses:
Status.create(:label => 'pending')
Status.create(:label => 'paid')
Status.create(:label => 'payment failed')
Status.create(:label => 'pickup')
Status.create(:label => 'delivery')
Status.create(:label => 'delivered')
Status.create(:label => 'cancelled')

puts "Statuses ----- OK"

# Default user:
User.create!({
  :first_name => 'Gian',
  :last_name => 'M',
  :email => "gm@rockstardev.co",
  :mobile => "0111111111",
  :password => "#Wines1234",
  :password_confirmation => "#Wines1234"
})

defaultUser = User.find_by(id: 1)
defaultUser.add_role(:superadmin)
defaultUser.active = true
defaultUser.save

puts "Admin -------- OK"

@house = Category.create(
                :id => 1,
              :name => "House",
             :price => 15,
  :restaurant_price => "20-40",
       :description => "<p>Producers with much higher quality than mass-produced wines you'll find in supermarkets.</p>",
           :summary => "Entry-point to best wine regions"
)

@reserve = Category.create(
                :id => 2,
              :name => "Reserve",
             :price => 20,
  :restaurant_price => "40-55",
       :description => "<p>An introduction to producers from the most sought after locations in the world's best wine regions, with the most rigorous and premium production.</p>",
           :summary => "Premium production, best vineyards"
)

@fine = Category.create(
                :id => 3,
              :name => "Fine",
             :price => 30,
  :restaurant_price => "55-75",
       :description => "<p>The most cherished  locations in wine, producing critically acclaimed wines. Discover clarity of flavours unique to the finest wines.</p>",
           :summary => "Top producers from famed vineyards"
)

@cellar = Category.create(
                :id => 4,
              :name => "Cellar",
             :price => 50,
  :restaurant_price => "75-120",
       :description => "<p>The best producers from wine's most sacred vineyards</p><p>Cellar wines are chosen at the perfect age to fully experience greatness in winemaking</p>",
           :summary => "Great vintages of the top producers"
)

puts "Categories --- OK"

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 45 food types

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
    :id => 4,
    :name => "preparation",
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
@food_one = Food.create(
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
    :id =>42,
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
Food.create(
    :id => 47,
    :name => "raw",
  :parent => 4
)

puts "Foods -------- OK"

# Preparations created as a part of migration
@preparation = Preparation.find(1)

puts 'Preparations - OK'

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5 producers

Producer.create(
    :id => 1,
    :name => 'Cálem',
    :country_id => 178,
    :note => ''
)
Producer.create(
    :id => 2,
    :name => 'Gruber Roschitz',
    :country_id => 15,
    :note => 'For generations, Ewald Gruber has been managing vineyards in the heart of the premium wine growing area of Weinviertel. This location is renowned for its fantastic character full Grüner Veltliners.'
)
Producer.create(
    :id => 3,
    :name => 'Wickham Vineyards',
    :country_id => 250,
    :note => ''
)
Producer.create(
    :id => 4,
    :name => 'Ruinart',
    :country_id => 76,
    :note => ''
)
Producer.create(
    :id => 5,
    :name => 'Prince Hill Wines',
    :country_id => 14,
    :note => ''
)
Producer.create(
    :id => 6,
    :name => 'Al Sur',
    :country_id => 209,
    :note => ''
)
Producer.create(
    :id => 7,
    :name => 'Aldo Clerico',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 8,
    :name => 'Archeo',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 9,
    :name => 'Armand de Brignac',
    :country_id => 76,
    :note => ''
)
Producer.create(
    :id => 10,
    :name => 'Barão de Vilar',
    :country_id => 178,
    :note => 'Traditional family run Madeira producer Barão de Vilar offers classic styles of madeira at great prices and with a long history. Traditionally trellised vines and aged traditionally in gentle warm conditions for 90 days before spending 3 years in oak barrels maturing, these are very easy drinking Madeiras, with great acidity running throughout.'
)
Producer.create(
    :id => 11,
    :name => 'Cantina Vignaioli',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 12,
    :name => 'Cantarutti',
    :country_id => 110,
    :note => 'The vineyards and winery are now managed by Alfieri daughter Antonella and her husband Fabrizio.'
)
Producer.create(
    :id => 13,
    :name => 'Domaine Moillard',
    :country_id => 76,
    :note => 'The viticultural practice has always been very natural and non invasive for Domaine Moillard wines, allowing the vines to grow deep roots and really show all that the terrior has to offer. Each soil type and terroir change has been accounted for over the years. Different grape varieties have been planted on the best soils for a certain expression. Now even different clones and rootstock types have been taken into consideration so that they are matched with the best possible site.'
)
Producer.create(
    :id => 14,
    :name => 'Idiom',
    :country_id => 206,
    :note => 'The vineyards are located on the foothills of impressive granite mountains overlooking False Bay. The vineyards are at 200-350m above sea level and the soils are composed of decomposed granite which is relatively shallow in places and very stony, on top of a clay base. The vines have deep and complex root systems, taking full advantage of the mineral rich soils.'
)
Producer.create(
    :id => 15,
    :name => 'The Auction Crossing',
    :country_id => 206,
    :note => 'Leon Dippenaar, an ex rugby player, is the winemaker and owner at Auction Crossing. His first vintage at Auction Crossing was in 2004, and he is known for making wines that he enjoys to drink and that are boutique but bold.'
)
Producer.create(
    :id => 16,
    :name => 'Domaine Georges Michel',
    :country_id => 159,
    :note => ''
)
Producer.create(
    :id => 17,
    :name => 'Saint Hilaire d’Ozilhan les Vignerons',
    :country_id => 76,
    :note => ''
)
Producer.create(
    :id => 18,
    :name => 'Il Poggio di Gavi',
    :country_id => 110,
    :note => 'Il Poggio is located in the green and luxuriant Rovereto Hills, in the heart of Gavi DOCG. The vineyards are a south south-west exposure, which allows the vines long sunny days, and are at 330m above sea level – where the soils are rich in sand and clay. The winemaking is simple and clean and unobtrusive, creating a wine that tastes of terroir, and delicate handling.'
)
Producer.create(
    :id => 19,
    :name => 'Louis Sipp',
    :country_id => 76,
    :note => 'Louis Sipp is one of the big names in Alsace, having a long history for producing premium wines stretching back to World War one. Etienne Sipp has just moved to totally organic production. The Louis SIPP parcels of land are situated in the geological fracture zone of Ribeauvillé. They constitute a territory which is geologically highly fragmented. They are above areas with hard chalk, clay and marl from the Liassic and Triassic periods, sandstone clay, and calcareous, chalky conglomerates from the Oligocene period. The area is also characterised by silt-laden deposits, originally loessial, and by glacis and sandy alluvium in the valley and on the plain.'
)
Producer.create(
    :id => 20,
    :name => 'Domaine Vincent Sauvestre',
    :country_id => 76,
    :note => 'Vincent’s family has been firmly established in Meursault for 4 generations. When Vincent, born in 1961, took over the family’s Domaine at the age of 28, it consisted of just 6 hectares in and around Meursault. In 1990 he began his acquisition of vines in Côte Chalonnaise and Côte Maconnais and now has 71 hectares. The Domaine itself was founded when Vincent’s great, great-grandfather was bequeathed a plot of land in Meursault, which is known as the Clos des Tessons. Contrary to New World trends, the wines are not aged at more than 40% of their volume in new oak barrels.'
)
Producer.create(
    :id => 21,
    :name => 'Gróf Degenfeld',
    :country_id => 101,
    :note => ''
)
Producer.create(
    :id => 22,
    :name => 'Carelli',
    :country_id => 11,
    :note => ''
)
Producer.create(
    :id => 23,
    :name => 'Paul Louis Martin',
    :country_id => 76,
    :note => 'The P Louis Martin Champagne house was founded in 1864 in Bouzy by Louis Martin. The family home, the winery, and its deep natural cellars known as Crayeres, are surrounded by 10 hectares of vineyards where the grapes for the wines are grown. No grapes are bought in, allowing complete control over the quality of fruit and in time the quality of the Champagne.'
)
Producer.create(
    :id => 24,
    :name => 'Govone',
    :country_id => 110,
    :note => 'Govone village is situated on the left bank of the Tanaro River, between Asti and Alba. The village community has formed a small co- operative that allows them to make larger volumes of classic wines from their local neighbourhood specializing in Barbera.'
)
Producer.create(
    :id => 25,
    :name => 'Seven Sisters',
    :country_id => 206,
    :note => 'Seven Sisters wine is produced in a climate of warm, breezy summers with temperatures ranging between 25 and 35 degree Celsius and an annual winter rainfall of 500mm, resulting in perfectly ripe grapes for harvest. The wines are made simply so that each wine really reflects the character of the grape and terroir offering a very elegant and honest wine.'
)
Producer.create(
    :id => 26,
    :name => 'Les Barbottes',
    :country_id => 76,
    :note => 'The region of Touraine is in the centre of the Loire Valley, and is famous for the many chateaux. Sauvignon Blanc is also grown in this region and is known for the great mineral flavours that are present due to the unique terroir. The terroir of the Touraine area is a variety of limestone with excellent drainage that is known as tuffeau which is the same material used to build many of the famous Loire Valley Chateaux'
)
Producer.create(
    :id => 27,
    :name => 'Val D\'Oca',
    :country_id => 110,
    :note => 'The Cantina Produttori di Valdobbiadene Val D’Oca is located in the surrounding hills between Conegliano Asolo and Treviso. Established in 1952, the consortium is fully committed to supplying wines of the highest quality.'
)
Producer.create(
    :id => 28,
    :name => 'Finca Cerrada',
    :country_id => 209,
    :note => 'In 1989, the winery and the vineyards were renovated. The red grape varieties were planted and the Viura (Macabeo) vines were radically pruned. This marked the change from a local house wine producer to a sophisticated premium wine producer. The wines are now in their prime 20 years on.'
)
Producer.create(
    :id => 29,
    :name => 'Pedroncelli',
    :country_id => 236,
    :note => 'Since 1927, when John Pedroncelli, Sr. purchased vineyard and a small winery in Sonoma County\'s Dry Creek Valley, two elements remain unchanged: the exceptional place the Pedroncelli family farms vineyards, and the family\'s dedication to making fine wines. From selling grapes to home winemakers during prohibition in order to keep the vineyards going, to growing a small base of business during the 1930s and 1940s, to the second generation joining their father: son John becoming winemaker in 1948 followed by Jim in 1955 as sales director, to 1963 when the winery was officially purchased by John and Jim from their father, to growing the line of wines in the 1960s with vineyard expansion and diversification, to the boom time of the 1970s and 1980s along with many changes and additions to our sales base including national sales and export, the third generation coming on board and vineyard replanting in the 1990s to the 21st century where the fourth generation is coming up the ranks… and it is still a family owned business. It all adds up to tradition, heritage and a family of wines you can enjoy with confidence.'
)
Producer.create(
    :id => 30,
    :name => 'Cantina di Castelnuovo del Garda',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 31,
    :name => 'Castrijo',
    :country_id => 209,
    :note => 'Augusto Ceballos Arce, a young grower from the village of Briñas, in the world-renown Rioja Alavesa region of northern Spain.'
)
Producer.create(
    :id => 32,
    :name => 'Palacio de Sada',
    :country_id => 209,
    :note => 'Bodega de Sada, founded in 1939, is located in the “Baja Montaña” area of Navarre, which is an area of large wine tradition due to its location, climatology and soil.'
)
Producer.create(
    :id => 33,
    :name => 'Caze Blanque',
    :country_id => 76,
    :note => ''
)
Producer.create(
    :id => 34,
    :name => 'Jean de Laroche',
    :country_id => 76,
    :note => 'From grapes in the Languedoc, the wine is made in the Loire Valley by the Bonhomme family'
)
Producer.create(
    :id => 35,
    :name => 'Domaine La Barbotaine',
    :country_id => 76,
    :note => 'The estate is in the district of the village of Crézancy, about 6 miles south-west of Sancerre. The Champault family has produced wines for three generations. Frédéric Champault, the current owner of the winery, follows the tradition of his father, Roland Champault and his grand-father, Louis Champault, who were also winegrowers. Since he has moved to the Barbotaine in 1994 he has worked in the vineyard together with his parents. Frédéric has extended his vineyards by taking over the vineyards of Lucien Dauny, his father-in-law, who is also a winegrower at the Epinières, in the same village.'
)
Producer.create(
    :id => 36,
    :name => 'Evergreen Vineyards',
    :country_id => 236,
    :note => 'Premium Oregon winery – Evergreen vineyards – has it all: great location, in the prestigious Willamette Valley; classic varietals; a proven commitment to sustainability; a renowned winemaker in Laurent Montalieu and if all that wasn’t enough – Evergreen also has its own HK-1, of Howard Hughes fame, commonly known by the moniker, “Spruce Goose”, which is a truly enormous flying cargo ship from the 1940s, part plane part boat, that adorns the “all American” labels. Evergreen’s wines are a proven winner and a great addition to the Amathus list.'
)
Producer.create(
    :id => 37,
    :name => 'Bluebell Vineyard Estates',
    :country_id => 250,
    :note => ''
)
Producer.create(
    :id => 38,
    :name => 'Domaine Marguerite Carillon',
    :country_id => 76,
    :note => 'Domaine Carillon, is one of the stars of the Cote de Beaune and a true specialist in Meursault. The grapes for this wine, are hand picked from vineyards in the heart of Meursault and that have been part of Domaine Carillon for many years. The chardonnay vines are grown on chalk and marl, which gives the wine a typical subtle minerality, which compliment the clean citrus fruit flavours of the wine well.'
)
Producer.create(
    :id => 39,
    :name => 'Manoir du Carra',
    :country_id => 76,
    :note => 'This historic Domaine has been producing Beaujolais wines since 1850. The Domaine stretches over 34 ha divided over many of the Cru Classe villages within Beaujolais. The beautiful vaulted cellar is still the hub of the winery. The Sambadier family have owned Manoir du Carra for many generations and take an active role in the vineyards and in the cellar. The vines are tended to by hand and at harvest the bunches are picked by hand, and sorted on entry to the winery to check the individual grape quality. The wines produced show classic terroir and typicity, and have won many awards around the world.'
)
Producer.create(
    :id => 40,
    :name => 'Domaine Albin Jacumin',
    :country_id => 76,
    :note => 'For over a century, the Albin Jacumin Domain has seen four generations of wine makers successively passing down their passion and pride from father to son. Our domain has evolved, first started by Aimé, it was then passed onto his son Alain who managed, with the support of his wife Sylvette to perpetuate his father’s passion for the noble craft of wine making. They have also extended the estate. Their son Albin and his wife Agnès are now skillfully striving to maintain and modernize the domain.'
)
Producer.create(
    :id => 41,
    :name => 'Fattoria Tregole',
    :country_id => 110,
    :note => 'Fattoria Tregole is a relatively small winery near Castellina in Chianti and produces wines of high quality. The farm overlooks the wavy hills of the Chianti region which is composed of forests, vineyards, olive-groves and a few rural and manor houses which punctuate the landscape.'
)
Producer.create(
    :id => 42,
    :name => 'Carla Chiaro',
    :country_id => 11,
    :note => ''
)
Producer.create(
    :id => 43,
    :name => 'Freixenet',
    :country_id => 209,
    :note => ''
)
Producer.create(
    :id => 44,
    :name => 'Chateau Haut-Mayne',
    :country_id => 76,
    :note => 'This wonderful boutique Sauternes Chateau is located in the heart of Barsac surrounded by world renowned larger Chateaux. There are 3 ha of Semillon and Sauvignon vines which have been tended by Marie Jose Michel and Jean Noel’s family for 3 generations. The berries are painstakingly hand harvested to ensure that only the grapes affected by botrytis are selected, each batch is then fermented separately and carefully aged in both steel and French oak barrels. The blend is then made to achieve a harmonious elegant sweet, but crisp classic sauternes.'
)
Producer.create(
    :id => 45,
    :name => 'Roccapia',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 46,
    :name => 'La Gitana',
    :country_id => 209,
    :note => ''
)
Producer.create(
    :id => 47,
    :name => 'Febe',
    :country_id => 110,
    :note => ''
)
Producer.create(
    :id => 48,
    :name => 'Domaine du Haut Banchereau',
    :country_id => 76,
    :note => 'A family business situated in the heart of the Muscadet since 1870, it is a beautiful 12 hectare estate in the prestigious Muscadet Sevre et Maine appellation on the east slopes of the Sevre Nantaise river.'
)
Producer.create(
    :id => 49,
    :name => 'Comte de la Boisserie',
    :country_id => 76,
    :note => ''
)

puts "Producers ---- OK"

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Region.create(
    :id => 1,
    :country_id => 178,
    :name => 'Douro Valley'
)
Region.create(
    :id => 2,
    :country_id => 15,
    :name => 'Weinviertel'
)
Region.create(
    :id => 3,
    :country_id => 250,
    :name => 'Hampshire'
)
Region.create(
    :id => 4,
    :country_id => 76,
    :name => 'Champagne'
)
Region.create(
    :id => 5,
    :country_id => 14,
    :name => 'Limestone Coast (South Australia)'
)
Region.create(
    :id => 6,
    :country_id => 209,
    :name => 'La Mancha'
)
Region.create(
    :id => 7,
    :country_id => 110,
    :name => 'Piemonte'
)
Region.create(
    :id => 8,
    :country_id => 110,
    :name => 'Sicily'
)
Region.create(
    :id => 9,
    :country_id => 110,
    :name => 'Puglia'
)
Region.create(
    :id => 10,
    :country_id => 178,
    :name => 'Madeira'
)
Region.create(
    :id => 11,
    :country_id => 110,
    :name => 'Tuscany'
)
Region.create(
    :id => 12,
    :country_id => 110,
    :name => 'Friuli'
)
Region.create(
    :id => 13,
    :country_id => 76,
    :name => 'Burgundy'
)
Region.create(
    :id => 14,
    :country_id => 206,
    :name => 'Costal Region (Western Cape)'
)
Region.create(
    :id => 15,
    :country_id => 206,
    :name => 'Breede River Valley'
)
Region.create(
    :id => 16,
    :country_id => 159,
    :name => 'Malborough'
)
Region.create(
    :id => 17,
    :country_id => 76,
    :name => 'Rhône Valley'
)
Region.create(
    :id => 18,
    :country_id => 76,
    :name => 'Alsace'
)
Region.create(
    :id => 19,
    :country_id => 101,
    :name => 'Tokaj'
)
Region.create(
    :id => 20,
    :country_id => 11,
    :name => 'Mendoza'
)
Region.create(
    :id => 21,
    :country_id => 76,
    :name => 'Loire Valley'
)
Region.create(
    :id => 22,
    :country_id => 110,
    :name => 'Veneto'
)
Region.create(
    :id => 23,
    :country_id => 236,
    :name => 'California'
)
Region.create(
    :id => 24,
    :country_id => 110,
    :name => 'Verona'
)
Region.create(
    :id => 25,
    :country_id => 209,
    :name => 'Rioja'
)
Region.create(
    :id => 26,
    :country_id => 209,
    :name => 'Navarra'
)
Region.create(
    :id => 27,
    :country_id => 76,
    :name => 'Languedoc'
)
Region.create(
    :id => 28,
    :country_id => 236,
    :name => 'Oregon'
)
Region.create(
    :id => 29,
    :country_id => 250,
    :name => 'East Sussex'
)
Region.create(
    :id => 30,
    :country_id => 209,
    :name => 'Catalunya'
)
Region.create(
    :id => 31,
    :country_id => 76,
    :name => 'Bordeaux'
)
Region.create(
    :id => 32,
    :country_id => 209,
    :name => 'Andalucía'
)
Region.create(
    :id => 34,
    :country_id => 110,
    :name => 'Abruzzo'
)

puts "Regions ------ OK"

Subregion.create(
    :id => 1,
    :region_id => 1,
    :name => 'Cima Corgo'
)
Subregion.create(
    :id => 2,
    :region_id => 5,
    :name => 'Coonawara'
)
Subregion.create(
    :id => 3,
    :region_id => 7,
    :name => 'Barolo'
)
Subregion.create(
    :id => 4,
    :region_id => 9,
    :name => 'Salento'
)
Subregion.create(
    :id => 5,
    :region_id => 7,
    :name => 'Alba'
)
Subregion.create(
    :id => 6,
    :region_id => 11,
    :name => 'Morellino di Scansano.'
)
Subregion.create(
    :id => 7,
    :region_id => 12,
    :name => 'Colli Orientali'
)
Subregion.create(
    :id => 8,
    :region_id => 13,
    :name => 'Côte de Nuits'
)
Subregion.create(
    :id => 9,
    :region_id => 14,
    :name => 'Stellenbosch'
)
Subregion.create(
    :id => 10,
    :region_id => 15,
    :name => 'Worcester'
)
Subregion.create(
    :id => 11,
    :region_id => 16,
    :name => 'Wairau Valley'
)
Subregion.create(
    :id => 12,
    :region_id => 17,
    :name => 'St Hilare d\'Ozilhan'
)
Subregion.create(
    :id => 13,
    :region_id => 7,
    :name => 'Gavi'
)
Subregion.create(
    :id => 14,
    :region_id => 13,
    :name => 'Chablis'
)
Subregion.create(
    :id => 15,
    :region_id => 19,
    :name => 'Tarcal'
)
Subregion.create(
    :id => 16,
    :region_id => 20,
    :name => 'Rivadavia'
)
Subregion.create(
    :id => 17,
    :region_id => 4,
    :name => 'Bouzy'
)
Subregion.create(
    :id => 18,
    :region_id => 7,
    :name => 'Asti'
)
Subregion.create(
    :id => 19,
    :region_id => 13,
    :name => 'Hautes-Côtes de Nuits'
)
Subregion.create(
    :id => 20,
    :region_id => 21,
    :name => 'Touraine'
)
Subregion.create(
    :id => 21,
    :region_id => 22,
    :name => 'Treviso'
)
Subregion.create(
    :id => 22,
    :region_id => 2,
    :name => 'Roschtiz'
)
Subregion.create(
    :id => 23,
    :region_id => 23,
    :name => 'Northern Sonoma'
)
Subregion.create(
    :id => 24,
    :region_id => 25,
    :name => 'Rioja Alavesa'
)
Subregion.create(
    :id => 25,
    :region_id => 13,
    :name => 'Côte de Beaune'
)
Subregion.create(
    :id => 26,
    :region_id => 26,
    :name => 'Baja Montaña'
)
Subregion.create(
    :id => 27,
    :region_id => 21,
    :name => 'Sancerre'
)
Subregion.create(
    :id => 28,
    :region_id => 28,
    :name => 'Willamette Valley'
)
Subregion.create(
    :id => 29,
    :region_id => 18,
    :name => 'Ribeauville'
)
Subregion.create(
    :id => 30,
    :region_id => 13,
    :name => 'Beaujolais'
)
Subregion.create(
    :id => 31,
    :region_id => 17,
    :name => 'Châteauneuf-du-Pape'
)
Subregion.create(
    :id => 32,
    :region_id => 11,
    :name => 'Chianti'
)
Subregion.create(
    :id => 33,
    :region_id => 31,
    :name => 'Sauternes and Barsac'
)
Subregion.create(
    :id => 34,
    :region_id => 32,
    :name => 'Jerez'
)
Subregion.create(
    :id => 35,
    :region_id => 21,
    :name => 'Muscadet Sèvre-et-Maine'
)
Subregion.create(
    :id => 36,
    :region_id => 21,
    :name => 'Vouvray and Montlouis-sur-Loire'
)

puts "Sub-regions -- OK"

# ------------------------------------------------------------------------------

Appellation.create(
    :id => 1,
    :name => 'Douro Valley',
    :classification => 'DOC',
    :region_id => 1
)
Appellation.create(
    :id => 2,
    :name => 'Weinviertel',
    :classification => 'DAC',
    :region_id => 2
)
Appellation.create(
    :id => 3,
    :name => 'Champagne',
    :classification => 'AOC',
    :region_id => 4
)
Appellation.create(
    :id => 4,
    :name => 'Coonawara',
    :classification => '',
    :region_id => 5
)
Appellation.create(
    :id => 5,
    :name => 'La Mancha',
    :classification => 'DO',
    :region_id => 6
)
Appellation.create(
    :id => 6,
    :name => 'Barolo',
    :classification => 'DOCG',
    :region_id => 7
)
Appellation.create(
    :id => 7,
    :name => 'Barbera D\'Alba',
    :classification => 'DOC',
    :region_id => 7
)
Appellation.create(
    :id => 8,
    :name => 'Sicilia',
    :classification => 'IGT',
    :region_id => 8
)
Appellation.create(
    :id => 9,
    :name => 'Salento',
    :classification => 'IGT',
    :region_id => 8
)
Appellation.create(
    :id => 10,
    :name => 'Madeira',
    :classification => 'DOP',
    :region_id => 10
)
Appellation.create(
    :id => 11,
    :name => 'Morellino di Scansano.',
    :classification => 'DOCG',
    :region_id => 11
)
Appellation.create(
    :id => 12,
    :name => 'Toscana',
    :classification => 'IGT',
    :region_id => 11
)
Appellation.create(
    :id => 13,
    :name => 'Colli Orientali del Friuli',
    :classification => 'DOC',
    :region_id => 12
)
Appellation.create(
    :id => 14,
    :name => 'Côte de Nuits Villages',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 15,
    :name => 'Schioppettino',
    :classification => 'DOC',
    :region_id => 12
)
Appellation.create(
    :id => 16,
    :name => 'Cotes du Rhone',
    :classification => 'AOC',
    :region_id => 17
)
Appellation.create(
    :id => 17,
    :name => 'Gavi di Gavi',
    :classification => 'DOCG',
    :region_id => 7
)
Appellation.create(
    :id => 18,
    :name => 'Alsace',
    :classification => 'AOC',
    :region_id => 18
)
Appellation.create(
    :id => 19,
    :name => 'Chablis',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 20,
    :name => 'Tokaji',
    :classification => '',
    :region_id => 19
)
Appellation.create(
    :id => 21,
    :name => 'Gevrey-Chambertin',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 22,
    :name => 'Barbera D\'Asti',
    :classification => 'DOCG',
    :region_id => 7
)
Appellation.create(
    :id => 23,
    :name => 'Hautes-Côtes de Nuits',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 24,
    :name => 'Touraine',
    :classification => 'AOC',
    :region_id => 21
)
Appellation.create(
    :id => 25,
    :name => 'Prosecco',
    :classification => 'DOC',
    :region_id => 22
)
Appellation.create(
    :id => 26,
    :name => 'Nuits-Saint-Georges Premier Cru Clos des Grandes Vins',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 27,
    :name => 'Rioja',
    :classification => 'DOC',
    :region_id => 25
)
Appellation.create(
    :id => 28,
    :name => 'Chassagne-Montrachet Premier Cru',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 29,
    :name => 'Pays d\'Oc',
    :classification => 'IGP',
    :region_id => 27
)
Appellation.create(
    :id => 30,
    :name => 'Sancerre',
    :classification => 'AOC',
    :region_id => 21
)
Appellation.create(
    :id => 31,
    :name => 'Chablis Premier Cru',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 32,
    :name => 'Kirchberg Grand Cru',
    :classification => 'AOC',
    :region_id => 18
)
Appellation.create(
    :id => 33,
    :name => 'Meursault',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 34,
    :name => 'Moulin-à-Vent',
    :classification => 'AOC',
    :region_id => 13
)
Appellation.create(
    :id => 35,
    :name => 'Châteauneuf-du-Pape',
    :classification => 'AOC',
    :region_id => 17
)
Appellation.create(
    :id => 36,
    :name => 'Chianti Classico',
    :classification => 'DOCG',
    :region_id => 11
)
Appellation.create(
    :id => 37,
    :name => 'Sauternes',
    :classification => 'AOC',
    :region_id => 31
)
Appellation.create(
    :id => 38,
    :name => 'Chianti',
    :classification => 'DOCG',
    :region_id => 11
)
Appellation.create(
    :id => 39,
    :name => 'Jerez',
    :classification => 'DOP',
    :region_id => 32
)
Appellation.create(
    :id => 40,
    :name => 'Muscadet Sèvre-et-Maine',
    :classification => 'AOC',
    :region_id => 21
)
Appellation.create(
    :id => 41,
    :name => 'Dolcetto d\'Alba',
    :classification => 'DOC',
    :region_id => 7
)
Appellation.create(
    :id => 42,
    :name => 'Vouvray',
    :classification => 'AOC',
    :region_id => 21
)

puts "Appellations - OK"

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5 types

types = ['Bold Red', 'Medium Red', 'Light Red', 'Rosé', 'Rich White', 'Dry White', 'Sparkling', 'Sweet White', 'Dessert', 'Fortified']
types.each_with_index do |t, index|
  Type.create(:id => index + 1, :name => t)
end

puts "Types -------- OK"

Vinification.create(
    :id => 1,
    :method => 'grape must to remain in contact with the skins for a short while (just a few hours). Thus the natural pigments in the skins of the black grapes begin to colour the juice and at the same time they enrich the juice with their aromatic components. After maceration, the juices are bled off - hence the name. Bled pink champagnes generally have a more intense pink robe, but this colour can vary widely with different vintages',
    :name => 'Rosé Champagne Saignée'
)
Vinification.create(
    :id => 2,
    :method => 'Winemaking at low temperature (max 27 ° C) with maceration on the skins for 4 days, racking and end of fermentation without the skins. The malolactic fermentation takes place naturally.',
    :name => ''
)
Vinification.create(
    :id => 3,
    :method => 'Fermentation in steel tank',
    :name => ''
)
Vinification.create(
    :id => 4,
    :method => 'Fermentation in temperature-regulated stainless steel fermenters,  Full malolactic fermentation',
    :name => ''
)
Vinification.create(
    :id => 5,
    :method => 'All the different grapes spent 5 days on cold maceration, where after it was fermented in stainless steel tanks at optimal temperatures between 22-28°C. Here after malo-lactic fermentation took place on wood staves in stainless steel tanks',
    :name => ''
)
Vinification.create(
    :id => 6,
    :method => 'Maceration on the grapes occurs at a controlled temperature that varies from 26 till 28°C for about 15/18 days in order to obtain a good extraction of the colour and to keep a good structure able to maintain itself for a long time. When the liquid part separates itself from the solid one, the must is kept in steel tanks for some days for the cleaning.',
    :name => ''
)
Vinification.create(
    :id => 7,
    :method => 'The juice undergoes low temperature alcoholic fermentation in stainless steel tanks, occasional lees stirring depending on vintage and then bottled after 8-10 months.',
    :name => ''
)
Vinification.create(
    :id => 8,
    :method => 'It happens at a controlled temperature (which varies from 18 to 20°C) in steel tanks and continues for quite 16 days.',
    :name => ''
)
Vinification.create(
    :id => 9,
    :method => 'The Viognier was partly fermented in stainless steel tanks and then completed fermentation and malo-lactic in 60% new French oak 225L barrels. Both red varieties received 4 days pre-fermentation cold maceration prior to fermentation in stainless steel tanks. Malolactic fermentation was completed in 70% new oak 225L barrels and matured in these same barrels. The Shiraz and Mourvedre was then blended and matured',
    :name => ''
)
Vinification.create(
    :id => 10,
    :method => 'Charmat (Italian) Method - the second fermentation which causes the bubbles is undertaken in large pressurised steel vats. The wine is bottled in its pressurised form. This is distinguished from the Champagne Method, in which the second fermentation is done in the bottle without any additional pressurisaiton.',
    :name => ''
)
Vinification.create(
    :id => 11,
    :method => 'The grapes are picked when fully ripe, gently crushed and allowed to begin fermentation with their skins. This process is what gives the wine its elegant pink colour. The pink skins are removed when the colour and aromas are judged by the winemaker to be just right. The wine then finishes the fermentation in large modern steel tanks at a cool temperature, which keeps the wine very fresh.',
    :name => ''
)
Vinification.create(
    :id => 12,
    :method => 'It was fermented with a selected burgundy yeast in open fermenters for over a week before being pressed off. It then underwent malolactic fermentation and was racked into French oak barriques.',
    :name => ''
)
Vinification.create(
    :id => 13,
    :method => 'The wine is left to macerate for 20 days, resulting in a rich ruby colour and a complex bouquet of red fruits, spices and truffles.',
    :name => ''
)
Vinification.create(
    :id => 14,
    :method => 'Fermentation takes place in vitrified cement vats at a temperature of approx. 28°C (82°F). Maceration on skins for 18 days with re-circulation carried out three times a day during the first 5 days, and two times a day in the remaining period.',
    :name => ''
)
Vinification.create(
    :id => 15,
    :method => 'The grapes are picked during three or four passes through the vineyards, with a further sorting just before pressing. After being completely destemmed, the grapes are placed in a hand operated basket press, where the juice then runs into cement tanks or barrels. Themacérations is relatively long, and all the wine is ultimately aged in barrel, of which 25% is new each year.',
    :name => ''
)

puts 'Vinifications - OK'

Maturation.create(
    :id => 1,
    :description => '20 years in wooden barrels'
)
Maturation.create(
    :id => 2,
    :description => '10 years in wooden barrels'
)
Maturation.create(
    :id => 3,
    :description => '4 to 6 years in oak casks and steel tanks'
)
Maturation.create(
    :id => 4,
    :description => 'storage in stainless steel tank'
)
Maturation.create(
    :id => 5,
    :description => 'Fermentation in temperature-regulated stainless steel fermenters,  Full malolactic fermentation'
)
Maturation.create(
    :id => 6,
    :description => '12 to 16 months in oak barrels'
)
Maturation.create(
    :id => 7,
    :description => 'aged traditionally in gentle warm conditions for 90 days before spending 3 years in oak barrels maturing'
)
Maturation.create(
    :id => 8,
    :description => 'Stainless steel for 3 months on the lees.'
)
Maturation.create(
    :id => 9,
    :description => 'The wine were then matured separately for 10 months in 45% new 225L French and American oak, before being blended and left to marry for a further 2-4 months.'
)
Maturation.create(
    :id => 10,
    :description => 'The wine is now put directly in new Hungarian 300 litre barrels where it stays for 18 months; during this period the maleolactic fermentation occurs. The wine contained in each barrel is put in an unique mass before the bottling'
)
Maturation.create(
    :id => 11,
    :description => 'Oak Barrels for 2 years'
)
Maturation.create(
    :id => 12,
    :description => 'Natural fermentation using wild yeasts'
)
Maturation.create(
    :id => 13,
    :description => 'No oak'
)
Maturation.create(
    :id => 14,
    :description => 'The must was put in new fine French wood barrels, where it was kept for 14 months. During this period a couple of decantings are done to remove noble dregs and the sediments of the malolactic fermentation that occurred in the meantime'
)
Maturation.create(
    :id => 15,
    :description => 'matured in 40% American and 60% French oak barrel for 12 months.'
)
Maturation.create(
    :id => 16,
    :description => 'Barrel aged for 10 months.'
)
Maturation.create(
    :id => 17,
    :description => 'The traditional oak aging process in Rioja is honoured here, using American white oak barrels for all the wines.'
)
Maturation.create(
    :id => 18,
    :description => '13 months in French Barriques'
)
Maturation.create(
    :id => 19,
    :description => 'Aged on the lees for a minimum of 12 months'
)
Maturation.create(
    :id => 20,
    :description => 'Aged in 70% new French barriques for 18 months'
)
Maturation.create(
    :id => 21,
    :description => '8 months in two-year-old French oak barriques'
)
Maturation.create(
    :id => 22,
    :description => '500L tonneaux and barriques (partly new, partly second and third passage) for approx. 12 months. Malolactic fermentation takes place in vats.'
)

puts 'Maturation - OK'


Locale.create(
    :id => 1,
    :name => 'Gevrey-Chambertin',
    :subregion_id => 8,
    :note => ''
)
Locale.create(
    :id => 2,
    :name => 'Govone',
    :subregion_id => 18,
    :note => ''
)
Locale.create(
    :id => 3,
    :name => 'Monforte d\'Alba',
    :subregion_id => 5,
    :note => ''
)
Locale.create(
    :id => 4,
    :name => 'Lyndoch',
    :subregion_id => 9,
    :note => ''
)
Locale.create(
    :id => 5,
    :name => 'Hex River Valley',
    :subregion_id => 10,
    :note => ''
)
Locale.create(
    :id => 6,
    :name => 'Dry Creek Valley',
    :subregion_id => 23,
    :note => ''
)
Locale.create(
    :id => 7,
    :name => 'Nuits-St-Georges',
    :subregion_id => 8,
    :note => ''
)
Locale.create(
    :id => 8,
    :name => 'Chassagne-Montrachet',
    :subregion_id => 25,
    :note => ''
)
Locale.create(
    :id => 9,
    :name => 'Golden Mile',
    :subregion_id => 11,
    :note => ''
)
Locale.create(
    :id => 10,
    :name => 'Crezancy-en-Sancerre',
    :subregion_id => 27,
    :note => ''
)
Locale.create(
    :id => 11,
    :name => 'McMinnville',
    :subregion_id => 28,
    :note => ''
)
Locale.create(
    :id => 12,
    :name => 'Beauroy',
    :subregion_id => 14,
    :note => 'The Premier Cru Beauroy vineyard is situated on the steep chalky hills to the north of the village on the right bank of the River Serein. The southwest facing slopes of Beauroy allow for the optimum sun exposure and the classic Kimmerdigien clay and chalk soils create a very classic elegant Chablis.'
)
Locale.create(
    :id => 13,
    :name => 'Kirchberg de Ribeauville',
    :subregion_id => 29,
    :note => ''
)
Locale.create(
    :id => 14,
    :name => 'Meursault',
    :subregion_id => 25,
    :note => ''
)
Locale.create(
    :id => 15,
    :name => 'Moulin-à-Vent',
    :subregion_id => 30,
    :note => ''
)
Locale.create(
    :id => 16,
    :name => 'Classico',
    :subregion_id => 32,
    :note => ''
)
Locale.create(
    :id => 17,
    :name => 'Barsac',
    :subregion_id => 33,
    :note => ''
)
Locale.create(
    :id => 18,
    :name => 'Sanlúcar de Barrameda',
    :subregion_id => 34,
    :note => ''
)

puts 'Locale - OK'

Grape.create(
    :id => 1,
    :name => 'Alicante'
)
Grape.create(
    :id => 2,
    :name => 'Bacchus'
)
Grape.create(
    :id => 3,
    :name => 'Barbera'
)
Grape.create(
    :id => 4,
    :name => 'bourboulenc'
)
Grape.create(
    :id => 5,
    :name => 'Cabernet'
)
Grape.create(
    :id => 6,
    :name => 'Cabernet Franc'
)
Grape.create(
    :id => 7,
    :name => 'Cabernet Sauvignon'
)
Grape.create(
    :id => 8,
    :name => 'Chardonnay'
)
Grape.create(
    :id => 9,
    :name => 'Chenin Blanc'
)
Grape.create(
    :id => 10,
    :name => 'Ciliegiolo'
)
Grape.create(
    :id => 11,
    :name => 'Cinsault'
)
Grape.create(
    :id => 12,
    :name => 'clairette'
)
Grape.create(
    :id => 13,
    :name => 'Cortese'
)
Grape.create(
    :id => 14,
    :name => 'Dolcetto'
)
Grape.create(
    :id => 15,
    :name => 'Furmint'
)
Grape.create(
    :id => 16,
    :name => 'Gamay'
)
Grape.create(
    :id => 17,
    :name => 'Garnacha'
)
Grape.create(
    :id => 18,
    :name => 'Gewürztraminer'
)
Grape.create(
    :id => 19,
    :name => 'Glera'
)
Grape.create(
    :id => 20,
    :name => 'Grenache'
)
Grape.create(
    :id => 21,
    :name => 'Grillo'
)
Grape.create(
    :id => 22,
    :name => 'Gruner Veltliner'
)
Grape.create(
    :id => 23,
    :name => 'Hárslevelű'
)
Grape.create(
    :id => 24,
    :name => 'Macabeo'
)
Grape.create(
    :id => 25,
    :name => 'Malbec'
)
Grape.create(
    :id => 26,
    :name => 'Melon de Bourgogne'
)
Grape.create(
    :id => 27,
    :name => 'Merlot'
)
Grape.create(
    :id => 28,
    :name => 'Montepulciano'
)
Grape.create(
    :id => 29,
    :name => 'Mourvedre'
)
Grape.create(
    :id => 30,
    :name => 'Mouverdre'
)
Grape.create(
    :id => 31,
    :name => 'Muscat de Lunel'
)
Grape.create(
    :id => 32,
    :name => 'Muscat Lunel'
)
Grape.create(
    :id => 33,
    :name => 'Nebbiolo'
)
Grape.create(
    :id => 34,
    :name => 'Palomino Fino'
)
Grape.create(
    :id => 35,
    :name => 'Parellada'
)
Grape.create(
    :id => 36,
    :name => 'Petite Syrah'
)
Grape.create(
    :id => 37,
    :name => 'Pinor Meunier'
)
Grape.create(
    :id => 38,
    :name => 'Pinot Blanc'
)
Grape.create(
    :id => 39,
    :name => 'Pinot Grigio'
)
Grape.create(
    :id => 40,
    :name => 'Pinot Gris'
)
Grape.create(
    :id => 41,
    :name => 'Pinot Meunier'
)
Grape.create(
    :id => 42,
    :name => 'Pinot Noir'
)
Grape.create(
    :id => 43,
    :name => 'Pinot Noir Wine'
)
Grape.create(
    :id => 44,
    :name => 'Pinotage'
)
Grape.create(
    :id => 45,
    :name => 'Primitivo'
)
Grape.create(
    :id => 46,
    :name => 'Reichensteiner'
)
Grape.create(
    :id => 47,
    :name => 'Ribolla Gialla'
)
Grape.create(
    :id => 48,
    :name => 'Riesling'
)
Grape.create(
    :id => 49,
    :name => 'Rondo'
)
Grape.create(
    :id => 50,
    :name => 'Roussane'
)
Grape.create(
    :id => 51,
    :name => 'Sangiovese'
)
Grape.create(
    :id => 52,
    :name => 'Sauvignon Blanc'
)
Grape.create(
    :id => 53,
    :name => 'Schioppettino'
)
Grape.create(
    :id => 54,
    :name => 'Semillon'
)
Grape.create(
    :id => 55,
    :name => 'Sémillon'
)
Grape.create(
    :id => 56,
    :name => 'Seyval'
)
Grape.create(
    :id => 57,
    :name => 'Syrah'
)
Grape.create(
    :id => 58,
    :name => 'Tempranillo'
)
Grape.create(
    :id => 59,
    :name => 'Tinta Negra Mole'
)
Grape.create(
    :id => 60,
    :name => 'Viognier'
)
Grape.create(
    :id => 61,
    :name => 'Xarel-lo'
)
Grape.create(
    :id => 62,
    :name => 'Zinfandel'
)
Grape.create(
    :id => 63,
    :name => 'Grolleau'
)
Grape.create(
    :id => 64,
    :name => 'Port Blend'
)

Grape.create(
    :id => 65,
    :name => 'White Port Bland'
)



puts "Grapes ------- OK"

Composition.create(:id => 1)
CompositionGrape.create(:composition_id => 1, :grape_id => 22, :percentage => 100 )
Composition.create(:id => 2)
CompositionGrape.create(:composition_id => 2, :grape_id => 56, :percentage => nil )
CompositionGrape.create(:composition_id => 2, :grape_id => 2, :percentage => nil )
CompositionGrape.create(:composition_id => 2, :grape_id => 46, :percentage => nil )
Composition.create(:id => 3)
CompositionGrape.create(:composition_id => 3, :grape_id => 8, :percentage => 40 )
CompositionGrape.create(:composition_id => 3, :grape_id => 42, :percentage => 57 )
CompositionGrape.create(:composition_id => 3, :grape_id => 41, :percentage => 3 )
Composition.create(:id => 4, :name => 'Bordeaux white')
CompositionGrape.create(:composition_id => 4, :grape_id => 54, :percentage => nil )
CompositionGrape.create(:composition_id => 4, :grape_id => 52, :percentage => nil )
Composition.create(:id => 5)
CompositionGrape.create(:composition_id => 5, :grape_id => 58, :percentage => nil )
CompositionGrape.create(:composition_id => 5, :grape_id => 7, :percentage => nil )
Composition.create(:id => 6, :name => 'Barolo style')
CompositionGrape.create(:composition_id => 6, :grape_id => 33, :percentage => 100 )
Composition.create(:id => 7)
CompositionGrape.create(:composition_id => 7, :grape_id => 3, :percentage => 100 )
Composition.create(:id => 8)
CompositionGrape.create(:composition_id => 8, :grape_id => 21, :percentage => 100 )
Composition.create(:id => 9)
CompositionGrape.create(:composition_id => 9, :grape_id => 45, :percentage => 100 )
Composition.create(:id => 10, :name => 'Champagne Blend')
CompositionGrape.create(:composition_id => 10, :grape_id => 8, :percentage => nil )
CompositionGrape.create(:composition_id => 10, :grape_id => 42, :percentage => nil )
CompositionGrape.create(:composition_id => 10, :grape_id => 41, :percentage => nil )
Composition.create(:id => 11, :name => 'Rosé Champagne Blend')
CompositionGrape.create(:composition_id => 11, :grape_id => 8, :percentage => nil )
CompositionGrape.create(:composition_id => 11, :grape_id => 42, :percentage => nil )
CompositionGrape.create(:composition_id => 11, :grape_id => 41, :percentage => nil )
Composition.create(:id => 12, :name => 'Tuscan')
CompositionGrape.create(:composition_id => 12, :grape_id => 51, :percentage => 100 )
Composition.create(:id => 13, :name => 'Tinta Negra Maderia')
CompositionGrape.create(:composition_id => 13, :grape_id => 59, :percentage => 100 )
Composition.create(:id => 14, :name => 'Tuscan IGT blend')
CompositionGrape.create(:composition_id => 14, :grape_id => 51, :percentage => 75 )
CompositionGrape.create(:composition_id => 14, :grape_id => 1, :percentage => nil )
CompositionGrape.create(:composition_id => 14, :grape_id => 10, :percentage => nil )
CompositionGrape.create(:composition_id => 14, :grape_id => 27, :percentage => nil )
CompositionGrape.create(:composition_id => 14, :grape_id => 5, :percentage => nil )
CompositionGrape.create(:composition_id => 14, :grape_id => 57, :percentage => nil )
Composition.create(:id => 15, :name => 'Ribolla Gialla')
CompositionGrape.create(:composition_id => 15, :grape_id => 47, :percentage => 100 )
Composition.create(:id => 16, :name => 'White Burgundy Style')
CompositionGrape.create(:composition_id => 16, :grape_id => 8, :percentage => 100 )
Composition.create(:id => 17, :name => 'Cape Blend')
CompositionGrape.create(:composition_id => 17, :grape_id => 7, :percentage => nil )
CompositionGrape.create(:composition_id => 17, :grape_id => 44, :percentage => nil )
CompositionGrape.create(:composition_id => 17, :grape_id => 27, :percentage => nil )
Composition.create(:id => 18, :name => 'Cote Rotie style Syrah Viognier Blend')
CompositionGrape.create(:composition_id => 18, :grape_id => 57, :percentage => 93 )
CompositionGrape.create(:composition_id => 18, :grape_id => 60, :percentage => 7 )
Composition.create(:id => 19)
CompositionGrape.create(:composition_id => 19, :grape_id => 52, :percentage => 100 )
Composition.create(:id => 20, :name => 'Schioppettino')
CompositionGrape.create(:composition_id => 20, :grape_id => 53, :percentage => 100 )
Composition.create(:id => 21, :name => 'Cotes du Rhone blend')
CompositionGrape.create(:composition_id => 21, :grape_id => 57, :percentage => nil )
CompositionGrape.create(:composition_id => 21, :grape_id => 20, :percentage => nil )
CompositionGrape.create(:composition_id => 21, :grape_id => 11, :percentage => nil )
Composition.create(:id => 22, :name => 'Gavi style')
CompositionGrape.create(:composition_id => 22, :grape_id => 13, :percentage => 100 )
Composition.create(:id => 23)
CompositionGrape.create(:composition_id => 23, :grape_id => 48, :percentage => 100 )
Composition.create(:id => 24, :name => 'Tokaji Aszú')
CompositionGrape.create(:composition_id => 24, :grape_id => 15, :percentage => nil )
CompositionGrape.create(:composition_id => 24, :grape_id => 23, :percentage => nil )
CompositionGrape.create(:composition_id => 24, :grape_id => 31, :percentage => nil )
Composition.create(:id => 25)
CompositionGrape.create(:composition_id => 25, :grape_id => 25, :percentage => 100 )
Composition.create(:id => 26, :name => 'Blanc de Blancs')
CompositionGrape.create(:composition_id => 26, :grape_id => 8, :percentage => 100 )
Composition.create(:id => 27, :name => 'Red Burgundy')
CompositionGrape.create(:composition_id => 27, :grape_id => 42, :percentage => 100 )
Composition.create(:id => 28)
CompositionGrape.create(:composition_id => 28, :grape_id => 39, :percentage => 100 )
Composition.create(:id => 29, :name => 'LIrac style Rhône Blend')
CompositionGrape.create(:composition_id => 29, :grape_id => 57, :percentage => nil )
CompositionGrape.create(:composition_id => 29, :grape_id => 30, :percentage => nil )
CompositionGrape.create(:composition_id => 29, :grape_id => 60, :percentage => nil )
Composition.create(:id => 30, :name => 'Bouzy Champagne Rose')
CompositionGrape.create(:composition_id => 30, :grape_id => 42, :percentage => 75 )
CompositionGrape.create(:composition_id => 30, :grape_id => 8, :percentage => 10 )
CompositionGrape.create(:composition_id => 30, :grape_id => 43, :percentage => 15 )
Composition.create(:id => 31, :name => 'Cotes du Rhône Blanc Roussane')
CompositionGrape.create(:composition_id => 31, :grape_id => 50, :percentage => 100 )
Composition.create(:id => 32)
CompositionGrape.create(:composition_id => 32, :grape_id => 60, :percentage => 100 )
Composition.create(:id => 33)
CompositionGrape.create(:composition_id => 33, :grape_id => 62, :percentage => 100 )
Composition.create(:id => 34, :name => 'Prosecco')
CompositionGrape.create(:composition_id => 34, :grape_id => 19, :percentage => 100 )
Composition.create(:id => 35)
CompositionGrape.create(:composition_id => 35, :grape_id => 58, :percentage => 100 )
Composition.create(:id => 36, :name => 'Pedroncelli Friends Red Blend')
CompositionGrape.create(:composition_id => 36, :grape_id => 27, :percentage => nil )
CompositionGrape.create(:composition_id => 36, :grape_id => 57, :percentage => nil )
CompositionGrape.create(:composition_id => 36, :grape_id => 62, :percentage => nil )
CompositionGrape.create(:composition_id => 36, :grape_id => 36, :percentage => nil )
Composition.create(:id => 37)
CompositionGrape.create(:composition_id => 37, :grape_id => 24, :percentage => 100 )
Composition.create(:id => 38, :name => 'Champagne Brut')
CompositionGrape.create(:composition_id => 38, :grape_id => 42, :percentage => 50 )
CompositionGrape.create(:composition_id => 38, :grape_id => 8, :percentage => 50 )
Composition.create(:id => 39)
CompositionGrape.create(:composition_id => 39, :grape_id => 17, :percentage => 100 )
Composition.create(:id => 40)
CompositionGrape.create(:composition_id => 40, :grape_id => 7, :percentage => 100 )
Composition.create(:id => 41)
CompositionGrape.create(:composition_id => 41, :grape_id => 27, :percentage => 100 )
Composition.create(:id => 42)
CompositionGrape.create(:composition_id => 42, :grape_id => 40, :percentage => 100 )
Composition.create(:id => 43, :name => 'Tokaji Hárslevelű')
CompositionGrape.create(:composition_id => 43, :grape_id => 23, :percentage => 100 )
Composition.create(:id => 44)
CompositionGrape.create(:composition_id => 44, :grape_id => 15, :percentage => 100 )
Composition.create(:id => 45)
CompositionGrape.create(:composition_id => 45, :grape_id => 32, :percentage => 100 )
Composition.create(:id => 46, :name => 'Rosé Champagne Blend')
CompositionGrape.create(:composition_id => 46, :grape_id => 42, :percentage => 69 )
CompositionGrape.create(:composition_id => 46, :grape_id => 37, :percentage => 31 )
Composition.create(:id => 47, :name => 'Classic Cuvee Blend')
CompositionGrape.create(:composition_id => 47, :grape_id => 42, :percentage => 31 )
CompositionGrape.create(:composition_id => 47, :grape_id => 37, :percentage => 21 )
CompositionGrape.create(:composition_id => 47, :grape_id => 8, :percentage => 48 )
Composition.create(:id => 48)
CompositionGrape.create(:composition_id => 48, :grape_id => 49, :percentage => nil )
CompositionGrape.create(:composition_id => 48, :grape_id => 42, :percentage => nil )
Composition.create(:id => 49)
CompositionGrape.create(:composition_id => 49, :grape_id => 7, :percentage => nil )
CompositionGrape.create(:composition_id => 49, :grape_id => 27, :percentage => nil )
Composition.create(:id => 50, :name => 'Cabernet Bordeaux Blend')
CompositionGrape.create(:composition_id => 50, :grape_id => 7, :percentage => nil )
CompositionGrape.create(:composition_id => 50, :grape_id => 27, :percentage => nil )
CompositionGrape.create(:composition_id => 50, :grape_id => 6, :percentage => nil )
Composition.create(:id => 51)
CompositionGrape.create(:composition_id => 51, :grape_id => 42, :percentage => 100 )
Composition.create(:id => 52)
CompositionGrape.create(:composition_id => 52, :grape_id => 18, :percentage => 100 )
Composition.create(:id => 53)
CompositionGrape.create(:composition_id => 53, :grape_id => 38, :percentage => 100 )
Composition.create(:id => 54)
CompositionGrape.create(:composition_id => 54, :grape_id => 16, :percentage => 100 )
Composition.create(:id => 55, :name => 'Châteauneuf-du-Pape')
CompositionGrape.create(:composition_id => 55, :grape_id => 20, :percentage => 70 )
CompositionGrape.create(:composition_id => 55, :grape_id => 29, :percentage => 15 )
CompositionGrape.create(:composition_id => 55, :grape_id => 57, :percentage => 12 )
CompositionGrape.create(:composition_id => 55, :grape_id => 11, :percentage => 3 )
Composition.create(:id => 56)
CompositionGrape.create(:composition_id => 56, :grape_id => 24, :percentage => nil )
CompositionGrape.create(:composition_id => 56, :grape_id => 61, :percentage => nil )
CompositionGrape.create(:composition_id => 56, :grape_id => 35, :percentage => nil )
Composition.create(:id => 57, :name => 'Sauternes Sémillon 85')
CompositionGrape.create(:composition_id => 57, :grape_id => 55, :percentage => 85 )
CompositionGrape.create(:composition_id => 57, :grape_id => 52, :percentage => 15 )
Composition.create(:id => 58, :name => 'Sherry')
CompositionGrape.create(:composition_id => 58, :grape_id => 34, :percentage => nil )
Composition.create(:id => 59, :name => 'White Chateauneuf-du-Pape')
CompositionGrape.create(:composition_id => 59, :grape_id => 12, :percentage => 30 )
CompositionGrape.create(:composition_id => 59, :grape_id => 20, :percentage => 60 )
CompositionGrape.create(:composition_id => 59, :grape_id => 4, :percentage => 10 )
Composition.create(:id => 60)
CompositionGrape.create(:composition_id => 60, :grape_id => 28, :percentage => 100 )
Composition.create(:id => 61, :name => 'Muscadet')
CompositionGrape.create(:composition_id => 61, :grape_id => 26, :percentage => 100 )
Composition.create(:id => 62)
CompositionGrape.create(:composition_id => 62, :grape_id => 14, :percentage => 100 )
Composition.create(:id => 63)
CompositionGrape.create(:composition_id => 63, :grape_id => 9, :percentage => 100 )
Composition.create(:id => 64, :name => 'Cremant de Loire Blend')
CompositionGrape.create(:composition_id => 64, :grape_id => 9, :percentage => nil )
CompositionGrape.create(:composition_id => 64, :grape_id => 8, :percentage => nil )
Composition.create(:id => 65, :name => 'Cremant de Loire Blend')
CompositionGrape.create(:composition_id => 65, :grape_id => 6, :percentage => 100 )
Composition.create(:id => 66)
CompositionGrape.create(:composition_id => 66, :grape_id => 63, :percentage => nil )
Composition.create(:id => 67, :name => 'Port Blend')
CompositionGrape.create(:composition_id => 67, :grape_id => 64, :percentage => nil )
Composition.create(:id => 68, :name => 'White Port Bland')
CompositionGrape.create(:composition_id => 68, :grape_id => 65, :percentage => nil )

puts 'Compositions - OK'

wine_and_inventory_file_path = File.dirname(__FILE__) + '/wine_seed.csv'

include WineImporter

import_wines(wine_and_inventory_file_path)

puts 'Wines ---- OK'



warehouse_address1 = Address.create!(
    :street => '7-19 Leadenhall Market',
    :postcode => 'EC3V 1LR'
)

warehouse_one = Warehouse.create!(
    :title => 'Amathus City',
    :email => 'AmathusCity@vynz.co',
    :phone => '0207 283 0638',
    :shutl => true,
    :address => warehouse_address1
)

warehouse_address2 = Address.create!(
    :street => 'Hammer House, 113-117 Wardour Street',
    :postcode => 'W1F 0UN'
)

warehouse_two = Warehouse.create!(
    :title => 'Amathus Soho',
    :email => 'AmathusSoho@vynz.co',
    :phone => '0207 287 5769',
    :shutl => true,
    :address => warehouse_address2
)

warehouse_address3 = Address.create!(
    :street => '203 Brompton Road,',
    :postcode => 'SW3 1LA'
)

warehouse_three = Warehouse.create!(
    :title => 'Amathus Knightsbridge',
    :email => 'AmathusKnightsbridge@vynz.co',
    :phone => '0207 745 7477',
    :shutl => true,
    :address => warehouse_address3
)

puts 'Warehouses - OK'

include InventoryImporter

import_inventory(wine_and_inventory_file_path, warehouse_one)
import_inventory(wine_and_inventory_file_path, warehouse_two)
import_inventory(wine_and_inventory_file_path, warehouse_three)

puts 'Inventories ---- OK'



#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 7 users

names = ["Frodo", "Samwise", "Peregrin", "Meriadoc", "Gandalf", "Aragorn Elessar", "Elrond"]
surnames = ["Baggins", "Gamgee", "Took", "Brandibuck", "Greyhame", "Telcontar", "Half-elven"]
emails = ["frodo@bagend.sh", "mayor@hobbiton.gov", "pippin@took.tl", "merry@rohan.mil.rh", "gd_mofo_wizard@istari.vl", "strider@rangers.org", "elrond@gov.im"]

for j in 0..6 do
  dummyUser = User.new(
               :first_name => names[j],
                :last_name => surnames[j],
                    :email => emails[j],
                   :mobile => "011111111#{j}",
                 :password => "#Wines1234",
    :password_confirmation => "#Wines1234"
  )
  dummyUser.add_role(:client)
  dummyUser.active = true
  dummyUser.save
end

puts "Users -------- OK"

(0..6).each { |j|
  payment = Payment.new(
      :user_id => j+2,
      :brand => 1,
      :number => '1111',
      :stripe => 'cus_4uQiP8ZhPAKXoa'
  )
  payment.save
}

puts 'Payment --- OK'

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 10 addresses

postcodes = ["EC1N8DL","SE11DN","W85ED", "W148TD", "W60SP", "SW151RT", "SW113JS", "SW61NL", "W113HG", "W114UA"]
streets = ["Hatton Garden","Elephant Rd","Kensington High Street", "North End Crescent", "King St", "Putney High Street", "Battersea High Street", "North End Road", "Pembridge Road", "Holland Park Avenue"]
numbers = ["33-34","Castle Industrial Estate","45", "30", "284/286", "161", "155", "244", "19", "116"]

for j in 0..9 do
  Address.create(
      :street => streets[j],
      :detail => numbers[j],
    :postcode => postcodes[j]
  )
end

puts "Addresses ---- OK"


allUsers = User.all
j=3
allUsers.each do |user|
  unless user.id == 1
    AddressesUsers.create(
      :address_id => j,
         :user_id => user.id
    )
    j += 1
  end
end


#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Agendas
# for i in 0..6 do
#   Agenda.create(
#     :warehouse_id => 1,
#              :day => i,
#          :opening =>  800,
#          :closing => 1900
#   )
# end
# for i in 0..6 do
#   Agenda.create(
#     :warehouse_id => 2,
#              :day => i,
#          :opening =>  900,
#          :closing => 2030
#   )
# end

# puts "Agendas ------ OK"


#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Orders!!!

totalOrders = 30

for i in 0..totalOrders do
  # 1 pending
  # 2 paid
  # 3 payment failed
  # 4 pickup
  # 5 delivery
  # 6 delivered
  # 7 cancelled
  status = 1+rand(7)
  warehouse = nil
  case status
    when 3
      status = 1
  end

  if status > 3
    warehouse = 1+rand(2)
  end

  warehouseRand = rand(3)


  if warehouseRand == 0
    warehouses = { :warehouses => [{ :id => 1, :distance => 1.914 }] }
  elsif warehouseRand == 1
    warehouses = { :warehouses => [{ :id => 2, :distance => 2.123 }] }
  else
    warehouses = { :warehouses => [{ :id => 1, :distance => 1.914 },{ :id => 2, :distance => 2.123 }] }
  end


  total_order_items = 1 + rand(2)
  order_items = Array.new
  category = 1 + rand(4)

  case category
    when 1
      category = @house
    when 2
      category = @reserve
    when 3
      category = @fine
    when 4
      category = @cellar
  end


  total_order_items.times do
    new_item = OrderItem.create({quantity: 1 + rand(2), category: category})
    order_items << new_item
    FoodItem.create!(:food => @food_one, :preparation => @preparation, :order_item => new_item)
  end

  client_id = 2+rand(7)
  Order.create(
    :warehouse_id => warehouse,
    :client_id => client_id,
    :address_id => 4+rand(4),
    :status_id => status,
    :information => warehouses.to_json,
    :order_items => order_items,
    :payment_id => client_id - 1
  )

end

puts "Orders ------- OK"

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


puts "Occasions ------- OK"
