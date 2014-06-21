module HeightHelper

  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, InstanceMethods
  end

  class MissingArgumentError < ArgumentError; end
  class BadArgumentError  < ArgumentError; end

  NIL_STATUS = "is_nil"
  IS_NUMBER_STATUS = "is_number"
  INVALID_STATUS = "invalid"

  module ClassMethods
    def height_inches_select_options(rebuild=false)
      unless @height_inches_select_options || rebuild
        @height_inches_select_options = []
        36.upto(96) do |n|
          feet = n / 12
          inches = n % 12
          label = "#{feet}' #{inches}\""
          @height_inches_select_options << [label, n]
        end
      end
      @height_inches_select_options
    end
  end

  module InstanceMethods
    def param_status(arg)
      if arg.nil?
        return NIL_STATUS
      elsif is_a_number?(arg)
        return IS_NUMBER_STATUS
      else
        return INVALID_STATUS
      end
    end

    def is_a_number?(s)

      s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true

    end

    def to_inches(options)
      feet_status = param_status(options[:feet])
      inches_status = param_status(options[:inches])
      centemeters_status = param_status(options[:centemeters])
      ret_val = nil;

      if ( (feet_status == NIL_STATUS) && (centemeters_status == NIL_STATUS) )
        raise MissingArgumentError, "Missing Argument. Must provide feet or centemeters to convert", caller
      elsif ( (feet_status == INVALID_STATUS) || (inches_status == INVALID_STATUS) )
          raise BadArgumentError, "Invalid Argument. feet and inches must be numbers: feet = #{options[:feet]}, inches = #{options[:inches]})", caller
      elsif (feet_status == IS_NUMBER_STATUS)
        feet = options[:feet]
        inches = 0
        unless (inches_status == NIL_STATUS)
          inches = options[:inches]
        end
        ret_val = (feet.to_i * 12) + inches.to_i
      elsif (centemeters_status == IS_NUMBER_STATUS)
        ret_val = (options[:centemeters] / 2.54).to_i
      end

      if(ret_val.nil?)
        raise ArgumentError, "Unkown Error.", caller
      else
        return ret_val
      end
    end

  end

end
