module OpenStreetMap
  # OpenStreetMap Relation.
  #
  # To create a new OpenStreetMap::Relation object:
  #   relation = OpenStreetMap::Relation.new()
  #
  # To get a relation from the API:
  #   relation = OpenStreetMap::Relation.find(17)
  #
  class Relation < Element
    # Array of Member objects
    attr_reader :members

    # Create new Relation object.
    #
    # If +id+ is +nil+ a new unique negative ID will be allocated.
    def initialize(attrs)
      attrs.stringify_keys!
      @members = extract_member(attrs['member'])
      super(attrs)
    end

    def type
      'relation'
    end

    protected

    def extract_member(member_array)
      return [] unless member_array && member_array.size > 0

      member_array.inject([]) do |memo, member|
        class_to_instantize = "OpenStreetMap::#{member['type'].classify}".constantize
        memo << class_to_instantize.new(:id => member['ref'])
      end
    end

  end
end