module WineImporter

  #todo need to return status and errors
  def import_wines(file)

    wine_data = Roo::CSV.new(file)

    header = wine_data.row(1)

    if validate_wine_data(wine_data)
      (2..wine_data.last_row).each do |i|
        row = Hash[[header, wine_data.row(i)].transpose]

        key = row['wine_key']

        unless key.nil?
          wine = Wine.find_by(wine_key: key)
        end

        unless wine.nil?

          wine.update(
              name: row['name'],
              vintage: convert_vintage(row['vintage']),
              single_estate: if row['single_estate'].nil?
                               false
                             else
                               row['single_estate'].downcase.strip == 'true' ? true : false
                             end,
              alcohol: row['alcohol'],
              producer_id: row['producer_id'].to_i,
              type_id: row['type_id'].to_i,
              note: row['note'],
              bottle_size: row['bottle_size'],
              region_id: row['region_id'],
              subregion_id: row['subregion_id'],
              locale_id: row['locale_id'],
              appellation_id: row['appellation_id'],
              maturation_id: row['maturation_id'],
              vinification_id: row['vinification_id'],
              composition_id: row['composition_id']
          )
        else

          new_key = create_wine_key(row)

          #TODO: Allow for forcing of new key from file upload to overwrite generated one.
          if !key.nil? && key.length > 0 && key != new_key
            puts 'Existing Key in file: ' + key + ' doesn\'t match generated key: ' + new_key + '\nUsing Generate Key'
          end

          existing_wine = Wine.find_by(wine_key: new_key)

          if existing_wine.nil?
            Wine.create!(
                :wine_key => new_key,
                :name => row['name'],
                :vintage => convert_vintage(row['vintage']),
                :single_estate => if row['single_estate'].nil?
                                    false
                                  else
                                    row['single_estate'].downcase.strip == 'true' ? true : false
                                  end,
                :alcohol => row['alcohol'],
                :producer_id => row['producer_id'].to_i,
                :type_id => row['type_id'].to_i,
                :note => row['note'],
                :bottle_size => row['bottle_size'],
                :region_id => row['region_id'],
                :subregion_id => row['subregion_id'],
                :locale_id => row['locale_id'],
                :appellation_id => row['appellation_id'],
                :maturation_id => row['maturation_id'],
                :vinification_id => row['vinification_id'],
                :composition_id => row['composition_id']
            )
          else
            puts 'Duplicate wine key found: ' + new_key + ' name: ' + existing_wine.name + ' - new wine name: ' + row['name']
            return
          end
        end
      end
    end
  end

  #TODO: Move to model
  def create_wine_key_from_wine(wine)
    key = convert_name_to_key_part(wine.name)
    key.concat('-')
    key.concat(convert_vintage_to_key_part(convert_vintage(wine.vintage)))

    unless wine.composition_id.blank?
      key.concat('-')
      key.concat('c' + wine.composition_id)
      key.concat('-')
    end

    key.concat(convert_producer_to_key_part(wine.producer_id))

    region = convert_region_to_key_part(wine.region_id)

    if region.length == 2
      key.concat('-')
      key.concat(region)
    end

    subregion = convert_subregion_to_key_part(wine.subregion_id)

    if subregion.length == 2
      key.concat('-')
      key.concat(subregion)
    end

    bottle = convert_bottle_size_to_key_part(wine.bottle_size)

    if bottle.length > 0
      key.concat('-')
      key.concat(bottle)
    end

    key
  end

  def create_wine_key(row)
    key = convert_name_to_key_part(row['name'])
    key.concat('-')
    key.concat(convert_vintage_to_key_part(convert_vintage(row['vintage'])))
    key.concat('-')
    key.concat('c' + row['composition_id'])
    key.concat('-')
    key.concat(convert_producer_to_key_part(row['producer_id']))

    region = convert_region_to_key_part(row['region_id'])

    if region.length == 2
      key.concat('-')
      key.concat(region)
    end

    subregion = convert_subregion_to_key_part(row['subregion_id'])

    if subregion.length == 2
      key.concat('-')
      key.concat(subregion)
    end

    bottle = convert_bottle_size_to_key_part(row['bottle_size'])

    if bottle.length > 0
      key.concat('-')
      key.concat(bottle)
    end

    key
  end

  def convert_name_to_key_part(name)

    part = ''

    parts = convert_to_ascii(name).downcase.split

    parts.each do |p|
      part.concat(p[0, 1])
    end

    part

  end

  def convert_vintage_to_key_part(vintage)
    if vintage.nil?
      'nv'
    else
      if vintage == 0
        'uv'
      else
        vintage.to_s[2, 1] + vintage.to_s[3, 1]
      end
    end
  end

  def convert_producer_to_key_part(producer_id)

    producer = Producer.find(producer_id)
    name = convert_to_ascii(producer.name).downcase.split

    if name.length > 1
      part = name[0][0, 1] + name[0][1, 1] + name[1][0, 1] + name[1][1, 1]
    else
      part = name[0][0, 1] + name[0][1, 1]
    end

    part + '-' + producer.country.alpha_2
  end

  def convert_region_to_key_part(region_id)

    if region_id.nil? || region_id == ''
      return '_'
    end

    region = Region.find(region_id)

    if region.nil?
      return '_'
    end

    name = convert_to_ascii(region.name).downcase.split
    name[0][0, 1] + name[0][1, 1]
  end

  def convert_subregion_to_key_part(subregion_id)

    if subregion_id.nil? || subregion_id == ''
      return '_'
    end

    subregion = Subregion.find(subregion_id)

    if subregion.nil?
      return '_'
    end

    name = convert_to_ascii(subregion.name).downcase.split
    name[0][0, 1] + name[0][1, 1]
  end

  def convert_bottle_size_to_key_part(bottle_size)
    if bottle_size.to_s != '75'
      bottle_size.to_s
    else
      ''
    end
  end

  #Convert to ASCII and remove keep only alphanumeric characters
  def convert_to_ascii(string)
    encoding_options = {
        :invalid => :replace, # Replace invalid byte sequences
        :undef => :replace, # Replace anything not defined in ASCII
        :replace => '', # Use a blank for those replacements
        :universal_newline => true # Always break lines with \n
    }

    string.encode(Encoding.find('ASCII'), encoding_options).gsub(/[^0-9a-z ]/i, '')
  end

  def validate_wine_data(data)
    header = data.row(1)
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      name = row['name']

      if name.nil?
        puts 'Wine name cannot be empty'
        return false
      end

      if row['producer_id'].to_i == 0
        puts 'Producer cannot be empty - ' + name
        return false
      end

      if row['type_id'].to_i == 0
        puts 'Wine type is required - ' + name
        return false
      end

      if row['composition_id'].to_i == 0
        puts 'Wine composition is required - ' + name
        return false
      end

    end
  end

  def convert_vintage(vintage)
    vintage = vintage.to_s.strip.downcase
    case vintage
      when 'nv'
        nil
      else
        case vintage.length
          when 4
            vintage.to_i
          else
            0
        end
    end
  end

end