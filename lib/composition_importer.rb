module CompositionImporter
  def import_data(file_part, columns)

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

      id = row['composition_id']
      name = row['name']
      grape1_id = row['grape1_id']

      max_grapes = 10


      if id.blank? || grape1_id.blank?
        return
      end

      composition = Composition.find_by_id(id)

      if composition.nil?
        new_composition = Composition.create!(
            id: id,
            name: name
        )

        (1..max_grapes).each do |i|
          grape_id = row['grape' + i.to_s + '_id']
          unless grape_id.blank?
            percentage = row['grape' + i.to_s + '_percentage']
            CompositionGrape.create(
                composition_id: new_composition.id,
                grape_id: grape_id,
                percentage: percentage
            )
          end
        end

      else
        composition.update(
            name: name
        )

        (1..max_grapes).each do |i|
          grape_id = row['grape' + i.to_s + '_id']
          unless grape_id.blank?
            percentage = row['grape' + i.to_s + '_percentage']
            existing_comp = composition.composition_grapes.detect { |comp| comp.grape_id == grape_id.to_i }
            if existing_comp.blank?
              CompositionGrape.create(
                  composition_id: composition.id,
                  grape_id: grape_id,
                  percentage: percentage
              )
            else
              existing_comp.update(
                  grape_id: grape_id,
                  percentage: percentage
              )
            end
          end
        end

        composition.save
      end
    end

    results

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