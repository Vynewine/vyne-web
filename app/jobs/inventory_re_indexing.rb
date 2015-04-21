class InventoryReIndexing

  @queue = :re_indexing
  @logger = Logging.logger['InventoryReIndexingJob']
  TAG = 'Inventory Re-Indexing'

  def self.perform (wines)
    log 'Starting Solr Inventory Re-Index'
    unless wines.blank?
      wines.each do |wine_id|
        wine = Wine.find(wine_id)
        Sunspot.index wine

        unless wine.inventories.blank?
          wine.inventories.each do |inventory|
            Sunspot.index inventory
          end
        end

      end
      Sunspot.commit
    end
    log 'Completed Solr Inventory Re-Index'
  end

  def self.log(message)
    @logger.info message
  end

end