# -*- encoding: utf-8 -*-

module ActiveRecord
  module ConnectionAdapters
    module Hana
      module Quoting

        QUOTED_TRUE, QUOTED_FALSE = '1', '0'

        def quoted_true
          QUOTED_TRUE
        end

        def quoted_false
          QUOTED_FALSE
        end

        def type_cast(value, column)
          return value.id if value.respond_to?(:quoted_id)

          case value
          when String, ActiveSupport::Multibyte::Chars
            value = value.to_s
            return value unless column

          case column.type
          when :binary then value
          when :integer then value.to_i
          when :float then value.to_f
          else
            value
          end

          when true, false then value ? quoted_true : quoted_false
  
          # BigDecimals need to be put in a non-normalized form and quoted.
          when nil        then nil
          when BigDecimal then value.to_s('F')
          when Numeric    then value
          when Date, Time then quoted_date(value)
          when Symbol     then value.to_s
          else
            YAML.dump(value)
          end
        end
        
        def quoted_date(value)
          if value.acts_like?(:time)
            zone_conversion_method = ActiveRecord::Base.default_timezone == :utc ? :getutc : :getlocal

            if value.respond_to?(zone_conversion_method)
              value = value.send(zone_conversion_method)
            end
          end

          value.to_s(:db).gsub(/ UTC.*/,"")
        end
      end
    end
  end
end
