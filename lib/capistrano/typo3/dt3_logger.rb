require 'logger'

class DT3Logger
  class << self

    # WE USE THE TYPES INFO, ERROR, DEBUG, WARN
    def log(key, val='', type='info')

      if(@logger.nil?) then
        @logger = Logger.new("rake-typo3.log")
        @logger.level = Logger::DEBUG
      end

      if( (fetch(:debug).to_i==1 && type=='debug') || (type!='debug'))
        logstring = "#{type.upcase} - #{key}#{val==''?'':': '+val}"
        @logger.info Time.now.strftime("%b-%d-%Y %H:%M") +' '+ logstring
        print "#{logstring}\n"
      end
    end
  end
end
