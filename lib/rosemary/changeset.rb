require 'builder'
module Rosemary
  # Changeset is used in OpenStreetMap to bundle several changes into a kind of "commit"
  class Changeset
    # Unique ID
    # @return [Fixnum]
    attr_reader :id

    # The user who last edited this object (as read from file, it is not updated by operations to this object)
    # @return [Rosemary::User] the user who last edited this object
    attr_accessor :user

    # The user id of the user who last edited this object(as read from file, it
    # is not updated by operations to this object) API 0.6 and above only
    # @return [Fixnum] the user id of the user who last edited this object
    attr_accessor :uid

    # @return [Boolean] is this changeset is still open.
    attr_accessor :open

    # @return [Date] creation date of this changeset
    attr_accessor :created_at

    # @return [Date] when the changeset was closed
    attr_accessor :closed_at

    # Bounding box surrounding all changes made in this changeset
    # @return [Float]
    attr_accessor :min_lat, :min_lon, :max_lat, :max_lon

    # Tags for this object
    # @return [Hash]
    attr_reader :tags

    def initialize(attrs = {}) #:nodoc:
      attrs = attrs.dup.stringify_keys!
      @id                 = attrs['id'].to_i if attrs['id']
      @uid                = attrs['uid'].to_i
      @user               = attrs['user']
      @created_at         = Time.parse(attrs['created_at']) rescue nil
      @closed_at          = Time.parse(attrs['closed_at']) rescue nil
      @open               = attrs['open']
      tags = attrs['tags'] || {}
      @tags               = Tags.new.merge(tags.dup.stringify_keys!)
      @tags['created_by'] = "rosemary v#{Rosemary::VERSION}"
      @min_lat            = attrs['min_lat'].to_f
      @min_lon            = attrs['min_lon'].to_f
      @max_lat            = attrs['max_lat'].to_f
      @max_lon            = attrs['max_lon'].to_f

    end

    # Set timestamp for this object.
    def created_at=(timestamp)
      @created_at = Time.parse(timestamp)
    end

    # Is this changeset still open?
    def open?
      ["yes", "1", "t", "true"].include?(open)
    end

    # List of attributes for a Changeset
    # @return [Array]
    def attribute_list
      [:id, :user, :uid, :open, :created_at, :closed_at, :min_lat, :max_lat, :min_lon, :max_lon]
    end

    # A hash of all non-nil attributes of this object.
    # Keys of this hash are <tt>:id</tt>, <tt>:user</tt>,
    # and <tt>:timestamp</tt>. For a Node also <tt>:lon</tt>
    # and <tt>:lat</tt>.
    #
    # @return [Hash] a hash of all non-nil attributes of this object.
    #
    def attributes
      attrs = Hash.new
      attribute_list.each do |attribute|
        value = self.send(attribute)
        attrs[attribute] = value unless value.nil?
      end
      attrs
    end

    # Renders the object as an xml representation compatible to the OSM API
    # @return [String] XML
    def to_xml(options = {})
      xml = options[:builder] ||= Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.osm do
        xml.changeset(attributes) do
          tags.each do |k,v|
            xml.tag(:k => k, :v => v)
          end unless tags.empty?
        end
      end
    end

  end
end