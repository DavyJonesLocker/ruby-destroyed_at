module DestroyedAt
  module HasManyAssociation
    def delete_records(records, method)
      if method == :destroy
        records.each do |r|
          if r.respond_to?(:destroyed_at) && owner.respond_to?(:destroyed_at)
            r.destroy(owner.destroyed_at)
          else
            r.destroy
          end
        end
        update_counter(-records.length) unless inverse_updates_counter_cache?
      else
        super
      end
    end
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:prepend, DestroyedAt::HasManyAssociation)
