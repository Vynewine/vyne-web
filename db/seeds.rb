# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Countries list:
# Ref:
# http://stefangabos.ro/other-projects/list-of-world-countries-with-national-flags/#download

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
  ('Zimbabwe', 'zw', 'zwe')"

# Default roles:
Role.create(:name => 'client')
Role.create(:name => 'supplier')
Role.create(:name => 'advisor')
Role.create(:name => 'admin')
Role.create(:name => 'superadmin')

# Default order statuses:
Status.create(:label => 'new')
Status.create(:label => 'waiting for call')
Status.create(:label => 'waiting for message')
Status.create(:label => 'paying')
Status.create(:label => 'paid')
Status.create(:label => 'waiting for delivery')
Status.create(:label => 'delivered')
Status.create(:label => 'cancelled')

# Default user:
User.create!({
  :name => 'Gian',
  :email => "gm@rockstardev.co",
  :mobile => "0111111111",
  :password => "#Wines1234",
  :password_confirmation => "#Wines1234"
})

defaultUser = User.find_by(id: 1)
defaultUser.add_role(:superadmin)
defaultUser.active = true
defaultUser.save


Category.create(
              :name => "label",
             :price => 15,
  :restaurant_price => "20-40",
       :description => "<p>The entry-level product from the same top wineries supplying the best restaurants</p><p>Same painstaking production - only more accesible</p>"
)

Category.create(
              :name => "reserve",
             :price => 20,
  :restaurant_price => "40-55",
       :description => "<p>Reserve wines are made by top independent producers</p><p>Their vineyards are in the best parcels of famous wine territories</p>"
)

Category.create(
              :name => "fine",
             :price => 30,
  :restaurant_price => "200000",
       :description => "<p>Yadyadya</p><p>duh duh duh</p>"
)

Category.create(
              :name => "cellar",
             :price => 50,
  :restaurant_price => "500000",
       :description => "<p>Yadyadya</p><p>duh duh duh</p>"
)

# ------------------------------------------------------------------------------
# DUMMY DATA

appelations = ["Abruzzo", "Matera", "Bivongi", "Cirò", "Pollino", "Cilento", "Taburno",
  "Lambrusco di Sorbara", "Carso", "Atina", "Frascati", "Marinoorvieto", "Cinque Terre",
  "Casteggio", "Oltrepò Pavese", "Biferno", "Fara", "Pinerolese", "Alezio", "Leverano",
  "Girò di Cagliari", "Etna", "Orcia", "Sovana", "Montefalco", "Valle d'Aosta",
  "Valpolicella", "Valpolicella Ripasso"]
# 28 appellations

appelations.each do |appelationName|
  Appellation.create(:name => appelationName)
end


#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5 producers

# 15 Austria, 32 Brazil, 45 Chile, 76 France, 110 Italy, 159 New Zealand, 206 SA

countries = [110,76,159,15,45,206,32]
num = ["One", "Two", "Three", "Four", "Five"]
num.each do |n|
  cCountry = rand(7)
  if rand(3)==1 # 0 1
    cCountry = rand(2)
  elsif rand(5)==1 #2 3 4
    cCountry = 2 + rand(3)
  end
  Producer.create(:name => "Producer #{n}", :country_id => countries[cCountry])
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5 types

types = ["red", "white", "sparkling", "sweet", "port"]
types.each do |t|
  Type.create(:name => t)
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 10 food types

foods = ["steak", "pasta", "pizza", "fish", "chicken", "boar", "giraffe", "letuce", "chocolate", "ice cream"]
foods.each do |f|
  Food.create(:name => f)
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 25 wines

for j in 1..5 do
  for i in 1..5 do
    Wine.create(
                  :name => "Random #{j}-#{i}",
               :vintage => 2000 + i,
                  :area => "Random",
         :single_estate => i%2,
               :alcohol => i+2,
                 :sugar => i*2,
               :acidity => 2,
                    :ph => 3,
            :vegetarian => i%2,
                 :vegan => i%2,
               :organic => i%2,
           :producer_id => j,
          # :subregion_id => 0,
        :appellation_id => j*i,
         :maturation_id => 1
    )
  end
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 6 notes

notes = ["oak", "plum", "earth", "caramel", "herbs", "spices"]
notes.each do |n|
  Note.create(:name => n)
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Grapes
grapes = [
  # 24 Red grapes
"Barbera",
"Brunello",
"Cabernet Franc",
"Cabernet Sauvignon",
"Carignan/Carignane",
"Carmenere",
"Charbono",
"Cinsault",
"Concord",
"Dolcetto",
"Gamay",
"Grenache",
"Malbec",
"Merlot",
"Mourvedre",
"Nebbiolo",
"Petite Sirah",
"Pinot Noir",
"Pinotage",
"Sangiovese",
"Syrah/Shiraz",
"Tempranillo",
"Zinfandel",
"Zweigelt",
  # 17 White grapes
"Airen",
"Aligote",
"Chardonnay",
"Chenin Blanc",
"Fume Blanc",
"Gewurztraminer",
"Gruner Veltliner",
"Muscat",
"Niagara",
"Pinot Blanc",
"Pinot Gris/Pinot Grigio",
"Riesling",
"Sauvignon Blanc",
"Semillon",
"Seyval",
"Trebbiano/Ugni Blanc",
"Viognier"]

grapes.each do |grape|
  Grape.create(:name => grape)
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Types  - wines
# Notes  - wines
# Grapes - wines

reds = 24
whites = 17

allWines = Wine.all
allWines.each do |wine|
  
  randomType = 1 + rand(5)
  randomNote = 1 + rand(6)
  grape1     = 1 + rand(41)
  grape2     = 0
  grape3     = 0
  allGrapes  = 1 + rand(3)

  loop do
    if grape1 < reds
      grape2 = 1 + rand(reds)
      grape3 = 1 + rand(reds)
    else
      grape2 = 1 + rand(whites)
      grape3 = 1 + rand(whites)
    end
    break if grape1 != grape2 && grape2 != grape3
  end

  if allGrapes == 1
    Composition.create(:wine_id => wine.id, :grape_id => grape1, :quantity => 100)
  elsif allGrapes == 2
    Composition.create(:wine_id => wine.id, :grape_id => grape1, :quantity => 50)
    Composition.create(:wine_id => wine.id, :grape_id => grape2, :quantity => 50)
  else
    Composition.create(:wine_id => wine.id, :grape_id => grape1, :quantity => 50)
    Composition.create(:wine_id => wine.id, :grape_id => grape2, :quantity => 30)
    Composition.create(:wine_id => wine.id, :grape_id => grape3, :quantity => 20)
  end

  # ["red", "white", "sparkling", "sweet", "port"]
  if grape1 < reds
    TypesWines.create(:wine_id => wine.id, :type_id => 1)
  else
    TypesWines.create(:wine_id => wine.id, :type_id => 2)
  end
  if rand(2) == 1
    TypesWines.create(:wine_id => wine.id, :type_id => 3 + rand(3))    
  end

  note1 = 1 + rand(6)
  note2 = 0
  loop do
    note2 = 1 + rand(6)
    break if note1 != note2
  end
  NotesWines.create(:wine_id => wine.id, :note_id => note1)
  if rand(2) == 1
    NotesWines.create(:wine_id => wine.id, :note_id => note2)
  end
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 7 users
users = ["Frodo Baggins", "Samwise Gamgee", "Peregrin Took", "Meriadoc Brandibuck", "Gandalf Greyhame", "Aragorn Elessar Telcontar", "Elrond Half-elven"]
emails = ["frodo@bagend.sh", "mayor@hobbiton.gov", "pippin@took.tl", "merry@rohan.mil.rh", "gd_mofo_wizard@istari.vl", "strider@rangers.org", "elrond@gov.im"]

for j in 0..6 do
  dummyUser = User.new(
                     :name => users[j],
                    :email => emails[j],
                   :mobile => "011111111#{j}",
                 :password => "#Wines1234",
    :password_confirmation => "#Wines1234"
  )
  dummyUser.add_role(:client)
  dummyUser.active = true
  dummyUser.save
end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 8 addresses

postcodes = ["W85ED", "W148TD", "W60SP", "SW151RT", "SW113JS", "SW61NL", "W113HG", "W114UA"]
streets = ["Kensington High Street", "North End Crescent", "King St", "Putney High Street", "Battersea High Street", "North End Road", "Pembridge Road", "Holland Park Avenue"]
numbers = ["45", "30", "284/286", "161", "155", "244", "19", "116"]

for j in 0..7 do
  Address.create(
      :street => streets[j],
      :detail => numbers[j],
    :postcode => postcodes[j]
  )
end

