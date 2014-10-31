module GenericImporter
  def import_data(file_part, importer, columns)

    results = process_file(file_part)

    unless results[:success]
      return results
    end

    data = Roo::CSV.new(results[:file_path])

    header = data.row(1)

    header_validation = validate_header(header, columns)

    if header_validation != true
      results[:success] = false
      results[:errors] << 'Column missing: ' + header_validation
      return results
    end

    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      case importer
        when :producers
          process_producer_row(row)
        when :regions
          process_region_row(row)
        when :subregions
          process_subregion_row(row)
        when :locales
          process_locale_row(row)
        when :appellations
          process_appellations_row(row)
        when :maturations
          process_maturations_row(row)
        when :vinifications
          process_vinifications_row(row)
        when :grapes
          process_grapes_row(row)
      end
    end

    results

  end

  def process_producer_row(row)
    id = row['producer_id']
    name = row['name']
    country_id = row['country_id']

    if id.blank? || name.blank? || country_id.blank?
      return
    end

    producer = Producer.find_by_id(id)

    if producer.nil?
      Producer.create!(
          id: id,
          name: name,
          country_id: country_id,
          note: row['note'],
      )
    else
      producer.update(
          name: name,
          country_id: country_id,
          note: row['note'],
      )
      producer.save
    end
  end

  def process_region_row(row)

    id = row['region_id']
    name = row['name']
    country_id = row['country_id']

    if id.blank? || name.blank? || country_id.blank?
      return
    end

    region = Region.find_by_id(id)

    if region.nil?
      Region.create!(
          id: id,
          name: name,
          country_id: country_id
      )
    else
      region.update(
          name: name,
          country_id: country_id
      )
      region.save
    end
  end

  def process_subregion_row(row)

    id = row['subregion_id']
    name = row['name']
    region_id = row['region_id']

    if id.blank? || name.blank? || region_id.blank?
      return
    end

    subregion = Subregion.find_by_id(id)

    if subregion.nil?
      Subregion.create!(
          id: id,
          name: name,
          region_id: region_id
      )
    else
      subregion.update(
          name: name,
          region_id: region_id
      )
      subregion.save
    end
  end

  def process_locale_row(row)

    id = row['locale_id']
    name = row['name']
    subregion_id = row['subregion_id']
    note = row['note']

    if id.blank? || name.blank? || subregion_id.blank?
      return
    end

    locale = Locale.find_by_id(id)

    if locale.nil?
      Locale.create!(
          id: id,
          name: name,
          subregion_id: subregion_id,
          note: note
      )
    else
      locale.update(
          name: name,
          subregion_id: subregion_id,
          note: note
      )
      locale.save
    end
  end

  def process_appellations_row(row)

    id = row['appellation_id']
    name = row['name']
    region_id = row['region_id']
    classification = row['classification']

    if id.blank? || name.blank? || region_id.blank?
      return
    end

    appellation = Appellation.find_by_id(id)

    if appellation.nil?
      Appellation.create!(
          id: id,
          name: name,
          region_id: region_id,
          classification: classification
      )
    else
      appellation.update(
          name: name,
          region_id: region_id,
          classification: classification
      )
      appellation.save
    end
  end

  def process_maturations_row(row)

    id = row['maturation_id']
    description = row['description']
    bottling_id = row['bottling_id']

    if id.blank? || description.blank?
      return
    end

    maturation = Maturation.find_by_id(id)

    if maturation.nil?
      Maturation.create!(
          id: id,
          description: description,
          bottling_id: bottling_id
      )
    else
      maturation.update(
          description: description,
          bottling_id: bottling_id
      )
      maturation.save
    end
  end

  def process_vinifications_row(row)

    id = row['vinification_id']
    method = row['method']
    name = row['name']

    if id.blank? || method.blank?
      return
    end

    vinification = Vinification.find_by_id(id)

    if vinification.nil?
      Vinification.create!(
          id: id,
          method: method,
          name: name
      )
    else
      vinification[:method] = method
      vinification.name = name
      vinification.save
    end
  end

  def process_grapes_row(row)

    id = row['grape_id']
    name = row['name']

    if id.blank? || name.blank?
      return
    end

    grape = Grape.find_by_id(id)

    if grape.nil?
      Grape.create!(
          id: id,
          name: name
      )
    else
      grape.update(
          name: name
      )
      grape.save
    end
  end

  def process_file(file_part)
    response = {
        :success => false,
        :errors => [],
        :file_path => ''
    }

    uploaded_file = file_part

    if uploaded_file.nil?
      response[:errors] << 'Please specify file to upload.'
      return response
    end

    file_name = uploaded_file.original_filename

    file_extension = File.extname(file_name)

    if file_extension != '.csv'
      response[:errors] << 'File must be .csv format.'
      return response
    end

    file_path = Rails.root.join('public', 'uploads', [Time.now.strftime('%Y-%m-%d-%H%M%S'), file_name].join('_'))

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    response[:file_path] = file_path.to_s
    response[:success] = true

    response

  end

  def validate_header(header, columns)
    columns.each do |column|
      found_column = header.select { |item| item == column }
      if found_column.length == 0
        return column
      end
    end
    true
  end
end