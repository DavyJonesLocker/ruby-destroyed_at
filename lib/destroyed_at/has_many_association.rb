module DestroyedAt
  module HasManyAssociation
    def delete_records(records, method)
      if method == :destroy
        records.each { |r| r.destroy(owner.destroyed_at) }
        update_counter(-records.length) unless inverse_updates_counter_cache?
      else
        super
      end
    end
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:prepend, DestroyedAt::HasManyAssociation)
