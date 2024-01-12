# frozen_string_literal: true

module Holdings
  # Represents an individual holding returned from the Alma real time availability API
  class Holding
    attr_accessor :raw

    def initialize(mms_id, holding)
      @mms_id = mms_id
      @raw = holding
    end

    # @return [String]
    def status
      case type
      when 'physical'
        @raw.fetch('availability', '')
      when 'electronic'
        @raw.fetch('activation_status', '')
      else
        ''
      end
    end

    # @return [String]
    def policy
      ''
    end

    # @return [String]
    def description
      case type
      when 'physical'
        @raw.fetch('call_number', '')
      when 'electronic'
        @raw.fetch('collection', '')
      else
        ''
      end
    end

    # @return [String]
    def format
      ''
    end

    # @return [String]
    def count
      @raw.fetch('total_items', '')
    end

    # @return [String]
    def location
      @raw.fetch('library', '')
    end

    # @return [String]
    def id
      case type
      when 'physical'
        @raw.fetch('holding_id', '')
      when 'electronic'
        @raw.fetch('portfolio_pid', '')
      else
        ''
      end
    end

    # @return [String]
    def href
      case type
      when 'physical'
        "/catalog/#{@mms_id}##{id}"
      when 'electronic'
        'https://upenn.alma.exlibrisgroup.com/view/uresolver/01UPENN_INST/openurl?Force_direct=true&portfolio_pid=' \
        "#{id}&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true"
      else
        ''
      end
    end

    # @return [String]
    def type
      @type ||= @raw.fetch('inventory_type', '')
    end

    # @return [Hash]
    def to_h
      {
        status: status, policy: policy, description: description, format: format, count: count,
        location: location, id: id, href: href, type: type
      }
    end
  end
end
