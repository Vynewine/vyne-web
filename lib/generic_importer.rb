module GenericImporter
  def import_data(file_part, importer)

    results = process_file(file_part)

    unless results[:success]
      return results
    end

    data = Roo::CSV.new(results[:file_path])

    header = data.row(1)

    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      id = row['id']
      case importer
        when :producers
          process_producer_row(id, row)
        when :regions
          process_region_row(id, row)
      end
    end

    results

  end

  def process_producer_row(id, row)
    producer = Producer.find_by_id(id)

    if producer.nil?
      Producer.create!(
          id: id,
          name: row['name'],
          country_id: row['country_id'],
          note: row['note'],
      )
    else
      producer.update(
          name: row['name'],
          country_id: row['country_id'],
          note: row['note'],
      )
    end
  end

  def process_region_row(id, row)
    region = Region.find_by_id(id)

    if region.nil?
      Region.create!(
          id: id,
          name: row['name'],
          country_id: row['country_id']
      )
    else
      region.update(
          name: row['name'],
          country_id: row['country_id']
      )
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
end