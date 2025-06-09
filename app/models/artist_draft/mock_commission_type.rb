class ArtistDraft::MockCommissionType
  attr_reader :data, :id, :subject, :medium, :price, :width, :height, :unit

  def initialize(data_hash = {}, id)
    @data = data_hash.with_indifferent_access
    @id = id
    @subject = @data[:subject]
    @medium = @data[:medium]
    @price = @data[:price]
    @width = @data[:width]
    @height = @data[:height]
    @unit = @data[:unit]
  end

  def size
    unit_symbol = @unit == "cm" ? "cm" : "\""
    "#{@width.round()}x#{@height.round()}#{unit_symbol}"
  end
end
