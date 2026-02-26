# frozen_string_literal: true

# To speedup searches of this large table, add a "virtual"/generated column with the searchable content aggregated.
# This means the vector tokens will be pre-computed and kept up-to-date as records are modified.
# Also add index for sortable "on display" field.
class AddVectorFieldToArtifact < ActiveRecord::Migration[8.1]
  def change
    # sql to build a vector field from searchable fields using english analysis (stemming)
    searched_fields_aggregator_sql = <<~SQL
      to_tsvector('english', coalesce(title, '')       || ' ' ||
                             coalesce(description, '') || ' ' ||
                             coalesce(creator, '')     || ' ' ||
                             coalesce(location, '')    || ' ' ||
                             coalesce(format, ''))
    SQL

    # create a "virtual" column that is not used by the ORM. store the data do it can be indexed.
    add_column :discover_artifacts, :search_vector, :virtual, type: :tsvector, stored: true,
                                                              as: searched_fields_aggregator_sql

    add_index :discover_artifacts, :search_vector, using: :gin
    add_index :discover_artifacts, :on_display
  end
end
