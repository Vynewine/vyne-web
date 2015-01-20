class InventoryReIndexing

  @queue = :re_indexing
  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Inventory Re-Indexing'

  def self.perform (wines)
    log 'Starting Solr Inventory Re-Index'
    unless wines.blank?
      wines.each do |wine_id|
        wine = Wine.find(wine_id)
        Sunspot.index wine
      end
      Sunspot.commit
    end
    log 'Completed Solr Inventory Re-Index'
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

end