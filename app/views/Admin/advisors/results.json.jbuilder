json.array!(@results) do |wine|
    json.countryCode wine.producer.country.alpha_2
    json.countryName wine.producer.country.name
      json.subregion wine.subregion.nil? ? '' : wine.subregion.name
       # json.producer wine.producer.name
    json.appellation wine.appellation.name
           json.name wine.name
        json.vintage wine.vintage
          json.types wine.types.map {|t| t.name}
   json.compositions wine.compositions_array
  json.single_estate wine.single_estate
          json.notes wine.notes.map {|n| n.name}
     json.vegetarian wine.vegetarian
          json.vegan wine.vegan
        json.organic wine.organic
end